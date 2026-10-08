#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(pwd)"
SANDBOX="opencode-$(basename "$PROJECT_DIR")"
#IMAGE="ghcr.io/anomalyco/opencode:2.0.23"
IMAGE="opencode-tools:latest"
ENVFILE="$HOME/.local/share/opencode-sandbox/config.env"
AGENTS="$HOME/.config/opencode/agents"
PORT=50001
NO_MOUNT=false
SHELL_MODE=false
CUSTOM_PORT=false
OPENCODE="/root/.opencode/bin/opencode"

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
      CUSTOM_PORT=true
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
if [ "$CUSTOM_PORT" = true ]; then
  if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
    echo "Error: Port must be a number between 1024 and 65535"
    exit 1
  fi
fi

[ -f "$ENVFILE" ] || {
  echo "Create $ENVFILE with MISTRAL_API_KEY first"
  exit 1
}
set -a
. "$ENVFILE"
set +a

# Build the mount arguments
MOUNT_ARGS=()
if [ "$NO_MOUNT" = false ]; then
  MOUNT_ARGS+=(--mount-dir "$PROJECT_DIR":/workspace)
fi
MOUNT_ARGS+=(--mount-dir "$AGENTS":/root/.config/opencode/agents:ro)

exec msb run "$IMAGE" --name "$SANDBOX" --replace \
  "${MOUNT_ARGS[@]}" \
  -e MISTRAL_API_KEY \
  -e OPENCODE_CONFIG_CONTENT="{\"model\":\"mistral/mistral-small-latest\"}" \
  --entrypoint start \
  --script start="
    mkdir -p /workspace
    cd /workspace
    
    if [ "$SHELL_MODE" = true ]; then
      # Shell mode - just start a shell
      echo 'Starting shell mode...'
      exec /bin/bash
    else
      # Normal mode - start OpenCode UI
      export OPENCODE_PASSWORD='blaat'
      export OPENCODE_SERVER_PASSWORD='blaat'
      $OPENCODE serve --hostname 0.0.0.0 --port ${PORT} > /tmp/opencode-serve.log 2>&1 &
      SERVER_PID=\$!

      # wait until the log says it's listening (POSIX-safe)
      i=0
      until grep -q 'server listening on' /tmp/opencode-serve.log 2>/dev/null; do
        kill -0 "\$SERVER_PID" 2>/dev/null || {
          echo 'serve died:' >&2; cat /tmp/opencode-serve.log >&2; exit 1
        }
        i=\$((i+1))
        [ \$i -gt 30 ] && { echo 'timeout waiting for serve' >&2; exit 1; }
        sleep 1
      done
      echo 'server is up'
      $OPENCODE --version

      exec $OPENCODE --server "http://127.0.0.1:${PORT}"
    fi
  " \
  -p "$PORT:$PORT"
