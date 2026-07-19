#include "attention.h"
#include "tensor.h"
#include <string.h>
#include <math.h>

void attention_forward(const float* Q,
                        const float* K,
                        const float* V,
                        float* out,
                        int seq_len,
                        int d_model,
                        int num_heads,
                        int head_dim) {
    int total_heads = num_heads * head_dim;
    float scores[256]; /* simplified: assume seq_len <= 256 for demo */

    for (int h = 0; h < num_heads; h++) {
        for (int i = 0; i < seq_len; i++) {
            float sum = 0.0f;
            for (int d = 0; d < head_dim; d++) {
                float q = Q[i * d_model + h * head_dim + d];
                float k = K[i * d_model + h * head_dim + d];
                sum += q * k;
            }
            float scale = 1.0f / sqrtf((float)head_dim);
            scores[i] = sum * scale;
        }

        /* Softmax over sequence dimension */
        for (int i = 0; i < seq_len; i++) {
            float max_s = scores[0];
            for (int j = 1; j < seq_len; j++) {
                if (scores[j] > max_s) max_s = scores[j];
            }
            float exp_sum = 0.0f;
            for (int j = 0; j < seq_len; j++) {
                scores[j] = expf(scores[j] - max_s);
                exp_sum += scores[j];
            }
            for (int j = 0; j < seq_len; j++) {
                scores[j] /= exp_sum;
            }

            /* Weighted sum of V */
            for (int d = 0; d < head_dim; d++) {
                float val = 0.0f;
                for (int j = 0; j < seq_len; j++) {
                    float v_weight = V[j * d_model + h * head_dim + d];
                    val += scores[j] * v_weight;
                }
                out[i * d_model + h * head_dim + d] = val;
            }
        }
    }
}

void self_attention_simple(const float* input,
                            float* output,
                            int seq_len,
                            int d_model,
                            int head_dim) {
    memset(output, 0, sizeof(float) * seq_len * d_model);
    attention_forward(input, input, input, output, seq_len, d_model, 1, head_dim);
}
