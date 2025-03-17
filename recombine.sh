#!/bin/bash

# Recombination script for Sesame CSM-1B model files
# This script recombines the chunked model files back into their original form

echo "Recombining Sesame CSM-1B model files..."

# Create output directory if it doesn't exist
mkdir -p output

# Recombine ckpt.pt
echo "Recombining ckpt.pt..."
cat chunks/ckpt/ckpt.pt.part-* > output/ckpt.pt

# Recombine model.safetensors
echo "Recombining model.safetensors..."
cat chunks/safetensors/model.safetensors.part-* > output/model.safetensors

# Verify file sizes
CKPT_SIZE=$(stat -c %s output/ckpt.pt)
SAFETENSORS_SIZE=$(stat -c %s output/model.safetensors)

echo "Recombination complete!"
echo "ckpt.pt size: $CKPT_SIZE bytes"
echo "model.safetensors size: $SAFETENSORS_SIZE bytes"
echo ""
echo "The recombined files are in the 'output' directory."
echo "Move them to the main directory to use with the model:"
echo "mv output/ckpt.pt ."
echo "mv output/model.safetensors ."

# Make the script executable
chmod +x recombine.sh
