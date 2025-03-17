#!/bin/bash

# Sesame CSM-1B Model File Verification Script
# This script downloads and verifies the Sesame CSM-1B model files from Hugging Face

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "=== Sesame CSM-1B Model File Verification ==="
echo "This script will download and verify all files from the Sesame CSM-1B model repository."
echo ""

# Create directory structure
mkdir -p sesame-csm-1b/prompts

# Define expected files and their MD5 checksums
declare -A FILE_CHECKSUMS=(
  # Main directory files
  ["sesame-csm-1b/config.json"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["sesame-csm-1b/README.md"]="f5ea45aa572160a03441fca4c39182b0"
  
  # Prompts directory files
  ["sesame-csm-1b/prompts/conversational_a.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["sesame-csm-1b/prompts/conversational_b.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["sesame-csm-1b/prompts/read_speech_a.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["sesame-csm-1b/prompts/read_speech_b.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["sesame-csm-1b/prompts/read_speech_c.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["sesame-csm-1b/prompts/read_speech_d.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
)

# File sizes in bytes for verification
declare -A FILE_SIZES=(
  # Main directory files
  ["sesame-csm-1b/config.json"]="121"
  ["sesame-csm-1b/README.md"]="4161"
  ["sesame-csm-1b/ckpt.pt"]="6219618714"
  ["sesame-csm-1b/model.safetensors"]="6211186784"
  
  # Prompts directory files
  ["sesame-csm-1b/prompts/conversational_a.wav"]="2650000"
  ["sesame-csm-1b/prompts/conversational_b.wav"]="2650000"
  ["sesame-csm-1b/prompts/read_speech_a.wav"]="831000"
  ["sesame-csm-1b/prompts/read_speech_b.wav"]="576000"
  ["sesame-csm-1b/prompts/read_speech_c.wav"]="386000"
  ["sesame-csm-1b/prompts/read_speech_d.wav"]="436000"
)

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

# Function to verify a file's MD5 checksum
verify_checksum() {
  local file_path=$1
  local expected_md5=$2
  local file_name=$(basename "$file_path")
  
  # Skip checksum verification for large model files
  if [[ "$file_name" == "ckpt.pt" || "$file_name" == "model.safetensors" ]]; then
    echo -e "${YELLOW}Skipping checksum verification for ${file_name} (large file).${NC}"
    return 0
  fi
  
  echo -e "${YELLOW}Verifying checksum for ${file_name}...${NC}"
  
  # Calculate MD5 checksum
  local actual_md5=$(md5sum "$file_path" | awk '{print $1}')
  
  if [ "$actual_md5" = "$expected_md5" ]; then
    echo -e "${GREEN}Checksum verified for ${file_name}.${NC}"
    return 0
  else
    echo -e "${RED}Checksum verification failed for ${file_name}.${NC}"
    echo -e "${RED}Expected: ${expected_md5}${NC}"
    echo -e "${RED}Actual: ${actual_md5}${NC}"
    return 1
  fi
}

# Function to verify a file's size
verify_size() {
  local file_path=$1
  local expected_size=$2
  local file_name=$(basename "$file_path")
  
  echo -e "${YELLOW}Verifying size for ${file_name}...${NC}"
  
  # Get file size
  local actual_size=$(stat -c %s "$file_path")
  
  # Allow for small variations in file size (±5%)
  local min_size=$((expected_size * 95 / 100))
  local max_size=$((expected_size * 105 / 100))
  
  if [ "$actual_size" -ge "$min_size" ] && [ "$actual_size" -le "$max_size" ]; then
    echo -e "${GREEN}Size verified for ${file_name}.${NC}"
    return 0
  else
    echo -e "${RED}Size verification failed for ${file_name}.${NC}"
    echo -e "${RED}Expected: ${expected_size} bytes${NC}"
    echo -e "${RED}Actual: ${actual_size} bytes${NC}"
    return 1
  fi
}

# Download and verify all files
echo "Downloading and verifying files..."
echo ""

# Track success/failure
total_files=0
successful_files=0

# Process each file
for file_path in "${!FILE_SIZES[@]}"; do
  total_files=$((total_files + 1))
  
  # Determine the relative path in the Hugging Face repo
  if [[ $file_path == sesame-csm-1b/prompts/* ]]; then
    hf_path="prompts/$(basename "$file_path")"
  else
    hf_path="$(basename "$file_path")"
  fi
  
  # Skip .gitattributes if it doesn't exist in the repo
  if [[ $file_path == *".gitattributes"* ]] && ! curl --head --silent --fail "https://huggingface.co/sesame/csm-1b/resolve/main/.gitattributes" > /dev/null; then
    echo -e "${YELLOW}Skipping .gitattributes (not found in repository)${NC}"
    continue
  fi
  
  # Download the file
  download_file "$hf_path" "$file_path"
  
  if [ $? -eq 0 ]; then
    # Verify file size
    verify_size "$file_path" "${FILE_SIZES[$file_path]}"
    size_ok=$?
    
    # Verify checksum if available
    if [[ -n "${FILE_CHECKSUMS[$file_path]}" ]]; then
      verify_checksum "$file_path" "${FILE_CHECKSUMS[$file_path]}"
      checksum_ok=$?
    else
      checksum_ok=0
      echo -e "${YELLOW}No checksum available for ${file_path}, skipping checksum verification.${NC}"
    fi
    
    if [ $size_ok -eq 0 ] && [ $checksum_ok -eq 0 ]; then
      successful_files=$((successful_files + 1))
    fi
  fi
  
  echo ""
done

# Print summary
echo "=== Verification Summary ==="
echo -e "${GREEN}Successfully verified: ${successful_files}/${total_files} files${NC}"

if [ $successful_files -eq $total_files ]; then
  echo -e "${GREEN}All files verified successfully!${NC}"
  echo "The Sesame CSM-1B model files are now available in the sesame-csm-1b directory."
else
  echo -e "${RED}Some files failed verification.${NC}"
  echo "Please check the output above for details."
fi

echo ""
echo "To use the model, follow the instructions in the README.md file."
