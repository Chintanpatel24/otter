CC = gcc
CFLAGS = -Wall -Wextra -O2 -std=c11 -I.
LDFLAGS = -lm

ENGINE_SRCS = engine/tensor.c engine/stream.c engine/quant.c engine/attention.c \
               engine/tokenizer.c engine/inference.c engine/otter_bridge.c
ENGINE_OBJ = $(ENGINE_SRCS:.c=.o)

.PHONY: all clean test build-gui

all: otter-engine mesh/mesh

otter-engine: $(ENGINE_OBJ) engine/main.o
	$(CC) $(ENGINE_OBJ) engine/main.o -o otter-engine $(LDFLAGS)

mesh/mesh: mesh/mesh.c
	$(CC) $(CFLAGS) mesh/mesh.c -o mesh/mesh

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

test: otter-engine
	./otter-engine

build-gui:
	cd src/.. || cd ..; cargo build --release

clean:
	rm -f $(ENGINE_OBJ) engine/main.o otter-engine
