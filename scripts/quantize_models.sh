#!/bin/bash
set -e

LLAMA_CPP="$HOME/llama.cpp/build/bin"
MODEL_DIR="$HOME/llm-quantization-project/models"
IMATRIX="$HOME/llm-quantization-project/calibration/qwen2.5-7b-imatrix.gguf"

BF16="$MODEL_DIR/Qwen2.5-7B-Instruct-BF16.gguf"

echo "Quantizing Q4_K_M..."
"$LLAMA_CPP/llama-quantize" \
  "$BF16" \
  "$MODEL_DIR/Qwen2.5-7B-Instruct-Q4_K_M.gguf" \
  Q4_K_M

echo "Quantizing Q4_K_M + imatrix..."
"$LLAMA_CPP/llama-quantize" \
  --imatrix "$IMATRIX" \
  "$BF16" \
  "$MODEL_DIR/Qwen2.5-7B-Instruct-Q4_K_M-imatrix.gguf" \
  Q4_K_M

echo "Quantizing IQ4_XS..."
"$LLAMA_CPP/llama-quantize" \
  "$BF16" \
  "$MODEL_DIR/Qwen2.5-7B-Instruct-IQ4_XS.gguf" \
  IQ4_XS

echo "Quantizing IQ4_XS + imatrix..."
"$LLAMA_CPP/llama-quantize" \
  --imatrix "$IMATRIX" \
  "$BF16" \
  "$MODEL_DIR/Qwen2.5-7B-Instruct-IQ4_XS-imatrix.gguf" \
  IQ4_XS

echo "All quantization jobs completed."
