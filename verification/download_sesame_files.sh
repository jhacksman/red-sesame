#!/bin/bash

# Sesame CSM-1B Model File Download Script
# This script downloads all files from the Sesame CSM-1B model repository

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Sesame CSM-1B Model File Download ===${NC}"
echo "This script will download all files from the Sesame CSM-1B model repository."
echo ""

# Create directory structure
mkdir -p sesame-csm-1b/prompts

# Function to download a file from Hugging Face
download_file() {
  local file_path=$1
  local output_path=$2
  local file_name=$(basename "$output_path")
  
  echo -e "${YELLOW}Downloading ${file_name}...${NC}"
  
  # Use curl to download the file
  curl -L "https://huggingface.co/sesame/csm-1b/resolve/main/${file_path}" -o "$output_path" --progress-bar
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Downloaded ${file_name} successfully.${NC}"
  else
    echo -e "${RED}Failed to download ${file_name}.${NC}"
    return 1
  fi
}

# Files to download
declare -A FILES=(
  # Main directory files
  ["config.json"]="sesame-csm-1b/config.json"
  ["README.md"]="sesame-csm-1b/README.md"
  ["ckpt.pt"]="sesame-csm-1b/ckpt.pt"
  ["model.safetensors"]="sesame-csm-1b/model.safetensors"
  
  # Prompts directory files
  ["prompts/conversational_a.wav"]="sesame-csm-1b/prompts/conversational_a.wav"
  ["prompts/conversational_b.wav"]="sesame-csm-1b/prompts/conversational_b.wav"
  ["prompts/read_speech_a.wav"]="sesame-csm-1b/prompts/read_speech_a.wav"
  ["prompts/read_speech_b.wav"]="sesame-csm-1b/prompts/read_speech_b.wav"
  ["prompts/read_speech_c.wav"]="sesame-csm-1b/prompts/read_speech_c.wav"
  ["prompts/read_speech_d.wav"]="sesame-csm-1b/prompts/read_speech_d.wav"
)

# Download all files
echo -e "${BLUE}Downloading files...${NC}"
for file_path in "${!FILES[@]}"; do
  download_file "$file_path" "${FILES[$file_path]}"
done

echo -e "${BLUE}=== Download Summary ===${NC}"
echo -e "${GREEN}All files downloaded successfully!${NC}"
echo "The Sesame CSM-1B model files are now available in the sesame-csm-1b directory."
echo ""
echo "To verify the files, run: ./sesame_file_verification.sh ./sesame-csm-1b"
