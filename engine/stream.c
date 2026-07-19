#include "stream.h"
#include <stdlib.h>

int stream_open(stream_loader_t* s, const char* path, size_t chunk_size) {
    if (!s || !path) return -1;
    s->file = fopen(path, "rb");
    if (!s->file) return -1;
    s->path = path;
    s->chunk_size = chunk_size > 0 ? chunk_size : 4096;
    fseek(s->file, 0, SEEK_END);
    s->file_size = ftell(s->file);
    fseek(s->file, 0, SEEK_SET);
    s->offset = 0;
    return 0;
}

void stream_close(stream_loader_t* s) {
    if (s && s->file) {
        fclose(s->file);
        s->file = NULL;
    }
    s->file_size = 0;
    s->offset = 0;
    s->chunk_size = 4096;
}

size_t stream_read_chunk(stream_loader_t* s, void* buffer, size_t max_bytes) {
    if (!s || !s->file || !buffer) return 0;
    size_t to_read = max_bytes < s->chunk_size ? max_bytes : s->chunk_size;
    if (s->offset + to_read > (size_t)s->file_size) {
        to_read = (size_t)s->file_size - s->offset;
    }
    if (to_read == 0) return 0;
    size_t read = fread(buffer, 1, to_read, s->file);
    s->offset += read;
    return read;
}

int stream_seek(stream_loader_t* s, size_t offset) {
    if (!s || !s->file) return -1;
    if (fseek(s->file, (long)offset, SEEK_SET) != 0) return -1;
    s->offset = offset;
    return 0;
}

size_t stream_tell(stream_loader_t* s) {
    return (s) ? s->offset : 0;
}

int stream_read_floats(stream_loader_t* s, float* out, int count) {
    if (!s || !s->file || !out) return 0;
    size_t bytes_to_read = (size_t)count * sizeof(float);
    size_t read = fread(out, sizeof(float), (size_t)count, s->file);
    s->offset += read * sizeof(float);
    return (int)read;
}
