#!/bin/bash

# Setup script for Sesame CSM-1B model
# This script helps set up the environment and dependencies for the Sesame CSM-1B model

set -e  # Exit on error

echo "Setting up Sesame CSM-1B model environment..."

# Check if Python 3.10 is installed
if command -v python3.10 &>/dev/null; then
    echo "Python 3.10 found."
else
    echo "Python 3.10 is required but not found."
    echo "Please install Python 3.10 and try again."
    exit 1
fi

# Check if CUDA is available
if command -v nvidia-smi &>/dev/null; then
    echo "NVIDIA GPU detected."
else
    echo "Warning: NVIDIA GPU not detected. The model will run slowly on CPU."
    echo "It is recommended to use a CUDA-compatible GPU for better performance."
fi

# Check if ffmpeg is installed
if command -v ffmpeg &>/dev/null; then
    echo "ffmpeg found."
else
    echo "Warning: ffmpeg not found. Some audio operations may not work."
    echo "Installing ffmpeg..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y ffmpeg
    elif command -v brew &>/dev/null; then
        brew install ffmpeg
    else
        echo "Please install ffmpeg manually and try again."
    fi
fi

# Create and activate virtual environment
echo "Creating virtual environment..."
python3.10 -m venv .venv
source .venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Check if we're on Windows and install triton-windows if needed
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "Windows detected. Installing triton-windows..."
    pip uninstall -y triton
    pip install triton-windows
fi

# Login to Hugging Face
echo "You need to log in to Hugging Face to access the model weights."
echo "Please run the following command and enter your Hugging Face token when prompted:"
echo "huggingface-cli login"

# Check if model files exist
if [ ! -f "ckpt.pt" ] || [ ! -f "model.safetensors" ]; then
    echo ""
    echo "Model weight files not found. You need to recombine the chunked files first."
    echo "Please run the recombination script:"
    echo "  chmod +x recombine.sh"
    echo "  ./recombine.sh"
    echo "Then move the recombined files to the main directory:"
    echo "  mv output/ckpt.pt ."
    echo "  mv output/model.safetensors ."
    echo "For more information, see CHUNKS.md"
    echo ""
else
    echo "Model weight files found."
fi
echo ""

# Provide a simple test script
echo "Creating a test script..."
cat > test_model.py << 'EOF'
from generator import load_csm_1b
import torchaudio
import torch

print("Testing Sesame CSM-1B model...")

if torch.backends.mps.is_available():
    device = "mps"
    print("Using MPS (Apple Silicon)")
elif torch.cuda.is_available():
    device = "cuda"
    print("Using CUDA")
else:
    device = "cpu"
    print("Using CPU (this will be slow)")

try:
    print("Loading model (this may take a while and will download weights if needed)...")
    generator = load_csm_1b(device=device)
    
    print("Generating audio...")
    audio = generator.generate(
        text="Hello, this is a test of the Sesame CSM-1B model.",
        speaker=0,
        context=[],
        max_audio_length_ms=5_000,
    )
    
    print("Saving audio to test_audio.wav...")
    torchaudio.save("test_audio.wav", audio.unsqueeze(0).cpu(), generator.sample_rate)
    print("Success! Audio saved to test_audio.wav")
except Exception as e:
    print(f"Error: {e}")
    print("Please check the documentation for troubleshooting.")
EOF

echo ""
echo "Setup complete!"
echo "To test the model, run: python test_model.py"
echo "For more information, see DOCUMENTATION.md"
