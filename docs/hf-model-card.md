# Qwen2.5-7B-Instruct — GGUF Quantization Study

This repository contains four GGUF quantizations of
[Qwen2.5-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-7B-Instruct),
created with [llama.cpp](https://github.com/ggml-org/llama.cpp).

The experiment compares K-Quants and I-Quants and measures the effect
of importance-matrix (imatrix) calibration.

## Quantized Models

| Variant | Size | BPW |
|---|---:|---:|
| Q4_K_M | 4.36 GiB | 4.91 |
| Q4_K_M + imatrix | 4.36 GiB | 4.91 |
| IQ4_XS | 3.95 GiB | 4.46 |
| IQ4_XS + imatrix | 3.92 GiB | 4.43 |

## Evaluation

### Held-out perplexity

| Variant | PPL |
|---|---:|
| Q4_K_M | 5.2194 ± 0.5684 |
| Q4_K_M + imatrix | 5.1698 ± 0.5643 |
| IQ4_XS | 5.4115 ± 0.6006 |
| IQ4_XS + imatrix | 5.3273 ± 0.5908 |

Lower is better.

### Generation throughput

Measured locally on an Apple Silicon M5 MacBook Pro with 16 GB
unified memory using llama.cpp and Metal.

| Variant | Generation tok/s |
|---|---:|
| Q4_K_M | 26.37 |
| Q4_K_M + imatrix | 26.20 |
| IQ4_XS | 28.60 |
| IQ4_XS + imatrix | 29.10 |

### Task evaluation

Six held-out tasks were evaluated for each model across coding,
mathematics, reasoning, and structured JSON generation.

| Variant | Score |
|---|---:|
| Q4_K_M | 18/18 |
| Q4_K_M + imatrix | 18/18 |
| IQ4_XS | 16/18 |
| IQ4_XS + imatrix | 17/18 |

## Key Findings

In this experiment:

- Q4_K_M produced the best measured perplexity and a perfect task score.
- Adding the imatrix slightly improved Q4_K_M perplexity without changing
  its nominal storage size.
- IQ4_XS reduced model size and delivered higher generation throughput,
  but showed a measurable quality trade-off.
- Adding the imatrix to IQ4_XS partially recovered the perplexity gap while
  retaining the smaller model size.
- The IQ4_XS + imatrix variant was the strongest size/quality/performance
  compromise observed in this experiment.

These findings are specific to this model, calibration corpus, hardware,
and evaluation methodology. They should not be interpreted as a universal
ranking of quantization formats.

## Calibration

A custom technical calibration corpus was created covering programming,
algorithms, mathematics, machine learning, LLMs, quantization, databases,
distributed systems, performance engineering, RAG, evaluation, and
reproducibility.

Approximately 13,000 tokens from this corpus were used to generate the
importance matrix because the full workload exceeded the available Metal
working set on the 16 GB system.

The importance matrix was generated using:

- Context: 512
- Batch size: 512
- Micro-batch size: 64
- GPU layers: 20

## Hardware

- Apple Silicon M5
- 16 GB unified memory
- macOS
- llama.cpp with Metal acceleration

## Usage

These GGUF files can be used with llama.cpp-compatible applications.

Example:

```bash
llama-cli \
  -m Qwen2.5-7B-Instruct-Q4_K_M.gguf \
  -ngl 99 \
  -c 2048

eof
tail -10 /tmp/hf-model-card.md

Replace the filename with any of the other quantized variants to compare
them.

## Reproducibility

The complete experiment documentation, calibration data, evaluation data,
scripts, and measured results are available in the companion GitHub
repository:

https://github.com/bigavloglive/qwen2.5-7b-quantization

The GitHub repository intentionally excludes the large GGUF files.

## Limitations

- The calibration corpus is custom rather than a standardized benchmark.
- Only approximately 13,000 calibration tokens were used for imatrix generation.
- The task evaluation contains only six prompts per model.
- Perplexity uncertainty intervals overlap.
- Throughput can vary with system state and caching.
- This study evaluates only approximately 4-bit quantization formats.
- Qwen2.5-7B-Instruct is instruction-tuned, so perplexity alone does not
  fully measure instruction-following quality.

## Base Model and License

The base model is:

Qwen/Qwen2.5-7B-Instruct

The original model is released under the Apache 2.0 license.

Please review the original model card and license for the applicable
terms and attribution requirements.

This repository contains quantized derivatives of the original model;
it does not claim ownership of the underlying Qwen model.

## Experiment Repository

GitHub:

https://github.com/bigavloglive/qwen2.5-7b-quantization
