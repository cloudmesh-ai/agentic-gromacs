#!/bin/bash

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Absolute path to the servers directory
SERVERS_DIR="$(pwd)/mcp/servers"
CONFIG_FILE="$(pwd)/mcp/config_snippet.json"

if [ ! -d "$SERVERS_DIR" ]; then
    log_error "Servers directory not found at $SERVERS_DIR"
    exit 1
fi

log_info "Starting MCP server setup..."

# Initialize the config snippet
echo "{" > "$CONFIG_FILE"
echo "  \"mcpServers\": {" >> "$CONFIG_FILE"

FIRST=true

# Iterate through every subdirectory in mcp/servers/
for server_path in "$SERVERS_DIR"/*/; do
    # Remove trailing slash
    server_path="${server_path%/}"
    server_name=$(basename "$server_path")

    log_info "Processing server: $server_name"

    # Check if server.py exists
    SERVER_SCRIPT="$server_path/server.py"
    if [ ! -f "$SERVER_SCRIPT" ]; then
        log_warn "No server.py found in $server_path. Skipping."
        continue
    fi

    # Setup Virtual Environment
    VENV_DIR="$server_path/.venv"
    PYTHON_EXE="$VENV_DIR/bin/python"

    if [ ! -d "$VENV_DIR" ]; then
        log_info "Creating venv for $server_name..."
        python3 -m venv "$VENV_DIR" || { log_error "Failed to create venv for $server_name"; continue; }
    fi

    # Install dependencies
    REQUIREMENTS="$server_path/requirements.txt"
    if [ -f "$REQUIREMENTS" ]; then
        log_info "Installing dependencies for $server_name..."
        "$PYTHON_EXE" -m pip install --upgrade pip > /dev/null 2>&1
        "$PYTHON_EXE" -m pip install -r "$REQUIREMENTS" > /dev/null 2>&1 || { log_error "Failed to install dependencies for $server_name"; continue; }
    else
        log_warn "No requirements.txt found for $server_name. Skipping dependency installation."
    fi

    # Smoke Test
    log_info "Running smoke test for $server_name..."
    # Use background process and kill to simulate timeout on macOS
    "$PYTHON_EXE" "$SERVER_SCRIPT" > /dev/null 2>&1 &
    PID=$!
    sleep 2
    if ps -p $PID > /dev/null; then
        kill $PID 2>/dev/null
        log_success "Server $server_name started successfully (was running after 2s)."

        # Add to config snippet
        if [ "$FIRST" = false ]; then
            echo "    ," >> "$CONFIG_FILE"
        fi
        echo "    \"$server_name\": {" >> "$CONFIG_FILE"
        echo "      \"command\": \"$PYTHON_EXE\"," >> "$CONFIG_FILE"
        echo "      \"args\": [\"$SERVER_SCRIPT\"]" >> "$CONFIG_FILE"
        echo "    }" >> "$CONFIG_FILE"
        FIRST=false
    else
        # Process died before 2s. Get the exit code.
        wait $PID 2>/dev/null
        EXIT_CODE=$?
        log_error "Smoke test failed for $server_name: process exited prematurely with code $EXIT_CODE"
    fi
done

# Close the config snippet
echo "  }" >> "$CONFIG_FILE"
echo "}" >> "$CONFIG_FILE"

log_info "Setup complete. Config snippet generated at: $CONFIG_FILE"
log_info "You can copy-paste the content of $CONFIG_FILE into your claude_desktop_config.json"
