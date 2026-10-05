# Build the CUDA mirror yardstick (host compile only needs nvcc; running needs a quiet GPU).
# Usage: make OMEGA_DIR=/path/to/omega-checkout   (needs bench/prime_race/prime_race_impl.{h,c})
NVCC    ?= /usr/local/cuda/bin/nvcc
ARCH    ?= sm_121
CC      ?= cc
ifeq ($(OMEGA_DIR),)
$(error OMEGA_DIR is required, e.g. make OMEGA_DIR=$$HOME/workspace/omega)
endif
PRDIR   := $(OMEGA_DIR)/bench/prime_race
OMEGA_COMMIT := $(shell git -C $(OMEGA_DIR) rev-parse HEAD)
OMEGA_DIRTY  := $(shell git -C $(OMEGA_DIR) status --porcelain -- bench/prime_race | head -c1)
YARD_COMMIT  := $(shell git -C $(CURDIR) rev-parse HEAD)
NVCC_VERSION := $(shell $(NVCC) --version | tail -n2 | tr '\n' ' ' | sed 's/ *$$//')
NVCC_FLAGS   := -O3 -arch=$(ARCH) -Xcompiler -O3,-mcpu=native
CFLAGS_HOST  := -O3 -mcpu=native -Wall -Wextra

BUILD := build
all: $(BUILD)/prime-race-cuda-mirror

$(BUILD)/build_info.h: FORCE | $(BUILD)
	@printf '#define YS_NVCC_VERSION "%s"\n#define YS_NVCC_FLAGS "%s"\n#define YS_OMEGA_COMMIT "%s%s"\n#define YS_YARD_COMMIT "%s"\n' \
	  "$(NVCC_VERSION)" "$(NVCC_FLAGS)" "$(OMEGA_COMMIT)" "$(if $(OMEGA_DIRTY),+dirty)" "$(YARD_COMMIT)" > $@.tmp
	@cmp -s $@.tmp $@ && rm $@.tmp || mv $@.tmp $@

$(BUILD)/prime_race_impl.o: $(PRDIR)/prime_race_impl.c | $(BUILD)
	nice -n 19 $(CC) $(CFLAGS_HOST) -I$(PRDIR) \
	  -DPR_SOURCE_COMMIT='"omega=$(OMEGA_COMMIT)$(if $(OMEGA_DIRTY),+dirty);yardsticks=$(YARD_COMMIT)"' \
	  -DPR_CC='"$(CC) + nvcc"' -DPR_CFLAGS='"host: $(CFLAGS_HOST); nvcc: $(NVCC_FLAGS)"' -c $< -o $@

$(BUILD)/sieve_cuda.o: sieve_cuda.cu $(BUILD)/build_info.h | $(BUILD)
	nice -n 19 $(NVCC) $(NVCC_FLAGS) -Xcompiler -Wall,-Wextra -I$(PRDIR) -I$(BUILD) -c $< -o $@

$(BUILD)/prime-race-cuda-mirror: $(BUILD)/sieve_cuda.o $(BUILD)/prime_race_impl.o
	nice -n 19 $(NVCC) -arch=$(ARCH) $^ -o $@

$(BUILD):
	mkdir -p $@

clean:
	rm -rf $(BUILD)

FORCE:
.PHONY: all clean FORCE
