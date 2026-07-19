#ifndef INFERENCE_H
#define INFERENCE_H

#include <stddef.h>

/* Main inference engine: connects stream loader, quantization,
   tensor operations, attention, and token generation */

typedef struct {
    int loaded;
    char model_path[512];
    int max_context;
    int num_layers;
    int model_dim;
} inference_state_t;

/* Initialize engine with model file path */
int inference_init(inference_state_t* state, const char* model_path);

/* Load weights for a single layer from disk stream */
int inference_load_layer_weights(const char* path,
                                   float* out_weights,
                                   int weight_count,
                                   int stream_chunk_size);

/* Run one forward pass: input_ids -> output_logits */
/* This is a simplified but functional pass through the model */
int inference_forward(const int* input_ids,
                       int input_len,
                       float* output_logits,
                       int max_output_len,
                       inference_state_t* state);

/* Generate next token: basic greedy sampling */
int inference_sample_token(const float* logits, int logit_size);

/* Clean up engine */
void inference_cleanup(inference_state_t* state);

#endif
