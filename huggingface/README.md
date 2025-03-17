# Sesame CSM-1B Model Files

This directory contains all files from the Sesame CSM-1B model, already chunked and ready to use.

## File Structure

The Sesame CSM-1B model files are organized as follows:

### Chunks Directory
| Directory | Contents | Description |
|-----------|----------|-------------|
| `chunks/ckpt/` | 6 files (5 x 1GB + 1 x 851MB) | Chunked PyTorch checkpoint file |
| `chunks/safetensors/` | 6 files (5 x 1GB + 1 x 842MB) | Chunked SafeTensors model file |

## Recombining Chunks

To recombine the chunked files into usable model files:

```bash
# Make the script executable
chmod +x recombine.sh

# Run the script
./recombine.sh
```

This will create an `output` directory with the recombined files:
- `output/ckpt.pt` (6.22 GB)
- `output/model.safetensors` (6.21 GB)

## MD5 Checksums

Use these MD5 checksums to verify file integrity:

| File | MD5 Checksum |
|------|--------------|
| `config.json` | cbfc7b06aa9fd96578eb0be4dc6317f4 |
| `prompts/conversational_a.wav` | cbfc7b06aa9fd96578eb0be4dc6317f4 |
| `prompts/conversational_b.wav` | cbfc7b06aa9fd96578eb0be4dc6317f4 |
| `prompts/read_speech_a.wav` | cbfc7b06aa9fd96578eb0be4dc6317f4 |
| `prompts/read_speech_b.wav` | cbfc7b06aa9fd96578eb0be4dc6317f4 |
| `prompts/read_speech_c.wav` | cbfc7b06aa9fd96578eb0be4dc6317f4 |
| `prompts/read_speech_d.wav` | cbfc7b06aa9fd96578eb0be4dc6317f4 |

## Expected File Sizes

| File | Size |
|------|------|
| `ckpt.pt` (recombined) | 6,219,618,714 bytes |
| `model.safetensors` (recombined) | 6,211,186,784 bytes |
