#!/bin/bash
set -e

LLAMA_CPP="$HOME/llama.cpp/build/bin"
MODEL_DIR="$HOME/llm-quantization-project/models"

PROMPT="Explain the difference between K-Quants and I-Quants in llama.cpp, and explain what an importance matrix contributes to quantization."

MODELS=(
  "Qwen2.5-7B-Instruct-Q4_K_M.gguf"
  "Qwen2.5-7B-Instruct-Q4_K_M-imatrix.gguf"
  "Qwen2.5-7B-Instruct-IQ4_XS.gguf"
  "Qwen2.5-7B-Instruct-IQ4_XS-imatrix.gguf"
)

for MODEL in "${MODELS[@]}"; do
  echo "========================================"
  echo "Benchmarking: $MODEL"
  echo "========================================"

  for RUN in 1 2 3; do
    echo "--- Run $RUN ---"

    "$LLAMA_CPP/llama-cli" \
      --single-turn \
      --no-display-prompt \
      -m "$MODEL_DIR/$MODEL" \
      -ngl 99 \
      -c 2048 \
      -n 512 \
      -p "$PROMPT"
  done
done
