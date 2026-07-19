#include "tensor.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

int tensor_init(tensor_t* t, int ndim, const size_t* dims) {
    if (!t || ndim < 1 || ndim > 4) return -1;
    t->ndim = ndim;
    t->count = 1;
    for (int i = 0; i < ndim; i++) {
        t->dims[i] = dims[i];
        t->count *= dims[i];
    }
    t->data = (float*)malloc(sizeof(float) * t->count);
    return (t->data) ? 0 : -1;
}

void tensor_free(tensor_t* t) {
    if (t && t->data) {
        free(t->data);
        t->data = NULL;
    }
    t->count = 0;
    t->ndim = 0;
    memset(t->dims, 0, sizeof(t->dims));
}

void tensor_zero(tensor_t* t) {
    if (t && t->data) {
        memset(t->data, 0, sizeof(float) * t->count);
    }
}

void tensor_fill(tensor_t* t, float val) {
    if (!t || !t->data) return;
    for (size_t i = 0; i < t->count; i++) {
        t->data[i] = val;
    }
}

int tensor_matmul(const float* a, int a_rows, int a_k,
                   const float* b, int b_k, int b_cols,
                   float* out) {
    if (a_k != b_k) return -1;
    for (int i = 0; i < a_rows; i++) {
        for (int j = 0; j < b_cols; j++) {
            float sum = 0.0f;
            for (int k = 0; k < a_k; k++) {
                sum += a[i * a_k + k] * b[k * b_cols + j];
            }
            out[i * b_cols + j] = sum;
        }
    }
    return 0;
}

void tensor_softmax(float* data, int rows, int cols) {
    for (int r = 0; r < rows; r++) {
        float max_val = -1e30f;
        for (int c = 0; c < cols; c++) {
            float v = data[r * cols + c];
            if (v > max_val) max_val = v;
        }
        float sum = 0.0f;
        for (int c = 0; c < cols; c++) {
            float v = expf(data[r * cols + c] - max_val);
            data[r * cols + c] = v;
            sum += v;
        }
        for (int c = 0; c < cols; c++) {
            data[r * cols + c] /= sum;
        }
    }
}
