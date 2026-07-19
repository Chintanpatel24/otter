#ifndef TENSOR_H
#define TENSOR_H

#include <stddef.h>
#include <stdint.h>

typedef struct {
    float* data;
    size_t dims[4];   // batch, seq, rows, cols (max 4 dims)
    int ndim;
    size_t count;
} tensor_t;

/* Initialize tensor with given dimensions */
int tensor_init(tensor_t* t, int ndim, const size_t* dims);
void tensor_free(tensor_t* t);

/* Zero all elements */
void tensor_zero(tensor_t* t);

/* Fill with scalar */
void tensor_fill(tensor_t* t, float val);

/* Simple matrix multiply: A(rows x k) * B(k x cols) -> out(rows x cols) */
int tensor_matmul(const float* a, int a_rows, int a_k,
                   const float* b, int b_k, int b_cols,
                   float* out);

/* Softmax across last dimension */
void tensor_softmax(float* data, int rows, int cols);

#endif
