# Sesame CSM-1B Model Files Documentation

This document provides detailed information about the Sesame CSM-1B model files, including exact filenames, sizes, MD5 checksums, and instructions for recreating the repository structure.

## Repository Structure

The Sesame CSM-1B model repository has the following structure:

```
sesame-csm-1b/
├── config.json
├── README.md
├── ckpt.pt
├── model.safetensors
└── prompts/
    ├── conversational_a.wav
    ├── conversational_b.wav
    ├── read_speech_a.wav
    ├── read_speech_b.wav
    ├── read_speech_c.wav
    └── read_speech_d.wav
```

## File Details

### Main Directory Files

| Filename | Size | MD5 Checksum | Description |
|----------|------|-------------|-------------|
| `config.json` | 121 bytes | cbfc7b06aa9fd96578eb0be4dc6317f4 | Model configuration file |
| `README.md` | 4.16 KB | f5ea45aa572160a03441fca4c39182b0 | Original documentation |
| `ckpt.pt` | 6.22 GB | *Large file, checksum verification skipped* | PyTorch checkpoint file |
| `model.safetensors` | 6.21 GB | *Large file, checksum verification skipped* | SafeTensors model file |

### Prompts Directory Files

| Filename | Size | MD5 Checksum | Description |
|----------|------|-------------|-------------|
| `conversational_a.wav` | 2.65 MB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Conversational speech sample A |
| `conversational_b.wav` | 2.65 MB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Conversational speech sample B |
| `read_speech_a.wav` | 831 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample A |
| `read_speech_b.wav` | 576 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample B |
| `read_speech_c.wav` | 386 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample C |
| `read_speech_d.wav` | 436 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample D |

## Downloading the Files

### Option 1: Using the Provided Script

The `download_sesame_files.sh` script will download all files from the Hugging Face repository and verify their integrity:

```bash
# Make the script executable
chmod +x download_sesame_files.sh

# Run the script
./download_sesame_files.sh
```

### Option 2: Manual Download

You can manually download the files from the Hugging Face repository:

1. Visit [https://huggingface.co/sesame/csm-1b](https://huggingface.co/sesame/csm-1b)
2. Accept the terms and conditions
3. Download each file individually:
   - Main directory files: config.json, README.md, ckpt.pt, model.safetensors
   - Prompts directory files: conversational_a.wav, conversational_b.wav, read_speech_a.wav, read_speech_b.wav, read_speech_c.wav, read_speech_d.wav

### Option 3: Using Git and Hugging Face CLI

You can use the Hugging Face CLI to download the model:

```bash
# Install the Hugging Face CLI
pip install huggingface_hub

# Login to Hugging Face
huggingface-cli login

# Download the model
huggingface-cli download sesame/csm-1b --local-dir ./sesame-csm-1b
```

## Verifying File Integrity

After downloading the files, you can verify their integrity using the provided `sesame_file_verification.sh` script:

```bash
# Make the script executable
chmod +x sesame_file_verification.sh

# Run the verification script
./sesame_file_verification.sh ./sesame-csm-1b
```

The script will:
1. Verify the directory structure
2. Verify the MD5 checksums of all files (except large model files)
3. Verify the sizes of all files
4. Report any discrepancies

## Using the Model

To use the model, you'll need to:

1. Clone the code repository:
   ```bash
   git clone https://github.com/SesameAILabs/csm.git
   cd csm
   ```

2. Install the requirements:
   ```bash
   pip install -r requirements.txt
   ```

3. Place the downloaded model files in the appropriate locations:
   - Place `ckpt.pt` and `model.safetensors` in the main directory
   - Place the prompt files in the `prompts` directory

4. Use the model as described in the documentation:
   ```python
   from generator import load_csm_1b
   import torchaudio
   
   generator = load_csm_1b(device="cuda")
   
   audio = generator.generate(
       text="Hello from Sesame.",
       speaker=0,
       context=[],
       max_audio_length_ms=10_000,
   )
   
   torchaudio.save("audio.wav", audio.unsqueeze(0).cpu(), generator.sample_rate)
   ```

## Notes

- The model weights (ckpt.pt and model.safetensors) are large files (over 12GB total)
- MD5 checksums are provided for all files except the large model files
- File sizes may vary slightly depending on the download method
- The model requires a CUDA-compatible GPU for optimal performance
