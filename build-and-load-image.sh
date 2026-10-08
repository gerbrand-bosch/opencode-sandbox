#!/bin/bash
# Script to build the custom OpenCode image and load it into microsandbox

set -e

echo "=== Building custom OpenCode image ==="
docker build -t opencode-tools:latest .

echo ""
echo "=== Saving image to tar file ==="
docker save opencode-tools:latest -o opencode-tools.tar

echo ""
echo "=== Loading image into microsandbox ==="
msb load -i opencode-tools.tar

echo ""
echo "=== Cleaning up tar file ==="
rm -f opencode-tools.tar

echo ""
echo "✅ Image successfully loaded into microsandbox as 'opencode-tools:latest'"