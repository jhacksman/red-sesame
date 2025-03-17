#!/bin/bash

# Sesame CSM-1B Model Manager
# A unified script to download, verify, chunk, and recombine Sesame CSM-1B model files

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR="sesame-csm-1b"
CHUNK_SIZE="1G"
VERIFY_ONLY=false
DOWNLOAD_ONLY=false
CHUNK_ONLY=false
RECOMBINE_ONLY=false
FORCE=false

# File information
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

# Print usage information
print_usage() {
  echo "Usage: $0 [OPTIONS] COMMAND"
  echo ""
  echo "A unified script to download, verify, chunk, and recombine Sesame CSM-1B model files."
  echo ""
  echo "Commands:"
  echo "  download    Download all files from the Hugging Face repository"
  echo "  verify      Verify the integrity of downloaded files"
  echo "  chunk       Split large model files into chunks"
  echo "  recombine   Recombine chunked files into original files"
  echo "  all         Perform all operations (download, verify, chunk)"
  echo ""
  echo "Options:"
  echo "  -o, --output DIR    Output directory (default: $OUTPUT_DIR)"
  echo "  -s, --size SIZE     Chunk size (default: $CHUNK_SIZE)"
  echo "  -f, --force         Force overwrite of existing files"
  echo "  -h, --help          Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 download                  # Download all files"
  echo "  $0 verify                    # Verify downloaded files"
  echo "  $0 chunk                     # Split large files into chunks"
  echo "  $0 recombine                 # Recombine chunked files"
  echo "  $0 all                       # Download, verify, and chunk files"
  echo "  $0 -o custom-dir download    # Download to custom directory"
  echo "  $0 -s 500M chunk             # Split into 500MB chunks"
  echo ""
}

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -o|--output)
        OUTPUT_DIR="$2"
        shift 2
        ;;
      -s|--size)
        CHUNK_SIZE="$2"
        shift 2
        ;;
      -f|--force)
        FORCE=true
        shift
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      download)
        DOWNLOAD_ONLY=true
        shift
        ;;
      verify)
        VERIFY_ONLY=true
        shift
        ;;
      chunk)
        CHUNK_ONLY=true
        shift
        ;;
      recombine)
        RECOMBINE_ONLY=true
        shift
        ;;
      all)
        DOWNLOAD_ONLY=false
        VERIFY_ONLY=false
        CHUNK_ONLY=false
        RECOMBINE_ONLY=false
        shift
        ;;
      *)
        echo "Unknown option: $1"
        print_usage
        exit 1
        ;;
    esac
  done
}

# Function to download a file from Hugging Face
download_file() {
  local file_path=$1
  local output_path=$2
  local file_name=$(basename "$output_path")
  
  # Skip if file exists and force is not set
  if [ -f "$output_path" ] && [ "$FORCE" = false ]; then
    echo -e "${YELLOW}File ${file_name} already exists, skipping download.${NC}"
    echo -e "${YELLOW}Use -f or --force to overwrite.${NC}"
    return 0
  fi
  
  echo -e "${YELLOW}Downloading ${file_name}...${NC}"
  
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$output_path")"
  
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

# Function to split a file into chunks
chunk_file() {
  local file_path=$1
  local chunk_dir=$2
  local file_name=$(basename "$file_path")
  
  echo -e "${YELLOW}Splitting ${file_name} into chunks...${NC}"
  
  # Check if file exists
  if [ ! -f "$file_path" ]; then
    echo -e "${RED}File not found: ${file_path}${NC}"
    return 1
  fi
  
  # Create chunk directory if it doesn't exist
  mkdir -p "$chunk_dir"
  
  # Split the file into chunks
  split -b "$CHUNK_SIZE" "$file_path" "${chunk_dir}/${file_name}.part-"
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Split ${file_name} into chunks successfully.${NC}"
    
    # List the chunks
    echo -e "${CYAN}Chunks:${NC}"
    ls -la "${chunk_dir}/${file_name}.part-"*
    
    return 0
  else
    echo -e "${RED}Failed to split ${file_name} into chunks.${NC}"
    return 1
  fi
}

# Function to recombine chunks into a file
recombine_chunks() {
  local chunk_dir=$1
  local output_file=$2
  local file_name=$(basename "$output_file")
  
  echo -e "${YELLOW}Recombining chunks into ${file_name}...${NC}"
  
  # Check if chunk directory exists
  if [ ! -d "$chunk_dir" ]; then
    echo -e "${RED}Chunk directory not found: ${chunk_dir}${NC}"
    return 1
  fi
  
  # Check if chunks exist
  if [ ! "$(ls -A "${chunk_dir}/${file_name}.part-"* 2>/dev/null)" ]; then
    echo -e "${RED}No chunks found for ${file_name}.${NC}"
    return 1
  fi
  
  # Create output directory if it doesn't exist
  mkdir -p "$(dirname "$output_file")"
  
  # Recombine the chunks
  cat "${chunk_dir}/${file_name}.part-"* > "$output_file"
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Recombined ${file_name} successfully.${NC}"
    
    # Verify the recombined file size
    local actual_size=$(stat -c %s "$output_file")
    echo -e "${CYAN}Recombined file size: ${actual_size} bytes${NC}"
    
    return 0
  else
    echo -e "${RED}Failed to recombine ${file_name}.${NC}"
    return 1
  fi
}

# Function to download all files
download_all() {
  local base_dir=$1
  
  echo -e "${BLUE}=== Downloading Sesame CSM-1B Model Files ===${NC}"
  
  # Create directory structure
  mkdir -p "${base_dir}/prompts"
  
  # Files to download
  local files=(
    "config.json"
    "README.md"
    "ckpt.pt"
    "model.safetensors"
    "prompts/conversational_a.wav"
    "prompts/conversational_b.wav"
    "prompts/read_speech_a.wav"
    "prompts/read_speech_b.wav"
    "prompts/read_speech_c.wav"
    "prompts/read_speech_d.wav"
  )
  
  # Download all files
  for file_path in "${files[@]}"; do
    download_file "$file_path" "${base_dir}/${file_path}"
  done
  
  echo -e "${BLUE}=== Download Summary ===${NC}"
  echo -e "${GREEN}All files downloaded to ${base_dir}${NC}"
  echo ""
}

# Function to verify all files
verify_all() {
  local base_dir=$1
  
  echo -e "${BLUE}=== Verifying Sesame CSM-1B Model Files ===${NC}"
  
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

# Function to chunk large files
chunk_all() {
  local base_dir=$1
  
  echo -e "${BLUE}=== Chunking Large Sesame CSM-1B Model Files ===${NC}"
  
  # Create chunk directories
  mkdir -p "${base_dir}/chunks/ckpt"
  mkdir -p "${base_dir}/chunks/safetensors"
  
  # Chunk large files
  chunk_file "${base_dir}/ckpt.pt" "${base_dir}/chunks/ckpt"
  chunk_file "${base_dir}/model.safetensors" "${base_dir}/chunks/safetensors"
  
  echo -e "${BLUE}=== Chunking Summary ===${NC}"
  echo -e "${GREEN}Large files chunked successfully!${NC}"
  echo -e "${GREEN}Chunks are available in:${NC}"
  echo -e "${GREEN}- ${base_dir}/chunks/ckpt${NC}"
  echo -e "${GREEN}- ${base_dir}/chunks/safetensors${NC}"
  echo ""
}

# Function to recombine chunked files
recombine_all() {
  local base_dir=$1
  
  echo -e "${BLUE}=== Recombining Chunked Sesame CSM-1B Model Files ===${NC}"
  
  # Create output directory
  mkdir -p "${base_dir}/recombined"
  
  # Recombine chunked files
  recombine_chunks "${base_dir}/chunks/ckpt" "${base_dir}/recombined/ckpt.pt"
  recombine_chunks "${base_dir}/chunks/safetensors" "${base_dir}/recombined/model.safetensors"
  
  echo -e "${BLUE}=== Recombination Summary ===${NC}"
  echo -e "${GREEN}Chunked files recombined successfully!${NC}"
  echo -e "${GREEN}Recombined files are available in:${NC}"
  echo -e "${GREEN}- ${base_dir}/recombined/ckpt.pt${NC}"
  echo -e "${GREEN}- ${base_dir}/recombined/model.safetensors${NC}"
  echo ""
  
  # Verify recombined files
  echo -e "${BLUE}Verifying recombined files...${NC}"
  verify_size "${base_dir}/recombined/ckpt.pt" "${FILE_SIZES["ckpt.pt"]}"
  verify_size "${base_dir}/recombined/model.safetensors" "${FILE_SIZES["model.safetensors"]}"
}

# Main function
main() {
  # Parse command line arguments
  parse_args "$@"
  
  # Print banner
  echo -e "${BLUE}=======================================${NC}"
  echo -e "${BLUE}  Sesame CSM-1B Model Manager v1.0${NC}"
  echo -e "${BLUE}=======================================${NC}"
  echo ""
  
  # Execute commands based on options
  if [ "$DOWNLOAD_ONLY" = true ]; then
    download_all "$OUTPUT_DIR"
  elif [ "$VERIFY_ONLY" = true ]; then
    verify_all "$OUTPUT_DIR"
  elif [ "$CHUNK_ONLY" = true ]; then
    chunk_all "$OUTPUT_DIR"
  elif [ "$RECOMBINE_ONLY" = true ]; then
    recombine_all "$OUTPUT_DIR"
  else
    # Default: do everything
    download_all "$OUTPUT_DIR"
    verify_all "$OUTPUT_DIR"
    chunk_all "$OUTPUT_DIR"
  fi
  
  echo -e "${BLUE}=======================================${NC}"
  echo -e "${GREEN}  Operation completed successfully!${NC}"
  echo -e "${BLUE}=======================================${NC}"
}

# Run the main function with all arguments
main "$@"
