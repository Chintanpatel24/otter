#ifndef OTTER_BRIDGE_H
#define OTTER_BRIDGE_H

#include <stddef.h>

/* Bridge layer: exposes engine internals using the otter_ naming convention */

typedef struct {
    int loaded;
    char path[512];
    int max_ctx;
    int layers;
    int dim;
} otter_engine_t;

int otter_init(otter_engine_t* state, const char* path);
void otter_cleanup(otter_engine_t* state);
int otter_forward(const int* ids, int len, float* logits, int max_len, otter_engine_t* state);
int otter_sample(const float* logits, int size);
int otter_tokenize(const char* text, int* out, int max_out);
int otter_detokenize(const int* ids, int count, char* text, int max_text);

#endif
