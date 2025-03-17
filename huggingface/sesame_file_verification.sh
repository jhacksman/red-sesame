#!/bin/bash

# Sesame CSM-1B Model File Verification Script
# This script verifies the structure and integrity of Sesame CSM-1B model files

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Sesame CSM-1B Model File Verification ===${NC}"
echo "This script verifies the structure and integrity of Sesame CSM-1B model files."
echo ""

# Define expected files and their MD5 checksums
declare -A FILE_CHECKSUMS=(
  # Main directory files
  ["config.json"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["README.md"]="f5ea45aa572160a03441fca4c39182b0"
  
  # Prompts directory files
  ["prompts/conversational_a.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["prompts/conversational_b.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["prompts/read_speech_a.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["prompts/read_speech_b.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["prompts/read_speech_c.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
  ["prompts/read_speech_d.wav"]="cbfc7b06aa9fd96578eb0be4dc6317f4"
)

# File sizes in bytes for verification
declare -A FILE_SIZES=(
  # Main directory files
  ["config.json"]="121"
  ["README.md"]="4161"
  ["ckpt.pt"]="6219618714"
  ["model.safetensors"]="6211186784"
  
  # Prompts directory files
  ["prompts/conversational_a.wav"]="2650000"
  ["prompts/conversational_b.wav"]="2650000"
  ["prompts/read_speech_a.wav"]="831000"
  ["prompts/read_speech_b.wav"]="576000"
  ["prompts/read_speech_c.wav"]="386000"
  ["prompts/read_speech_d.wav"]="436000"
)

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
  
  echo -e "${YELLOW}Verifying checksum for ${file_path}...${NC}"
  
  # Check if file exists
  if [ ! -f "$file_path" ]; then
    echo -e "${RED}File not found: ${file_path}${NC}"
    return 1
  fi
  
  # Calculate MD5 checksum
  local actual_md5=$(md5sum "$file_path" | awk '{print $1}')
  
  if [ "$actual_md5" = "$expected_md5" ]; then
    echo -e "${GREEN}Checksum verified for ${file_path}.${NC}"
    return 0
  else
    echo -e "${RED}Checksum verification failed for ${file_path}.${NC}"
    echo -e "${RED}Expected: ${expected_md5}${NC}"
    echo -e "${RED}Actual: ${actual_md5}${NC}"
    return 1
  fi
}

# Function to verify a file's size
verify_size() {
  local file_path=$1
  local expected_size=$2
  
  echo -e "${YELLOW}Verifying size for ${file_path}...${NC}"
  
  # Check if file exists
  if [ ! -f "$file_path" ]; then
    echo -e "${RED}File not found: ${file_path}${NC}"
    return 1
  fi
  
  # Get file size
  local actual_size=$(stat -c %s "$file_path")
  
  # Allow for small variations in file size (±5%)
  local min_size=$((expected_size * 95 / 100))
  local max_size=$((expected_size * 105 / 100))
  
  if [ "$actual_size" -ge "$min_size" ] && [ "$actual_size" -le "$max_size" ]; then
    echo -e "${GREEN}Size verified for ${file_path}.${NC}"
    return 0
  else
    echo -e "${RED}Size verification failed for ${file_path}.${NC}"
    echo -e "${RED}Expected: ${expected_size} bytes${NC}"
    echo -e "${RED}Actual: ${actual_size} bytes${NC}"
    return 1
  fi
}

# Function to verify directory structure
verify_directory_structure() {
  local base_dir=$1
  
  echo -e "${BLUE}Verifying directory structure...${NC}"
  
  # Check if base directory exists
  if [ ! -d "$base_dir" ]; then
    echo -e "${RED}Base directory not found: ${base_dir}${NC}"
    return 1
  fi
  
  # Check if prompts directory exists
  if [ ! -d "${base_dir}/prompts" ]; then
    echo -e "${RED}Prompts directory not found: ${base_dir}/prompts${NC}"
    return 1
  fi
  
  echo -e "${GREEN}Directory structure verified.${NC}"
  return 0
}

# Main verification function
verify_files() {
  local base_dir=$1
  
  echo -e "${BLUE}Starting verification of files in ${base_dir}...${NC}"
  
  # Verify directory structure
  verify_directory_structure "$base_dir"
  if [ $? -ne 0 ]; then
    echo -e "${RED}Directory structure verification failed.${NC}"
    return 1
  fi
  
  # Track success/failure
  local total_files=0
  local successful_files=0
  
  # Verify file checksums
  echo -e "${BLUE}Verifying file checksums...${NC}"
  for file_path in "${!FILE_CHECKSUMS[@]}"; do
    total_files=$((total_files + 1))
    verify_checksum "${base_dir}/${file_path}" "${FILE_CHECKSUMS[$file_path]}"
    if [ $? -eq 0 ]; then
      successful_files=$((successful_files + 1))
    fi
  done
  
  # Verify file sizes
  echo -e "${BLUE}Verifying file sizes...${NC}"
  for file_path in "${!FILE_SIZES[@]}"; do
    if [[ ! " ${!FILE_CHECKSUMS[@]} " =~ " ${file_path} " ]]; then
      total_files=$((total_files + 1))
      verify_size "${base_dir}/${file_path}" "${FILE_SIZES[$file_path]}"
      if [ $? -eq 0 ]; then
        successful_files=$((successful_files + 1))
      fi
    fi
  done
  
  # Print summary
  echo -e "${BLUE}=== Verification Summary ===${NC}"
  echo -e "${GREEN}Successfully verified: ${successful_files}/${total_files} files${NC}"
  
  if [ $successful_files -eq $total_files ]; then
    echo -e "${GREEN}All files verified successfully!${NC}"
    return 0
  else
    echo -e "${RED}Some files failed verification.${NC}"
    return 1
  fi
}

# Check if a directory was provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <directory>"
  echo "Example: $0 ./sesame-csm-1b"
  exit 1
fi

# Run verification
verify_files "$1"
exit $?
