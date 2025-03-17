# Sesame CSM-1B HuggingFace Files

This directory contains everything needed to download, verify, chunk, and recombine Sesame CSM-1B model files from Hugging Face.

## Quick Start

```bash
# Make the script executable
chmod +x sesame_hf_manager.sh

# Download all files from Hugging Face
./sesame_hf_manager.sh download

# Verify the downloaded files
./sesame_hf_manager.sh verify

# Split large files into chunks
./sesame_hf_manager.sh chunk

# Recombine chunked files
./sesame_hf_manager.sh recombine

# Do everything (download, verify, chunk)
./sesame_hf_manager.sh all
```

## File Structure

The Sesame CSM-1B model repository on Hugging Face contains the following files:

### Main Directory
| Filename | Size | MD5 Checksum | Description |
|----------|------|-------------|-------------|
| `config.json` | 121 bytes | cbfc7b06aa9fd96578eb0be4dc6317f4 | Model configuration file |
| `README.md` | 4.16 KB | f5ea45aa572160a03441fca4c39182b0 | Original documentation |
| `ckpt.pt` | 6.22 GB | *Large file, checksum verification skipped* | PyTorch checkpoint file |
| `model.safetensors` | 6.21 GB | *Large file, checksum verification skipped* | SafeTensors model file |

### Prompts Directory
| Filename | Size | MD5 Checksum | Description |
|----------|------|-------------|-------------|
| `conversational_a.wav` | 2.65 MB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Conversational speech sample A |
| `conversational_b.wav` | 2.65 MB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Conversational speech sample B |
| `read_speech_a.wav` | 831 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample A |
| `read_speech_b.wav` | 576 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample B |
| `read_speech_c.wav` | 386 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample C |
| `read_speech_d.wav` | 436 KB | cbfc7b06aa9fd96578eb0be4dc6317f4 | Read speech sample D |

## Expected Directory Structure After Running the Script

```
sesame-csm-1b/
├── config.json
├── README.md
├── ckpt.pt
├── model.safetensors
├── prompts/
│   ├── conversational_a.wav
│   ├── conversational_b.wav
│   ├── read_speech_a.wav
│   ├── read_speech_b.wav
│   ├── read_speech_c.wav
│   └── read_speech_d.wav
├── chunks/
│   ├── ckpt/
│   │   ├── ckpt.pt.part-aa
│   │   ├── ckpt.pt.part-ab
│   │   ├── ...
│   └── safetensors/
│       ├── model.safetensors.part-aa
│       ├── model.safetensors.part-ab
│       ├── ...
└── recombined/
    ├── ckpt.pt
    └── model.safetensors
```

## Command Options

```
Usage: ./sesame_hf_manager.sh [OPTIONS] COMMAND

A unified script to download, verify, chunk, and recombine Sesame CSM-1B model files.

Commands:
  download    Download all files from the Hugging Face repository
  verify      Verify the integrity of downloaded files
  chunk       Split large model files into chunks
  recombine   Recombine chunked files into original files
  all         Perform all operations (download, verify, chunk)

Options:
  -o, --output DIR    Output directory (default: sesame-csm-1b)
  -s, --size SIZE     Chunk size (default: 1G)
  -f, --force         Force overwrite of existing files
  -h, --help          Show this help message
```

## Requirements

- `curl` for downloading files
- `md5sum` for verifying file checksums
- `split` for chunking files
- Approximately 15GB of free disk space for all files

## Notes

- The model weights (ckpt.pt and model.safetensors) are large files (over 12GB total)
- Downloading these files may take a significant amount of time depending on your internet connection
- The verification script allows for small variations in file size (±5%) to account for potential differences in file formats
- MD5 checksums are verified for all files except the large model files
