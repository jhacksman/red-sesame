# Red Sesame: Sesame CSM-1B Model Files

This repository contains the complete Sesame CSM-1B model files for security analysis.

## Quick Start

All model files are in the `huggingface` directory:

```bash
cd huggingface

# Recombine the model chunks
./recombine.sh

# Move the recombined files to your working directory
mv output/ckpt.pt .
mv output/model.safetensors .
```

## Repository Structure

- `huggingface/`: Contains all model files and scripts
  - `chunks/`: Contains chunked model weight files
  - `recombine.sh`: Script to recombine chunked files
  - `README.md`: Detailed information about the model files

## Model Information

Sesame CSM-1B is a speech generation model that uses a Llama backbone and a smaller audio decoder to produce audio codes.
