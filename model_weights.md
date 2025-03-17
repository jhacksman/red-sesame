# Sesame CSM-1B Model Weights

The Sesame CSM-1B model weights are hosted on Hugging Face and are required to use the model. This document provides information on the model weight files and how to access them.

## Model Weight Files

All model files from [https://huggingface.co/sesame/csm-1b](https://huggingface.co/sesame/csm-1b) are now included in this repository:

### Main Directory Files

| File | Size | Description |
|------|------|-------------|
| ckpt.pt | 6.22 GB | PyTorch checkpoint file containing the model weights |
| model.safetensors | 6.21 GB | SafeTensors format of the model weights (more secure alternative to PyTorch format) |
| config.json | 155 Bytes | Configuration file for the model |
| README.md | 4.16 KB | Original documentation from Hugging Face |
| .gitattributes | 121 Bytes | Git attributes file |

### Prompts Directory Files

The `prompts` directory contains audio samples that can be used for testing and as context for the model:

| File | Size | Description |
|------|------|-------------|
| conversational_a.wav | 2.65 MB | Conversational speech sample for speaker A |
| conversational_b.wav | 2.65 MB | Conversational speech sample for speaker B |
| read_speech_a.wav | 831 KB | Read speech sample, variant A |
| read_speech_b.wav | 576 KB | Read speech sample, variant B |
| read_speech_c.wav | 386 KB | Read speech sample, variant C |
| read_speech_d.wav | 436 KB | Read speech sample, variant D |

## Using the Included Model Weights

All model weights and files are now included in this repository with the exact same directory structure as the original Hugging Face repository. This means:

1. You don't need to download the weights separately
2. The code will work with the local files without modification
3. Security analysis can be performed on the complete model

If you want to access the original source or get updates, you can visit the Hugging Face repository:

1. Visit [https://huggingface.co/sesame/csm-1b](https://huggingface.co/sesame/csm-1b)
2. Click "Accept conditions to access this model" and review the terms
3. Log in to your Hugging Face account if prompted

### Local Access

Since all model weights are now included in this repository, you can use them directly without downloading from Hugging Face. The `generator.py` file has been modified to use the local weights:

```python
def load_csm_1b(device: str = "cuda") -> Generator:
    # Load model from local files instead of downloading from Hugging Face
    # This uses the local ckpt.pt or model.safetensors file
    model = Model.from_local("./")
    model.to(device=device, dtype=torch.bfloat16)

    generator = Generator(model)
    return generator
```

This modification ensures that:
1. No network access is required to use the model
2. The model works consistently in air-gapped environments
3. Security analysis can be performed without external dependencies
4. The exact version of the model used for analysis is preserved

### Prompts Directory Usage

The audio files in the `prompts` directory can be used as context for the model. For example:

```python
# Load a prompt file from the prompts directory
audio_tensor, sample_rate = torchaudio.load("prompts/conversational_a.wav")
audio_tensor = torchaudio.functional.resample(
    audio_tensor.squeeze(0), orig_freq=sample_rate, new_freq=generator.sample_rate
)

# Create a segment with the audio
segment = Segment(
    text="Hey how are you doing.",
    speaker=0,
    audio=audio_tensor
)

# Generate a response with this context
audio = generator.generate(
    text="I'm doing well, thanks for asking!",
    speaker=1,
    context=[segment],
    max_audio_length_ms=10_000,
)
```

These prompt files provide examples of different speech styles and can help the model generate more contextually appropriate responses.

## Using the Model Weights

The model weights are automatically loaded by the `load_csm_1b()` function in `generator.py`:

```python
def load_csm_1b(device: str = "cuda") -> Generator:
    model = Model.from_pretrained("sesame/csm-1b")
    model.to(device=device, dtype=torch.bfloat16)

    generator = Generator(model)
    return generator
```

This function:
1. Downloads the model weights from Hugging Face if they're not already cached locally
2. Loads the model onto the specified device (CUDA by default)
3. Returns a Generator instance that can be used to generate audio

## Storage Location

When downloaded through the Hugging Face Hub library, the model weights are cached in:
- Linux: `~/.cache/huggingface/hub/`
- Windows: `C:\Users\<username>\.cache\huggingface\hub\`
- macOS: `~/Library/Caches/huggingface/hub/`

## Security Considerations

The model weights are large files that contain the learned parameters of the model. While they don't contain any training data directly, they encapsulate patterns learned from the training data. When conducting security analysis, consider:

1. The model's capability to generate realistic speech that could potentially be misused
2. The watermarking functionality that helps identify AI-generated content
3. The model's limitations in non-English languages and specific voice mimicry

For security testing purposes, having local access to these weights is essential to analyze the model's behavior and potential vulnerabilities.
