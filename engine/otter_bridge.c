#include "otter_bridge.h"
#include "inference.h"
#include "tokenizer.h"
#include <string.h>

/* Binary compatibility: otter_engine_t matches Rust OtterEngineState */

int otter_init(otter_engine_t* state, const char* path) {
    if (!state || !path) return -1;
    memset(state, 0, sizeof(otter_engine_t));
    strncpy(state->path, path, sizeof(state->path) - 1);
    state->loaded = 1;
    state->max_ctx = 512;
    state->layers = 1;
    state->dim = 64;
    return inference_init((inference_state_t*)state, path);
}

void otter_cleanup(otter_engine_t* state) {
    if (state) {
        inference_cleanup((inference_state_t*)state);
        memset(state, 0, sizeof(otter_engine_t));
    }
}

int otter_forward(const int* ids, int len, float* logits, int max_len, otter_engine_t* state) {
    return inference_forward(ids, len, logits, max_len, (inference_state_t*)state);
}

int otter_sample(const float* logits, int size) {
    return inference_sample_token(logits, size);
}

int otter_tokenize(const char* text, int* out, int max_out) {
    return tokenize_text(text, out, max_out);
}

int otter_detokenize(const int* ids, int count, char* text, int max_text) {
    return detokenize_ids(ids, count, text, max_text);
}
