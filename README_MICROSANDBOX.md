# OpenCode with Additional Tools - Microsandbox Setup

This setup extends the base OpenCode image with additional tools like `pdftotext`, ImageMagick, Tesseract OCR, and more, using **microsandbox** instead of Docker Compose.

## Features Added

- **pdftotext**: Extract text from PDF files
- **ImageMagick**: Image processing and conversion
- **Ghostscript**: Advanced PDF processing
- **Tesseract OCR**: Optical Character Recognition
- **FFmpeg**: Video and audio processing
- **LibreOffice**: Document conversion
- **Pandoc**: Universal document converter

## Quick Start with Microsandbox

### 1. Build and Load the Custom Image

```bash
# Make the build script executable
chmod +x build-and-load-image.sh

# Build the image and load it into microsandbox
./build-and-load-image.sh
```

This will:
1. Build the extended OpenCode image with all additional tools
2. Save it as `opencode-tools.tar`
3. Load it into microsandbox as `opencode-tools:latest`
4. Clean up the temporary tar file

### 2. Run OpenCode in Microsandbox

```bash
# Start OpenCode with persistent storage (default port: 50000 for web)
./start-opencode.sh

# Custom port
./start-opencode.sh --port 3000

# Shell mode (for debugging/advanced usage)
./start-opencode.sh --shell
```



### 4. Access OpenCode

- Web interface: http://localhost:50000 (or your custom port)

## Usage Examples

### Extract text from PDF

```bash
# Once the container is running, you can use pdftotext inside it:
msb exec opencode pdftotext /app/data/input.pdf /app/data/output.txt
```

### Convert images

```bash
# Use ImageMagick's convert command
msb exec opencode convert input.jpg output.png
```

### Perform OCR on an image

```bash
# Use Tesseract OCR
msb exec opencode tesseract input.png output -l eng
```

## Persistent Storage

- `./data`: Stores all persistent data
- `./config`: Stores configuration files

## Updating

To update to a newer version:

```bash
# Rebuild and reload the image
./build-and-load-image.sh

# Restart your microsandbox containers
msb stop opencode
./start-opencode.sh
```

## Security Notes

- The containers run with elevated privileges (`SYS_ADMIN` capability) required for some PDF operations
- AppArmor is disabled for better compatibility
- Consider setting strong passwords and API keys
- For production, use proper security measures and network isolation

## Troubleshooting

### Common issues

1. **PDF processing fails**: Ensure the container has proper permissions to access the files
2. **Memory issues**: Increase microsandbox's memory allocation if processing large files
3. **Missing fonts**: Install additional fonts by extending the Dockerfile

### View logs

```bash
# View all logs
msb logs opencode

# Follow logs in real-time
msb logs -f opencode
```

### Shell access

```bash
# Access the container shell
msb exec -it opencode sh
```

## Command Reference

### Basic microsandbox commands

```bash
# List running containers
msb ps

# Stop a container
msb stop opencode

# Start a container
msb start opencode

# Remove a container
msb rm opencode

# View container details
msb inspect opencode
```

## Customization

To add more tools or customize the setup:

1. Edit the `Dockerfile` to add additional packages
2. Rebuild and reload: `./BUILD_AND_LOAD_IMAGE.sh`
3. Update your microsandbox commands as needed

## License

This setup is provided as-is. The base OpenCode image follows its own licensing terms.

---

For more information about OpenCode, visit: https://github.com/anomalyco/opencode
For more information about microsandbox, check the microsandbox documentation.