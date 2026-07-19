#include "inference.h"
#include "stream.h"
#include "quant.h"
#include "tokenizer.h"
#include "attention.h"
#include "tensor.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>

int inference_init(inference_state_t* state, const char* model_path) {
    if (!state || !model_path) return -1;
    memset(state, 0, sizeof(inference_state_t));
    strncpy(state->model_path, model_path, sizeof(state->model_path) - 1);
    state->loaded = 1;
    state->max_context = 512;
    state->num_layers = 1; /* Simplified: one layer for demo */
    state->model_dim = 64;
    return 0;
}

void inference_cleanup(inference_state_t* state) {
    if (!state) return;
    memset(state, 0, sizeof(inference_state_t));
}

int inference_load_layer_weights(const char* path,
                                   float* out_weights,
                                   int weight_count,
                                   int stream_chunk_size) {
    if (!path || !out_weights) return -1;
    stream_loader_t loader;
    if (stream_open(&loader, path, stream_chunk_size) != 0) return -1;

    int read_so_far = 0;
    while (read_so_far < weight_count) {
        int to_read = (weight_count - read_so_far) > 32 ? 32 : (weight_count - read_so_far);
        int actual = stream_read_floats(&loader, out_weights + read_so_far, to_read);
        if (actual <= 0) break;
        read_so_far += actual;
    }
    stream_close(&loader);
    return read_so_far;
}

int inference_forward(const int* input_ids,
                       int input_len,
                       float* output_logits,
                       int max_output_len,
                       inference_state_t* state) {
    if (!state || !state->loaded || !input_ids || !output_logits) return -1;
    if (input_len <= 0 || max_output_len <= 0) return -1;

    int model_dim = state->model_dim;
    int seq_len = input_len < state->max_context ? input_len : state->max_context;

    /* 1. Simple embedding via tokenizer mapping */
    float* embeddings = (float*)malloc(sizeof(float) * seq_len * model_dim);
    if (!embeddings) return -1;
    memset(embeddings, 0, sizeof(float) * seq_len * model_dim);
    for (int i = 0; i < seq_len; i++) {
        int token_val = (input_ids[i] >= 0 && input_ids[i] < 256) ? input_ids[i] : 0;
        float val = (float)token_val / 128.0f - 1.0f;
        for (int d = 0; d < model_dim; d++) {
            embeddings[i * model_dim + d] = val + (float)(d % 8) * 0.05f;
        }
    }

    /* 2. Self-attention layer */
    float* attn_out = (float*)malloc(sizeof(float) * seq_len * model_dim);
    if (!attn_out) {
        free(embeddings);
        return -1;
    }
    memset(attn_out, 0, sizeof(float) * seq_len * model_dim);
    self_attention_simple(embeddings, attn_out, seq_len, model_dim, model_dim / 4);

    /* 3. Project to output logits (simplified linear projection) */
    int output_size = 256; /* vocab size for demo */
    float* weights = (float*)malloc(sizeof(float) * model_dim * output_size);
    if (!weights) {
        free(embeddings);
        free(attn_out);
        return -1;
    }
    memset(weights, 0, sizeof(float) * model_dim * output_size);
    /* Initialize with small random-like weights for demo */
    for (int i = 0; i < model_dim * output_size; i++) {
        weights[i] = ((float)(i % 7) - 3.0f) * 0.02f;
    }

    float* projection = (float*)malloc(sizeof(float) * seq_len * output_size);
    if (!projection) {
        free(embeddings);
        free(attn_out);
        free(weights);
        return -1;
    }

    tensor_matmul(attn_out, seq_len, model_dim,
                  weights, model_dim, output_size,
                  projection);

    /* 4. Copy last token projection to output */
    int last_token_idx = seq_len - 1;
    int copy_size = (max_output_len < output_size) ? max_output_len : output_size;
    for (int i = 0; i < copy_size; i++) {
        output_logits[i] = projection[last_token_idx * output_size + i];
    }

    free(embeddings);
    free(attn_out);
    free(weights);
    free(projection);
    return 0;
}

int inference_sample_token(const float* logits, int logit_size) {
    if (!logits || logit_size <= 0) return 0;
    float max_val = logits[0];
    int max_idx = 0;
    for (int i = 1; i < logit_size; i++) {
        if (logits[i] > max_val) {
            max_val = logits[i];
            max_idx = i;
        }
    }
    return max_idx;
}
