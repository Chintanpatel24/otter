#include <stdio.h>
#include <string.h>
#include "inference.h"
#include "tokenizer.h"

int main(int argc, char** argv) {
    printf("Pure Local Host Engine v0.1.0\n");
    printf("Inspired by Colibri architecture: pure C, disk streaming, zero deps\n");

    const char* model_path = (argc > 1) ? argv[1] : "model.gguf";

    inference_state_t state;
    if (inference_init(&state, model_path) != 0) {
        printf("Failed to initialize inference state.\n");
        return 1;
    }

    printf("Engine initialized. Path: %s\n", state.model_path);
    printf("Max context: %d, Model dim: %d, Layers: %d\n",
           state.max_context, state.model_dim, state.num_layers);

    /* Demonstration: tokenize a simple prompt */
    const char* prompt = "Hello local engine";
    int ids[64];
    int id_count = tokenize_text(prompt, ids, 64);
    printf("Tokenized prompt (%d tokens): ", id_count);
    for (int i = 0; i < id_count; i++) {
        printf("%d ", ids[i]);
    }
    printf("\n");

    /* Demonstration: run forward pass */
    float logits[256];
    memset(logits, 0, sizeof(float) * 256);
    int result = inference_forward(ids, id_count, logits, 256, &state);
    if (result == 0) {
        printf("Forward pass completed. Sample output tokens:\n");
        int best_token = inference_sample_token(logits, 256);
        char text_buf[256];
        int best_ids[1] = {best_token};
        detokenize_ids(best_ids, 1, text_buf, sizeof(text_buf));
        printf("Predicted token: %d (char: %c)\n", best_token, text_buf[0]);
    } else {
        printf("Forward pass failed.\n");
    }

    /* Demonstration: load weights from a file (if exists) */
    float test_weights[64];
    int loaded = inference_load_layer_weights(model_path, test_weights, 64, 1024);
    printf("Weight stream test: loaded %d floats from %s\n", loaded, model_path);

    inference_cleanup(&state);
    printf("Engine shut down cleanly.\n");
    return 0;
}
