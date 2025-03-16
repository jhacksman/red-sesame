# Sesame CSM-1B Model Documentation

## Overview

CSM (Conversational Speech Model) is a speech generation model from Sesame that generates RVQ audio codes from text and audio inputs. The model architecture employs a Llama backbone and a smaller audio decoder that produces Mimi audio codes.

Released on March 13, 2025, the 1B CSM variant is designed for high-quality speech generation with a focus on conversational applications. The model is capable of producing a variety of voices but has not been fine-tuned on any specific voice.

## Architecture

The CSM-1B model consists of two main components:

1. **Backbone**: A Llama-3.2-1B transformer model that processes text and audio inputs
2. **Audio Decoder**: A smaller decoder that produces audio codes

The model architecture:
- Uses residual vector quantization (RVQ) to encode and recreate human-like speech
- Employs a technique similar to Google's SoundStream and Meta's Encodec
- Processes both text and audio inputs to generate contextually appropriate speech
- Includes watermarking functionality to identify AI-generated audio

## Dependencies

The model requires the following dependencies:

```
torch==2.4.0
torchaudio==2.4.0
tokenizers==0.21.0
transformers==4.49.0
huggingface_hub==0.28.1
moshi==0.2.2
torchtune==0.4.0
torchao==0.9.0
silentcipher @ git+https://github.com/SesameAILabs/silentcipher@master
```

Additionally, you'll need:
- A CUDA-compatible GPU
- CUDA 12.4 or 12.6 (other versions may work)
- Python 3.10 (recommended, newer versions may work)
- ffmpeg (for some audio operations)
- Access to the following Hugging Face models:
  - [Llama-3.2-1B](https://huggingface.co/meta-llama/Llama-3.2-1B)
  - [CSM-1B](https://huggingface.co/sesame/csm-1b)

## Setup Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/jhacksman/red-sesame.git
   cd red-sesame
   ```

2. Create and activate a virtual environment:
   ```bash
   python3.10 -m venv .venv
   source .venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Login to Hugging Face (required to access the model weights):
   ```bash
   huggingface-cli login
   ```

5. For Windows users: The `triton` package cannot be installed in Windows. Instead use:
   ```bash
   pip install triton-windows
   ```

## Usage Examples

### Basic Usage

Generate a sentence:

```python
from generator import load_csm_1b
import torchaudio
import torch

if torch.backends.mps.is_available():
    device = "mps"
elif torch.cuda.is_available():
    device = "cuda"
else:
    device = "cpu"

generator = load_csm_1b(device=device)

audio = generator.generate(
    text="Hello from Sesame.",
    speaker=0,
    context=[],
    max_audio_length_ms=10_000,
)

torchaudio.save("audio.wav", audio.unsqueeze(0).cpu(), generator.sample_rate)
```

### Advanced Usage with Context

CSM sounds best when provided with context. You can prompt or provide context to the model using a `Segment` for each speaker's utterance:

```python
speakers = [0, 1, 0, 0]
transcripts = [
    "Hey how are you doing.",
    "Pretty good, pretty good.",
    "I'm great.",
    "So happy to be speaking to you.",
]
audio_paths = [
    "utterance_0.wav",
    "utterance_1.wav",
    "utterance_2.wav",
    "utterance_3.wav",
]

def load_audio(audio_path):
    audio_tensor, sample_rate = torchaudio.load(audio_path)
    audio_tensor = torchaudio.functional.resample(
        audio_tensor.squeeze(0), orig_freq=sample_rate, new_freq=generator.sample_rate
    )
    return audio_tensor

segments = [
    Segment(text=transcript, speaker=speaker, audio=load_audio(audio_path))
    for transcript, speaker, audio_path in zip(transcripts, speakers, audio_paths)
]
audio = generator.generate(
    text="Me too, this is some cool stuff huh?",
    speaker=1,
    context=segments,
    max_audio_length_ms=10_000,
)

torchaudio.save("audio.wav", audio.unsqueeze(0).cpu(), generator.sample_rate)
```

## Model Weights

The model weights are hosted on Hugging Face and are quite large:
- ckpt.pt: 6.22 GB
- model.safetensors: 6.21 GB

See the [model_weights.md](model_weights.md) file for detailed information on accessing and downloading these files.

## Watermarking Functionality

The CSM-1B model includes watermarking functionality to identify audio as AI-generated. This is implemented in the `watermarking.py` file and uses the `silentcipher` library.

Key aspects of the watermarking:
- Applies an imperceptible watermark to identify audio as AI-generated
- Ensures transparency and enables traceability
- Helps dissuade misuse of the technology
- Uses a public watermark key for the GitHub version

The watermarking process:
1. Takes the generated audio
2. Applies a watermark using the `silentcipher` library
3. Returns the watermarked audio

You can verify if audio has been watermarked using the `verify` function in `watermarking.py`.

## Limitations and Ethical Considerations

- The model is a base generation model and has not been fine-tuned on any specific voice
- It cannot generate text and is not a general-purpose multimodal LLM
- It has limited support for non-English languages
- The model should not be used for impersonation, fraud, misinformation, or any illegal/harmful activities

## Attribution

The CSM-1B model was created by Johan Schalkwyk, Ankit Kumar, Dan Lyth, Sefik Emre Eskimez, Zack Hodari, Cinjon Resnick, Ramon Sanabria, Raven Jiang, and the Sesame team.

The model is released under the Apache 2.0 license.
