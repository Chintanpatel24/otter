CC = gcc
CFLAGS = -Wall -Wextra -O2 -std=c11 -I.
LDFLAGS = -lm

# Detect nvcc
HAS_NVCC := $(shell command -v nvcc 2> /dev/null)

ifdef HAS_NVCC
    CUDA_SRCS = cuda/kernels.cu
    CUDA_OBJ = cuda/kernels.o
    CUDA_LDFLAGS = -L/usr/local/cuda/lib64 -lcudart
    CFLAGS += -DUSE_CUDA
else
    CUDA_SRCS =
    CUDA_OBJ =
    CUDA_LDFLAGS =
endif

ENGINE_SRCS = engine/tensor.c engine/stream.c engine/quant.c engine/attention.c \
               engine/tokenizer.c engine/inference.c engine/otter_bridge.c
ENGINE_OBJ = $(ENGINE_SRCS:.c=.o)

.PHONY: all clean test build-gui

all: otter-engine mesh/mesh

otter-engine: $(ENGINE_OBJ) $(CUDA_OBJ) engine/main.o
	$(CC) $(ENGINE_OBJ) $(CUDA_OBJ) engine/main.o -o otter-engine $(LDFLAGS) $(CUDA_LDFLAGS)

mesh/mesh: mesh/mesh.c
	$(CC) $(CFLAGS) mesh/mesh.c -o mesh/mesh

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

cuda/kernels.o: cuda/kernels.cu
	nvcc -O2 -c $< -o $@

test: otter-engine
	./otter-engine

build-gui:
	cd src/.. || cd ..; cargo build --release

clean:
	rm -f $(ENGINE_OBJ) $(CUDA_OBJ) engine/main.o otter-engine mesh/mesh
