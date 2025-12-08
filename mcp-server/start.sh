#!/bin/bash
# Start the AILANG MCP server
# This script ensures dependencies are installed before running

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if node_modules exists, if not install
if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
    cd "$SCRIPT_DIR"
    npm install --silent 2>/dev/null
fi

# Run the server
exec node "$SCRIPT_DIR/server.js"
