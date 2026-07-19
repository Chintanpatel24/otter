#ifndef STREAM_H
#define STREAM_H

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

typedef struct {
    FILE* file;
    const char* path;
    size_t file_size;
    size_t offset;
    size_t chunk_size;
} stream_loader_t;

/* Open file for streaming reads */
int stream_open(stream_loader_t* s, const char* path, size_t chunk_size);
void stream_close(stream_loader_t* s);

/* Read next chunk into buffer (returns bytes read) */
size_t stream_read_chunk(stream_loader_t* s, void* buffer, size_t max_bytes);

/* Seek to absolute offset */
int stream_seek(stream_loader_t* s, size_t offset);

/* Get current position */
size_t stream_tell(stream_loader_t* s);

/* Read float weights from current position, return count */
int stream_read_floats(stream_loader_t* s, float* out, int count);

#endif
