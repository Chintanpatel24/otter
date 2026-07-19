#ifndef QUANT_H
#define QUANT_H

#include <stdint.h>
#include <stddef.h>

/* Dequantize Q4_K block: 2 bits per weight, scale as float */
/* Simplified version: reads 32 weights + 1 scale */
int quant_dequantize_q4(const uint8_t* block, float* out, int count);

/* Dequantize Q5_K simplified */
int quant_dequantize_q5(const uint8_t* block, float* out, int count);

/* Read scale and weights from GGUF tensor data chunk */
int quant_read_scale(const uint8_t* data, int offset, float* scale);

#endif
