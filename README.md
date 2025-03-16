# Red Sesame: Security Analysis of Sesame CSM-1B Model

This repository contains the Sesame CSM-1B model files and documentation for security analysis and red teaming purposes. The goal is to understand the model's capabilities, limitations, and potential security implications.

## What is Sesame CSM-1B?

Sesame CSM-1B (Conversational Speech Model) is a speech generation model that uses a Llama backbone and a smaller audio decoder to produce audio codes. The model is available on GitHub (code) and Hugging Face (weights).

Key components:
- Python code for model architecture and generation
- Dependencies on Hugging Face models (Llama-3.2-1B and CSM-1B)
- Large model weights (over 12GB total)
- Watermarking functionality to identify AI-generated audio

## Repository Contents

- `generator.py`: Main code for generating speech using the model
- `models.py`: Model architecture definitions
- `watermarking.py`: Code for watermarking generated audio
- `requirements.txt`: Dependencies required to run the model
- `DOCUMENTATION.md`: Comprehensive documentation about the model
- `model_weights.md`: Information about accessing the model weights
- `setup.sh`: Script to help with model installation
- `LICENSE`: Apache 2.0 license from the original repository

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/jhacksman/red-sesame.git
   cd red-sesame
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

3. Generate speech:
   ```python
   from generator import load_csm_1b
   import torchaudio
   import torch

   generator = load_csm_1b(device="cuda")

   audio = generator.generate(
       text="Hello, this is a test of the Sesame CSM-1B model.",
       speaker=0,
       context=[],
       max_audio_length_ms=10_000,
   )

   torchaudio.save("test_audio.wav", audio.unsqueeze(0).cpu(), generator.sample_rate)
   ```

## Documentation

For detailed information about the model, see:
- [DOCUMENTATION.md](DOCUMENTATION.md): Comprehensive documentation about the model architecture, setup, and usage
- [model_weights.md](model_weights.md): Information about accessing and using the model weights

## Security Considerations

When analyzing this model for security purposes, consider:

1. **Voice Cloning Potential**: The model can generate realistic speech that could potentially be misused for impersonation
2. **Watermarking**: The model includes watermarking functionality to identify AI-generated audio
3. **Ethical Use**: The model should not be used for impersonation, fraud, misinformation, or any illegal activities
4. **Limitations**: The model has limitations in non-English languages and specific voice mimicry

## Attribution

The original CSM-1B model was created by Johan Schalkwyk, Ankit Kumar, Dan Lyth, Sefik Emre Eskimez, Zack Hodari, Cinjon Resnick, Ramon Sanabria, Raven Jiang, and the Sesame team.

The model is released under the Apache 2.0 license.
