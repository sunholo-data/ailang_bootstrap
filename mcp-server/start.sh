#!/bin/bash
# Start the AILANG MCP server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v node >/dev/null 2>&1; then
    echo "AILANG MCP requires Node.js 18 or newer: https://nodejs.org/" >&2
    exit 1
fi

exec node "$SCRIPT_DIR/server.js"
