#ifndef ATTENTION_H
#define ATTENTION_H

#include <stddef.h>

/* Simplified multi-head attention for small context windows */
/* This is a functional but minimal implementation inspired by
   the architecture used in large models, scaled for demonstration. */

typedef struct {
    int num_heads;
    int head_dim;
    int context_size;
} attention_config_t;

/* Apply scaled dot-product attention: Q, K, V are float arrays */
/* Input dimensions: [seq_len, d_model] */
/* Output: [seq_len, d_model] */
void attention_forward(const float* Q,
                        const float* K,
                        const float* V,
                        float* out,
                        int seq_len,
                        int d_model,
                        int num_heads,
                        int head_dim);

/* Simplified self-attention: uses single head for demo */
void self_attention_simple(const float* input,
                            float* output,
                            int seq_len,
                            int d_model,
                            int head_dim);

#endif
