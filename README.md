# Quantization Trade-offs in Qwen2.5-7B-Instruct

A practical experiment comparing **K-Quants vs. I-Quants** in `llama.cpp`, with and without **imatrix calibration**, on Apple Silicon.

## Experiment Summary

- Model: **Qwen2.5-7B-Instruct**
- Base format: BF16
- Quantization framework: `llama.cpp`
- Hardware: Apple Silicon M5, 16 GB unified memory
- GPU backend: Metal
- Calibration corpus: 801 lines / ~68K tokens
- Held-out evaluation corpus: 180 prompts / ~39K tokens
- Task evaluation: 6 tasks per model

Variants:
1. `Q4_K_M`
2. `Q4_K_M + imatrix`
3. `IQ4_XS`
4. `IQ4_XS + imatrix`

## Results

### Model Size and Quantization Cost

| Model | Quantized size | BPW | Quantization time |
|---|---:|---:|---:|
| Q4_K_M | 4.36 GiB | 4.91 | 33.0 s |
| Q4_K_M + imatrix | 4.36 GiB | 4.91 | 48.5 s |
| IQ4_XS | 3.95 GiB | 4.46 | 91.6 s |
| IQ4_XS + imatrix | 3.92 GiB | 4.43 | 93.1 s |

IQ4_XS was approximately **10% smaller** than Q4_K_M.

### Held-Out Perplexity

| Model | PPL | Change vs Q4_K_M |
|---|---:|---:|
| **Q4_K_M** | **5.2194 ± 0.5684** | baseline |
| **Q4_K_M + imatrix** | **5.1698 ± 0.5643** | **-0.95%** |
| **IQ4_XS** | **5.4115 ± 0.6006** | **+3.68%** |
| **IQ4_XS + imatrix** | **5.3273 ± 0.5908** | **+2.07%** |

Imatrix improved measured perplexity for both formats. For IQ4_XS, PPL improved from 5.4115 to 5.3273 (~1.56%).

These are observed results from this setup, not statistically definitive differences; the uncertainty ranges overlap.

### Generation Throughput

Three runs were averaged for each model.

| Model | Avg. generation |
|---|---:|
| Q4_K_M | 26.37 tok/s |
| Q4_K_M + imatrix | 26.20 tok/s |
| IQ4_XS | **28.60 tok/s** |
| IQ4_XS + imatrix | **29.10 tok/s** |

IQ4_XS generated approximately **8.5% more tokens/sec** than Q4_K_M while using approximately 10% less storage.

The benchmark should not be interpreted as evidence that imatrix itself makes inference faster; the small differences between imatrix and non-imatrix runs can vary with system state.

### Task-Based Quality

Six tasks were used per model: 2 coding, 1 math, 1 reasoning, and 2 structured JSON tasks.

| Model | Score | Accuracy |
|---|---:|---:|
| **Q4_K_M** | **18/18** | **100%** |
| **Q4_K_M + imatrix** | **18/18** | **100%** |
| IQ4_XS | **16/18** | **88.9%** |
| IQ4_XS + imatrix | **17/18** | **94.4%** |

The IQ4_XS result improved from **16/18 to 17/18** after imatrix calibration.

## Overall Takeaway

**Q4_K_M** delivered the best measured perplexity and perfect performance on the small task suite, making it the strongest quality-oriented choice in this experiment.

**IQ4_XS** produced a smaller model with higher generation throughput, but initially lost some quality.

**IQ4_XS + imatrix** recovered part of that quality gap while retaining the size and throughput advantages of IQ4_XS. In this experiment, it represents the most interesting **efficiency/quality compromise**.

The key observation is that **imatrix calibration improved measured perplexity across both quantization families**, with a more visible quality recovery for IQ4_XS.

## Methodology

### Calibration

A custom calibration corpus covered Python/algorithms, data structures, math/statistics, ML, transformers/LLMs, quantization, GGUF/llama.cpp, databases, APIs/security, distributed systems, testing, performance, RAG, evaluation, experiment design, and reproducibility.

Because the BF16 model exceeded the available Metal working-set budget under aggressive GPU offload, imatrix generation used reduced GPU layers and smaller batches:

```bash
llama-imatrix \
  -m Qwen2.5-7B-Instruct-BF16.gguf \
  -f calibration-10k.txt \
  -o qwen2.5-7b-imatrix.gguf \
  -ngl 20 \
  -c 512 \
  -b 512 \
  -ub 64
```

The calibration subset contained ~13K tokens.

### Quantization

Baseline:

```bash
llama-quantize Qwen2.5-7B-Instruct-BF16.gguf \
  Qwen2.5-7B-Instruct-Q4_K_M.gguf Q4_K_M
```

With imatrix:

```bash
llama-quantize --imatrix qwen2.5-7b-imatrix.gguf \
  Qwen2.5-7B-Instruct-BF16.gguf \
  Qwen2.5-7B-Instruct-Q4_K_M-imatrix.gguf Q4_K_M
```

I-Quant:

```bash
llama-quantize Qwen2.5-7B-Instruct-BF16.gguf \
  Qwen2.5-7B-Instruct-IQ4_XS.gguf IQ4_XS
```

I-Quant with imatrix used the same `--imatrix` option and `IQ4_XS` output type.

### Evaluation

Perplexity used a separate held-out evaluation corpus so that evaluation text was not the same text used to build the imatrix.

Inference throughput used three runs per model with the same configuration.

The task suite used the exact same six prompts for every model and was manually scored for correctness and instruction adherence.

## Limitations

1. The calibration corpus is custom-built rather than a large standardized dataset.
2. Only six task prompts were used for qualitative evaluation.
3. Perplexity was measured on synthetic/domain-oriented text rather than a broad standardized benchmark.
4. Qwen2.5-7B-Instruct is instruction-tuned, so plain-text perplexity does not fully capture instruction-following quality.
5. Throughput was measured on one Apple Silicon system and can vary with system state.
6. The imatrix calibration subset was deliberately kept small to keep the project free and fast.
7. PPL uncertainty ranges overlap, so small differences should not be overinterpreted.

## Portfolio Resume Bullet

> Quantized Qwen2.5-7B-Instruct to GGUF using llama.cpp, generated activation-based importance-matrix calibration data, and benchmarked K-Quant vs I-Quant variants across model size, perplexity, inference throughput, and coding/math/structured-output tasks; demonstrated measurable perplexity recovery from imatrix calibration at lower bitrates.

## Future Work

- Add Q5_K_M and Q6_K as higher-quality reference points.
- Add IQ3_M to explore lower-bit I-Quant behavior.
- Use a larger standardized calibration corpus.
- Expand task evaluation to dozens or hundreds of prompts.
- Automate code execution and JSON-validity scoring.
- Measure prompt-processing throughput more systematically.
- Measure memory usage and peak Metal allocation.
- Publish GGUF models to Hugging Face.
- Publish scripts, raw measurements, and analysis to GitHub.
