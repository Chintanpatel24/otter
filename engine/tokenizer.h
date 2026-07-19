#ifndef TOKENIZER_H
#define TOKENIZER_H

#include <stddef.h>

/* Minimal byte-level tokenizer inspired by basic encoding schemes */
/* Maps bytes directly to integer IDs for demonstration */
int tokenize_text(const char* text, int* out_ids, int max_ids);
int detokenize_ids(const int* ids, int count, char* out_text, int max_chars);
int get_vocab_size(void);

#endif
