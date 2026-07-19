#ifndef OTTER_CUDA_H
#define OTTER_CUDA_H

#include <stddef.h>

/* CUDA-accelerated matrix operations for the Otter engine */

/* Initialize CUDA context for the engine */
int cuda_init_context(void);

/* Release CUDA resources */
void cuda_release_context(void);

/* Matrix multiply using CUDA kernels: A(a_rows x a_k) * B(b_k x b_cols) -> C(a_rows x b_cols) */
int cuda_matmul(const float* a, int a_rows, int a_k,
                 const float* b, int b_k, int b_cols,
                 float* out);

/* Check if CUDA is available */
int cuda_is_available(void);

#endif
