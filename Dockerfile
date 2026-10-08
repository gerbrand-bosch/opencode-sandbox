# Dockerfile using Debian base image with OpenCode installed
FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install additional tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils \
    imagemagick \
    ghostscript \
    tesseract-ocr \
    libtesseract-dev \
    ffmpeg \
    libreoffice \
    pandoc \
    fonts-liberation \
    fonts-noto \
    fonts-noto-color-emoji \
    fonts-dejavu \
    fonts-liberation2 \
    && fc-cache -fv \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCode using the official installation script
RUN curl -fsSL https://opencode.ai/v2/install | bash


# Set environment variables for the tools
ENV PDFTOTEXT_PATH=/usr/bin/pdftotext
ENV MAGICK_HOME=/usr/lib/x86_64-linux-gnu/ImageMagick-6.9.7
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

# Set the working directory
WORKDIR /app

# Default command - will be overridden by the start-opencode.sh script
CMD ["bash"]
