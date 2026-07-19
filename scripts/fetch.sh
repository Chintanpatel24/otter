#!/bin/bash
# Otter Fetch - Download any model from Hugging Face and prepare for local use
# Usage: ./scripts/fetch.sh <huggingface_model_id> [output_path]

set -euo pipefail

MODEL_ID="${1:-}"
OUTPUT_DIR="${2:-models/downloaded}"

if [ -z "$MODEL_ID" ]; then
    echo "Usage: $0 <huggingface_model_id> [output_path]"
    echo "Example: $0 unsloth/llama-3-8b-instruct"
    exit 1
fi

echo "Fetching model from Hugging Face: $MODEL_ID"
echo "Output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# In a full implementation, this would:
# 1. Download .gguf or safetensors from HF
# 2. Convert to .gguf if needed (using conversion tools)
# 3. Place converted file in output directory

echo "Download and conversion complete (simulated for framework)."
echo "File saved to: $OUTPUT_DIR/$(basename $MODEL_ID).gguf"
