# OpenCode with Additional Tools - Microsandbox Edition

This setup extends the base OpenCode image with additional tools like `pdftotext`, ImageMagick, Tesseract OCR, and more, using **microsandbox** instead of Docker Compose.

## Features Added

- **pdftotext**: Extract text from PDF files
- **ImageMagick**: Image processing and conversion
- **Ghostscript**: Advanced PDF processing
- **Tesseract OCR**: Optical Character Recognition
- **FFmpeg**: Video and audio processing
- **LibreOffice**: Document conversion
- **Pandoc**: Universal document converter

## Quick Start

### 1. Build and load the custom image

```bash
# Make the build script executable
chmod +x build-and-load-image.sh

# Build the image and load it into microsandbox
./build-and-load-image.sh
```

### 2. Start OpenCode

```bash
# Start the main OpenCode container (default port: 50001 for web)
./opencode-sandbox.sh

# Custom port
./opencode-sandbox.sh --port 3000

# Shell mode (for debugging/advanced usage)
./opencode-sandbox.sh --shell

# Custom secrets file location
./opencode-sandbox.sh --secrets-env /path/to/my-secrets.env
```

### 3. Access OpenCode

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

## Configuration Options

The OpenCode sandbox supports several configuration methods:

### Command Line Arguments

| Argument | Description | Default Value |
|----------|-------------|---------------|
| `--secrets-env <path>` | Path to secrets file (.env) | `$HOME/.local/share/opencode-sandbox/config.env` |
| `--port <port>` | Port for OpenCode web interface | `50001` |
| `--no-mount` | Disable project directory mounting | Disabled |
| `--shell` | Start in shell mode | Disabled |

### Environment Variables in .env file

You can also configure OpenCode by setting these variables in your `.env` file:

- `OPENCODE_PASSWORD` - Password for OpenCode server (default: `blaat`)
- `OPENCODE_SERVER_PASSWORD` - Server password (default: `blaat`)
- `OPENCODE_WEB_PASSWORD` - Web interface password
- `OPENCODE_API_KEY` - API key for models
- `OPENCODE_HOST` - Host address
- `OPENCODE_PORT` - Port number

### Examples

```bash
# Use custom secrets file
./opencode-sandbox.sh --secrets-env /path/to/my-secrets.env

# Use custom port
./opencode-sandbox.sh --port 8080

# Combine options
./opencode-sandbox.sh --port 8080 --secrets-env ./my.env
```

## Updating

To update to a newer version:

```bash
# Rebuild and reload the image
./build-and-load-image.sh

# Restart your containers
msb stop opencode
./opencode-sandbox.sh
```

## Security Notes

- The containers run with elevated privileges (`SYS_ADMIN` capability) required for some PDF operations
- AppArmor is disabled for better compatibility
- **Secrets Management**: Store your `.env` file in a secure location and use `--secrets-env` to specify its path
- **Password Configuration**: Set `OPENCODE_PASSWORD` in your `.env` file for better security
- For production, use proper security measures and network isolation

## Troubleshooting

### Common issues

1. **PDF processing fails**: Ensure the container has proper permissions to access the files
2. **Memory issues**: Increase Docker's memory allocation if processing large files
3. **Missing fonts**: Install additional fonts by extending the Dockerfile

### View logs

```bash
# View all logs
msb logs opencode
```

### Shell access

```bash
# Access the container shell
msb exec -it opencode sh
```



## Customization

To add more tools or customize the setup:

1. Edit the `Dockerfile` to add additional packages
2. Rebuild and reload: `./BUILD_AND_LOAD_IMAGE.sh`
3. Restart your containers as needed

## Command Reference

### Starting OpenCode Sandbox

```bash
# Start with default configuration
./opencode-sandbox.sh

# Custom port
./opencode-sandbox.sh --port 3000

# Shell mode
./opencode-sandbox.sh --shell

# Custom secrets file
./opencode-sandbox.sh --secrets-env /path/to/secrets.env

# Disable project mounting
./opencode-sandbox.sh --no-mount
```

### Basic microsandbox commands

```bash
# List running containers
msb ps

# Stop a container
msb stop opencode

# Start a container
msb start opencode

# View logs
msb logs opencode

# Shell access
msb exec -it opencode sh
```

## License

This setup is provided as-is. The base OpenCode image follows its own licensing terms.

---

For more information about OpenCode, visit: https://github.com/anomalyco/opencode

For more information about microsandbox, check the microsandbox documentation.