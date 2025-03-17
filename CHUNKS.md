# Sesame CSM-1B Model File Chunks

Due to GitHub's file size limitations (max 2GB per file), the large model weight files have been split into 1GB chunks. This document explains how to recombine these chunks to use the model.

## Chunked Files

The model weight files have been split into the following chunks:

### ckpt.pt (PyTorch checkpoint)
- `chunks/ckpt/ckpt.pt.part-aa` (1GB)
- `chunks/ckpt/ckpt.pt.part-ab` (1GB)
- `chunks/ckpt/ckpt.pt.part-ac` (1GB)
- `chunks/ckpt/ckpt.pt.part-ad` (1GB)
- `chunks/ckpt/ckpt.pt.part-ae` (1GB)
- `chunks/ckpt/ckpt.pt.part-af` (~851MB)

Total size: ~5.8GB

### model.safetensors (SafeTensors format)
- `chunks/safetensors/model.safetensors.part-aa` (1GB)
- `chunks/safetensors/model.safetensors.part-ab` (1GB)
- `chunks/safetensors/model.safetensors.part-ac` (1GB)
- `chunks/safetensors/model.safetensors.part-ad` (1GB)
- `chunks/safetensors/model.safetensors.part-ae` (1GB)
- `chunks/safetensors/model.safetensors.part-af` (~842MB)

Total size: ~5.8GB

## Recombining the Chunks

### Option 1: Using the Provided Script

The repository includes a `recombine.sh` script that automatically recombines the chunks:

```bash
# Make the script executable if needed
chmod +x recombine.sh

# Run the script
./recombine.sh
```

This will create an `output` directory containing the recombined files. You can then move them to the main directory:

```bash
mv output/ckpt.pt .
mv output/model.safetensors .
```

### Option 2: Manual Recombination

You can also manually recombine the chunks using the `cat` command:

#### For ckpt.pt:
```bash
cat chunks/ckpt/ckpt.pt.part-* > ckpt.pt
```

#### For model.safetensors:
```bash
cat chunks/safetensors/model.safetensors.part-* > model.safetensors
```

### Verification

You can verify the recombined files have the correct size:

```bash
# Check file sizes
ls -la ckpt.pt model.safetensors
```

The expected sizes are:
- ckpt.pt: ~5.8GB (6,219,618,714 bytes)
- model.safetensors: ~5.8GB (6,211,186,784 bytes)

## Using the Recombined Files

Once recombined, the model files will work with the code as described in the main documentation. The `generator.py` file has been modified to use local model files:

```python
def load_csm_1b(device: str = "cuda") -> Generator:
    # Load model from local files instead of downloading from Hugging Face
    # This uses the local ckpt.pt or model.safetensors file
    model = Model.from_local("./")
    model.to(device=device, dtype=torch.bfloat16)

    generator = Generator(model)
    return generator
```

This ensures that the model uses the local files rather than attempting to download them from Hugging Face.

## Troubleshooting

If you encounter issues with the recombined files:

1. **Verify file integrity**: Ensure all chunk files were downloaded correctly
2. **Check file permissions**: Make sure the recombined files have the correct read permissions
3. **Verify recombination**: The recombined files should match the original file sizes exactly

For any other issues, please refer to the main documentation or open an issue on the repository.
