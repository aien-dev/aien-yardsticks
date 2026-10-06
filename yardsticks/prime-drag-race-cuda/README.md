# prime-drag-race-cuda

An outside CUDA yardstick for the AIEN Prime Drag Race (a prime sieve speed contest). It runs the same
algorithm as the AIEN native GPU kernel, written in CUDA, so the two can be compared fairly on the same
GB10 chip. It is a yardstick only: it lives outside AIEN and nothing here ships in AIEN.

## What it does
Each thread owns one 32-bit word of the answer and loops over the odd base primes up to sqrt(limit). No
atomics. The host builds the base primes and their division constants, copies them over, launches, then
copies the whole result back to host memory (the copy is counted in every pass, because the result must be
host-readable). Labels match the native kernel: algorithm=other, faithful=no, bits=1, environment
linux-hosted-gb10-cuda. Kernel-only time (cudaEvents) is a diagnostic in the report, not the score.

The command line, timing loop, report and bitmap export come from the shared protocol in omega
(`bench/prime_race/prime_race_impl.{h,c}`). This repo does not copy it. The build records the omega commit,
this repo's commit, the nvcc version and the flags inside the binary.

## Upstream relation
Upstream PrimeCUDA/solution_2 (PlummersSoftwareLLC/Primes, pinned a2899c96752b65ac1b08a0e1418ab7e708040ed0)
splits the work differently. It is reference reading only and was not copied. This program is NONCONFORMING
for upstream submission (different algorithm split, shared protocol harness).

## Build (compile only, safe anywhere with nvcc)
    make OMEGA_DIR=/path/to/omega-checkout
Needs nvcc at /usr/local/cuda/bin (13.0 tested) and `-arch=sm_121` (GB10). Override with `ARCH=...` or `NVCC=...`.

## Run (uses the GPU: only inside a quiet-flag window)
    build/prime-race-cuda-mirror --limit 1000000 --min-seconds 5 --report-out r.json --bitmap-out b.bin
    build/prime-race-cuda-mirror --limit 1000000 --audit-passes 5 --bitmap-out audit.bin
Limit 1,000,000 must give 78,498 primes. Limits above 2^33-2 are refused (32-bit indices).
