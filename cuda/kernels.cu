#include "otter_cuda.h"
#include <cuda_runtime.h>
#include <stdio.h>

__global__ void matmul_kernel(const float* A, const float* B, float* C,
                               int M, int K, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < M && col < N) {
        float sum = 0.0f;
        for (int k = 0; k < K; k++) {
            sum += A[row * K + k] * B[k * N + col];
        }
        C[row * N + col] = sum;
    }
}

int cuda_is_available(void) {
    int count = 0;
    cudaError_t err = cudaGetDeviceCount(&count);
    return (err == cudaSuccess && count > 0) ? 1 : 0;
}

int cuda_init_context(void) {
    if (!cuda_is_available()) return -1;
    cudaSetDevice(0);
    return 0;
}

void cuda_release_context(void) {
    cudaDeviceReset();
}

int cuda_matmul(const float* a, int a_rows, int a_k,
                 const float* b, int b_k, int b_cols,
                 float* out) {
    if (a_k != b_k) return -1;
    float *d_a = NULL, *d_b = NULL, *d_c = NULL;
    size_t size_a = sizeof(float) * a_rows * a_k;
    size_t size_b = sizeof(float) * b_k * b_cols;
    size_t size_c = sizeof(float) * a_rows * b_cols;

    cudaMalloc(&d_a, size_a);
    cudaMalloc(&d_b, size_b);
    cudaMalloc(&d_c, size_c);

    cudaMemcpy(d_a, a, size_a, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size_b, cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((b_cols + threadsPerBlock.x - 1) / threadsPerBlock.x,
                    (a_rows + threadsPerBlock.y - 1) / threadsPerBlock.y);

    matmul_kernel<<<numBlocks, threadsPerBlock>>>(d_a, d_b, d_c, a_rows, a_k, b_cols);

    cudaMemcpy(out, d_c, size_c, cudaMemcpyDeviceToHost);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    return 0;
}
