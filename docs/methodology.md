# Methodology

## Model

- Model: Qwen2.5-7B-Instruct
- Source: Qwen/Qwen2.5-7B-Instruct
- License: Apache 2.0
- Original format: BF16
- Converted format: GGUF

## Hardware and Software

- Hardware: Apple MacBook Pro with Apple Silicon M5
- Unified memory: 16 GB
- Backend: llama.cpp with Metal
- llama.cpp version: 0.4.0-dev
- Build: Release with GGML_METAL=ON
- Platform: macOS / arm64

## Quantization Variants

Four variants were evaluated:

1. Q4_K_M
2. Q4_K_M + imatrix
3. IQ4_XS
4. IQ4_XS + imatrix

The goal was to compare a conventional K-Quant format with an I-Quant format, and then measure the effect of importance-matrix calibration on each.

## Calibration Corpus

The calibration corpus was a custom technical dataset covering topics including:

- Programming and algorithms
- Data structures
- Mathematics and statistics
- Machine learning
- Transformers and LLMs
- Quantization
- GGUF and llama.cpp
- Python and SQL
- Databases and data pipelines
- APIs and security
- Distributed systems
- Containers and Kubernetes
- Performance engineering
- Testing
- RAG and evaluation
- Experiment design
- Reproducibility

The main calibration source contained approximately 68,000 tokens.

For imatrix generation on the 16 GB Apple Silicon system, a smaller approximately 13,000-token subset was used because the full calibration workload exceeded the available Metal working set.

## Imatrix Generation

The importance matrix was generated with llama-imatrix using:

- Context size: 512
- Batch size: 512
- Micro-batch size: 64
- GPU layers: 20

The resulting imatrix was approximately 4.3 MB.

## Quantization

All four variants were generated from the same BF16 GGUF source model.

Representative commands:

```bash
# Q4_K_M
llama-quantize \
  Qwen2.5-7B-Instruct-BF16.gguf \
  Qwen2.5-7B-Instruct-Q4_K_M.gguf \
  Q4_K_M

# Q4_K_M + imatrix
llama-quantize \
  --imatrix qwen2.5-7b-imatrix.gguf \
  Qwen2.5-7B-Instruct-BF16.gguf \
  Qwen2.5-7B-Instruct-Q4_K_M-imatrix.gguf \
  Q4_K_M

# IQ4_XS
llama-quantize \
  Qwen2.5-7B-Instruct-BF16.gguf \
  Qwen2.5-7B-Instruct-IQ4_XS.gguf \
  IQ4_XS

# IQ4_XS + imatrix
llama-quantize \
  --imatrix qwen2.5-7b-imatrix.gguf \
  Qwen2.5-7B-Instruct-BF16.gguf \
  Qwen2.5-7B-Instruct-IQ4_XS-imatrix.gguf \
  IQ4_XS

