#include "tokenizer.h"
#include <string.h>

int get_vocab_size(void) {
    return 256;
}

int tokenize_text(const char* text, int* out_ids, int max_ids) {
    if (!text || !out_ids) return 0;
    int len = 0;
    size_t str_len = strlen(text);
    for (size_t i = 0; i < str_len && len < max_ids; i++) {
        out_ids[len++] = (unsigned char)text[i];
    }
    return len;
}

int detokenize_ids(const int* ids, int count, char* out_text, int max_chars) {
    if (!ids || !out_text) return 0;
    int written = 0;
    for (int i = 0; i < count && written < max_chars - 1; i++) {
        out_text[written++] = (char)(ids[i] & 0xFF);
    }
    out_text[written] = '\0';
    return written;
}
