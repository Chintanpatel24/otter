#include "quant.h"
#include <string.h>
#include <math.h>

int quant_read_scale(const uint8_t* data, int offset, float* scale) {
    if (!data || !scale) return -1;
    memcpy(scale, (const float*)(data + offset), sizeof(float));
    return 0;
}

int quant_dequantize_q4(const uint8_t* block, float* out, int count) {
    if (!block || !out || count <= 0) return -1;
    float scale = 0.0f;
    memcpy(&scale, block, sizeof(float));
    int offset = sizeof(float);
    for (int i = 0; i < count; i++) {
        int byte_idx = offset + i / 16;
        int sub_idx = (i % 16) / 8;
        uint8_t byte = block[byte_idx];
        int nibble = (sub_idx == 0) ? ((byte >> 4) & 0xF) : (byte & 0xF);
        float weight = ((float)(nibble) - 8.0f) * scale;
        out[i] = weight;
    }
    return count;
}

int quant_dequantize_q5(const uint8_t* block, float* out, int count) {
    if (!block || !out || count <= 0) return -1;
    float scale = 0.0f;
    memcpy(&scale, block, sizeof(float));
    int offset = sizeof(float);
    for (int i = 0; i < count; i++) {
        int byte_idx = offset + i / 4;
        int shift = (i % 4) * 2;
        uint8_t byte = block[byte_idx];
        int value = (byte >> shift) & 0x3;
        float weight = ((float)value - 1.5f) * scale;
        out[i] = weight;
    }
    return count;
}
