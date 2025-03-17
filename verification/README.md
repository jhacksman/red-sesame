# Sesame CSM-1B Model Verification

This directory contains scripts and documentation for downloading and verifying the Sesame CSM-1B model files.

## Contents

- `SESAME_FILES.md`: Detailed documentation of all files in the Sesame CSM-1B model repository
- `download_sesame_files.sh`: Script to download all files from the Hugging Face repository
- `sesame_file_verification.sh`: Script to verify the integrity of downloaded files

## Quick Start

1. Download the files:
   ```bash
   ./download_sesame_files.sh
   ```

2. Verify the files:
   ```bash
   ./sesame_file_verification.sh ./sesame-csm-1b
   ```

## File Structure

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

For detailed information about each file, including exact filenames, sizes, and MD5 checksums, see [SESAME_FILES.md](SESAME_FILES.md).

## Requirements

- `curl` for downloading files
- `md5sum` for verifying file checksums
- Approximately 15GB of free disk space for all files

## Notes

- The model weights (ckpt.pt and model.safetensors) are large files (over 12GB total)
- Downloading these files may take a significant amount of time depending on your internet connection
- The verification script allows for small variations in file size (±5%) to account for potential differences in file formats
