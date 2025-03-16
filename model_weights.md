# Sesame CSM-1B Model Weights

The Sesame CSM-1B model weights are hosted on Hugging Face and are required to use the model. This document provides information on the model weight files and how to access them.

## Model Weight Files

The model weights are available at [https://huggingface.co/sesame/csm-1b](https://huggingface.co/sesame/csm-1b) and include:

| File | Size | Description |
|------|------|-------------|
| ckpt.pt | 6.22 GB | PyTorch checkpoint file containing the model weights |
| model.safetensors | 6.21 GB | SafeTensors format of the model weights (more secure alternative to PyTorch format) |
| config.json | 155 Bytes | Configuration file for the model |
| prompts/ | - | Directory containing prompt templates |
| README.md | 4.16 KB | Documentation for the model |
| .gitattributes | 1.9 KB | Git attributes file |

## Accessing the Model Weights

The model weights are publicly accessible but require accepting the terms and conditions on Hugging Face. To access them:

1. Visit [https://huggingface.co/sesame/csm-1b](https://huggingface.co/sesame/csm-1b)
2. Click "Accept conditions to access this model" and review the terms
3. Log in to your Hugging Face account if prompted

### Programmatic Access

The model code is designed to download the weights automatically when you call `load_csm_1b()`. This requires:

1. Installing the Hugging Face Hub library:
   ```bash
   pip install huggingface_hub
   ```

2. Logging in to Hugging Face:
   ```bash
   huggingface-cli login
   ```

3. When prompted, enter your Hugging Face token (found in your Hugging Face account settings)

### Manual Download

If you prefer to download the weights manually:

1. Navigate to [https://huggingface.co/sesame/csm-1b/tree/main](https://huggingface.co/sesame/csm-1b/tree/main)
2. Click on the file you want to download
3. Click the download button on the right side of the page

Note that these are large files (over 12GB total), so ensure you have sufficient bandwidth and storage.

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
