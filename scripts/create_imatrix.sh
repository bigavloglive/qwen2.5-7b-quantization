#!/bin/bash
set -e

LLAMA_CPP="$HOME/llama.cpp/build/bin"
MODEL="$HOME/llm-quantization-project/models/Qwen2.5-7B-Instruct-BF16.gguf"
CALIBRATION="$HOME/llm-quantization-project/calibration/calibration-10k.txt"
OUTPUT="$HOME/llm-quantization-project/calibration/qwen2.5-7b-imatrix.gguf"

echo "Creating importance matrix..."

"$LLAMA_CPP/llama-imatrix" \
  -m "$MODEL" \
  -f "$CALIBRATION" \
  -o "$OUTPUT" \
  -ngl 20 \
  -c 512 \
  -b 512 \
  -ub 64

echo "Importance matrix created:"
ls -lh "$OUTPUT"
