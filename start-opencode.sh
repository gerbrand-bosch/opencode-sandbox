#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(pwd)"
SANDBOX="opencode-$(basename "$PROJECT_DIR")"
IMAGE="opencode-tools:latest"
ENVFILE=".env"
PORT=50000
NO_MOUNT=false
SHELL_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --no-mount | -n)
    NO_MOUNT=true
    shift
    ;;
  --shell | -s)
    SHELL_MODE=true
    shift
    ;;
  --port | -p)
    if [[ -n "${2:-}" && "$2" != -* ]]; then
      PORT="$2"
      shift 2
    else
      echo "Error: --port requires a port number"
      echo "Usage: $0 [--no-mount|-n] [--shell|-s] [--port|-p PORT]"
      exit 1
    fi
    ;;
  *)
    echo "Unknown argument: $1"
    echo "Usage: $0 [--no-mount|-n] [--shell|-s] [--port|-p PORT]"
    exit 1
    ;;
  esac
done

# If custom port is specified, validate it's a number between 1024 and 65535
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
  echo "Error: Port must be a number between 1024 and 65535"
  exit 1
fi

# Check if image is loaded
if ! msb images | grep -q "opencode-tools"; then
  echo "❌ opencode-tools image not found. Please run build-and-load-image.sh first."
  exit 1
fi

# Load environment variables if .env file exists
if [ -f "$ENVFILE" ]; then
  set -a
  . "$ENVFILE"
  set +a
fi

# Build the mount arguments
MOUNT_ARGS=()
if [ "$NO_MOUNT" = false ]; then
  MOUNT_ARGS+=(--mount-dir "$PROJECT_DIR":/app)
fi
MOUNT_ARGS+=(--mount-dir "$PROJECT_DIR/data":/app/data)
MOUNT_ARGS+=(--mount-dir "$PROJECT_DIR/config":/app/config)

# Start the container
echo "=== Starting OpenCode container ==="
echo "Using image: $IMAGE"
echo "Web interface port: $PORT"
echo "Access at: http://localhost:$PORT"

if [ "$SHELL_MODE" = true ]; then
  echo "Starting shell mode..."
  exec msb run "$IMAGE" --name "$SANDBOX" --replace \
    "${MOUNT_ARGS[@]}" \
    -e NODE_ENV=production \
    -e OPENCODE_API_KEY=${OPENCODE_API_KEY:-} \
    -e OPENCODE_WEB_PASSWORD=${OPENCODE_WEB_PASSWORD:-} \
    --cap-add SYS_ADMIN \
    --device /dev/fuse:/dev/fuse \
    --security-opt apparmor=unconfined \
    --entrypoint /bin/sh
else
  echo "Starting OpenCode server..."
  exec msb run "$IMAGE" --name "$SANDBOX" --replace \
    "${MOUNT_ARGS[@]}" \
    -e NODE_ENV=production \
    -e OPENCODE_API_KEY=${OPENCODE_API_KEY:-} \
    -e OPENCODE_WEB_PASSWORD=${OPENCODE_WEB_PASSWORD:-} \
    --cap-add SYS_ADMIN \
    --device /dev/fuse:/dev/fuse \
    --security-opt apparmor=unconfined \
    --entrypoint start \
    --script start="
      cd /app
      
      # Start OpenCode server
      export OPENCODE_PASSWORD=''
      export OPENCODE_SERVER_PASSWORD=''
      opencode serve --hostname 0.0.0.0 --port ${PORT} > /tmp/opencode-serve.log 2>&1 &
      SERVER_PID=$!

      # wait until the log says it's listening (POSIX-safe)
      i=0
      until grep -q 'server listening on' /tmp/opencode-serve.log 2>/dev/null; do
        kill -0 "$SERVER_PID" 2>/dev/null || {
          echo 'serve died:' >&2; cat /tmp/opencode-serve.log >&2; exit 1
        }
        i=$((i + 1))
        [ $i -gt 30 ] && { echo 'timeout waiting for serve' >&2; exit 1; }
        sleep 1
      done
      echo 'server is up'

      exec opencode --server "http://127.0.0.1:${PORT}"
    " \
    -p "$PORT:$PORT"
fi
