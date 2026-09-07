#!/bin/bash
set -e

LLAMA_CPP="$HOME/llama.cpp/build/bin"
MODEL_DIR="$HOME/llm-quantization-project/models"
EVAL="$HOME/llm-quantization-project/calibration/eval.txt"

MODELS=(
  "Qwen2.5-7B-Instruct-Q4_K_M.gguf"
  "Qwen2.5-7B-Instruct-Q4_K_M-imatrix.gguf"
  "Qwen2.5-7B-Instruct-IQ4_XS.gguf"
  "Qwen2.5-7B-Instruct-IQ4_XS-imatrix.gguf"
)

for MODEL in "${MODELS[@]}"; do
  echo "========================================"
  echo "Evaluating: $MODEL"
  echo "========================================"

  "$LLAMA_CPP/llama-perplexity" \
    -m "$MODEL_DIR/$MODEL" \
    -f "$EVAL" \
    -ngl 99 \
    -c 2048
done
