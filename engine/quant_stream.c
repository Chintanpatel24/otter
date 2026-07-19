/* Quantized streaming loader - streams quantized weights without full RAM load */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STREAM_CHUNK 4096

int quant_stream_load(const char* path, float* out_buffer, int max_weights) {
    FILE* f = fopen(path, "rb");
    if (!f) return -1;
    int count = 0;
    char chunk[STREAM_CHUNK];
    size_t read = 0;
    while ((read = fread(chunk, 1, STREAM_CHUNK, f)) > 0 && count < max_weights) {
        int to_process = (int)read / 2; /* Simplified quant dequant per chunk */
        for (int i = 0; i < to_process && count < max_weights; i++) {
            out_buffer[count++] = ((float)(unsigned char)chunk[i]) / 255.0f;
        }
    }
    fclose(f);
    return count;
}
