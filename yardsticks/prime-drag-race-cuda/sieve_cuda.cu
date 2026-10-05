// aien-cuda-mirror: outside CUDA yardstick that mirrors the AIEN native GPU kernel algorithm exactly.
// One thread per 32-bit output word, loop over odd base primes, no atomics. See README.md.
#include <cuda_runtime.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern "C" {
#include "prime_race_impl.h"
}

#include "build_info.h"

#define BLOCK 256

struct PrimeEnt { uint32_t p, magic, k0; };

static __global__ void sieve_words(uint32_t *out, uint32_t nwords, uint32_t odd_count,
                                   const PrimeEnt *primes, uint32_t nprimes) {
    uint32_t w = blockIdx.x * blockDim.x + threadIdx.x;
    if (w >= nwords) return;
    uint32_t base = 32u * w;
    uint32_t acc = 0;
    for (uint32_t i = 0; i < nprimes; i++) {
        PrimeEnt e = primes[i];
        if (e.k0 >= base + 32u) break;
        uint32_t j;
        if (e.k0 >= base) {
            j = e.k0 - base;
        } else {
            uint32_t d = base - e.k0;
            uint32_t q = __umulhi(d, e.magic);
            uint32_t r = d - q * e.p;
            if ((int32_t)r < 0) r += e.p;  // magic = ceil(2^32/p) can overshoot q by one
            if (r >= e.p) r -= e.p;
            j = (r == 0) ? 0u : e.p - r;
        }
        while (j < 32u) { acc |= 1u << j; j += e.p; }
    }
    if (w == 0) acc |= 1u;  // number 1 is not prime
    uint32_t tail = 0xffffffffu;
    if (w == nwords - 1 && (odd_count & 31u)) tail = (1u << (odd_count & 31u)) - 1u;
    out[w] = ~acc & tail;
}

struct State {
    uint64_t limit, odd_count;
    uint32_t nwords32, nprimes, grid;
    uint32_t *d_out;
    PrimeEnt *d_primes;
    uint32_t *h_out;
    PrimeEnt *h_primes;
    uint8_t *small;  // host small sieve scratch
    uint32_t cap_primes;
    uint64_t sqrt_limit;
    cudaEvent_t ev0, ev1;
    double diag_kernel_ns;
};

static int cu(cudaError_t e, const char *what) {
    if (e != cudaSuccess) { fprintf(stderr, "cuda error in %s: %s\n", what, cudaGetErrorString(e)); return 1; }
    return 0;
}

static uint64_t isqrt64(uint64_t n) {
    uint64_t lo = 0, hi = 1ull << 21, r = 0;
    while (lo <= hi) { uint64_t m = lo + (hi - lo) / 2; if (m * m <= n) { r = m; lo = m + 1; } else hi = m - 1; }
    return r;
}

static void cuda_teardown(void *vs) {
    State *s = (State *)vs;
    if (!s) return;
    if (s->d_out) cudaFree(s->d_out);
    if (s->d_primes) cudaFree(s->d_primes);
    if (s->ev0) cudaEventDestroy(s->ev0);
    if (s->ev1) cudaEventDestroy(s->ev1);
    free(s->h_out); free(s->h_primes); free(s->small);
    free(s);
}

static int cuda_setup(void **state, uint64_t limit) {
    if (limit > (1ull << 33) - 2) { fprintf(stderr, "limit too large for 32-bit indices\n"); return 1; }
    State *s = (State *)calloc(1, sizeof *s);
    if (!s) return 1;
    s->limit = limit;
    s->odd_count = pr_odd_count(limit);
    s->nwords32 = (uint32_t)((s->odd_count + 31) / 32);
    s->grid = (s->nwords32 + BLOCK - 1) / BLOCK;
    s->sqrt_limit = isqrt64(limit);
    s->cap_primes = (uint32_t)(s->sqrt_limit / 2 + 2);
    size_t nw = s->nwords32 ? s->nwords32 : 1;
    s->h_out = (uint32_t *)calloc(nw, 4);
    s->h_primes = (PrimeEnt *)calloc(s->cap_primes, sizeof(PrimeEnt));
    s->small = (uint8_t *)malloc(s->sqrt_limit + 2);
    *state = s;
    if (!s->h_out || !s->h_primes || !s->small) return 1;
    if (cu(cudaSetDevice(0), "cudaSetDevice")) return 1;
    if (cu(cudaMalloc(&s->d_out, nw * 4), "cudaMalloc out")) return 1;
    if (cu(cudaMalloc(&s->d_primes, s->cap_primes * sizeof(PrimeEnt)), "cudaMalloc primes")) return 1;
    if (cu(cudaEventCreate(&s->ev0), "event0") || cu(cudaEventCreate(&s->ev1), "event1")) return 1;
    return 0;
}

static int cuda_pass(void *vs, uint64_t limit) {
    State *s = (State *)vs;
    (void)limit;
    // timed work: host odd primes <= isqrt(limit) plus division magics, then H2D, launch, D2H
    uint64_t sq = s->sqrt_limit;
    memset(s->small, 1, sq + 1);
    uint32_t np = 0;
    for (uint64_t p = 3; p <= sq; p += 2) {
        if (!s->small[p]) continue;
        for (uint64_t m = p * p; m <= sq; m += 2 * p) s->small[m] = 0;
        s->h_primes[np].p = (uint32_t)p;
        s->h_primes[np].magic = (uint32_t)(((1ull << 32) + p - 1) / p);
        s->h_primes[np].k0 = (uint32_t)((p * p - 1) / 2);
        np++;
    }
    s->nprimes = np;
    if (s->nwords32 == 0) return 0;
    if (np && cu(cudaMemcpy(s->d_primes, s->h_primes, np * sizeof(PrimeEnt), cudaMemcpyHostToDevice), "H2D primes")) return 1;
    if (cu(cudaEventRecord(s->ev0), "ev0")) return 1;
    sieve_words<<<s->grid, BLOCK>>>(s->d_out, s->nwords32, (uint32_t)s->odd_count, s->d_primes, np);
    if (cu(cudaGetLastError(), "kernel launch")) return 1;
    if (cu(cudaEventRecord(s->ev1), "ev1")) return 1;
    // result must be host-resident: the D2H copy is counted in the pass
    if (cu(cudaMemcpy(s->h_out, s->d_out, (size_t)s->nwords32 * 4, cudaMemcpyDeviceToHost), "D2H out")) return 1;
    if (cu(cudaDeviceSynchronize(), "sync")) return 1;
    if (cu(cudaGetLastError(), "post-run")) return 1;
    float ms = 0;
    if (cu(cudaEventElapsedTime(&ms, s->ev0, s->ev1), "elapsed")) return 1;
    s->diag_kernel_ns += (double)ms * 1e6;
    return 0;
}

static int cuda_export(void *vs, uint64_t limit, uint64_t *out) {
    State *s = (State *)vs;
    size_t n64 = pr_words64(limit);
    for (size_t i = 0; i < n64; i++) {
        uint64_t lo = s->h_out[2 * i];
        uint64_t hi = (2 * i + 1 < s->nwords32) ? s->h_out[2 * i + 1] : 0;
        out[i] = lo | (hi << 32);
    }
    return 0;
}

static uint64_t cuda_threads(void *vs) { State *s = (State *)vs; return (uint64_t)s->grid * BLOCK; }

static int cuda_detail(void *vs, FILE *f) {
    State *s = (State *)vs;
    int rt = 0, drv = 0;
    cudaRuntimeGetVersion(&rt);
    cudaDriverGetVersion(&drv);
    fprintf(f, "{\"grid\":%u,\"block\":%d,\"words32\":%u,\"nprimes\":%u,"
               "\"cuda_runtime\":%d,\"cuda_driver\":%d,"
               "\"diag_kernel_ns_total\":%.0f,\"diag_kernel_ns_note\":\"sum of cudaEvent kernel-only times, diagnostic, not the score\","
               "\"result_copy\":\"D2H of full output counted in every pass\","
               "\"nvcc_version\":\"%s\",\"nvcc_flags\":\"%s\",\"omega_commit\":\"%s\",\"yardsticks_commit\":\"%s\"}",
            s->grid, BLOCK, s->nwords32, s->nprimes, rt, drv, s->diag_kernel_ns,
            YS_NVCC_VERSION, YS_NVCC_FLAGS, YS_OMEGA_COMMIT, YS_YARD_COMMIT);
    return 0;
}

int main(int argc, char **argv) {
    static const pr_impl impl = {
        "cuda-mirror", "other", "no", 1, "linux-hosted-gb10-cuda",
        cuda_setup, cuda_pass, cuda_export, cuda_threads, cuda_detail, cuda_teardown,
    };
    return pr_main(argc, argv, &impl);
}
