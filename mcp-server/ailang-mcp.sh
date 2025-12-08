#!/usr/bin/env bash
# AILANG MCP Server - Simple shell-based implementation
# Executes AILANG CLI commands and returns results

set -euo pipefail

# Parse the tool call from stdin (JSON-RPC format)
# This is a simplified implementation for demonstration

TOOL="$1"
shift

case "$TOOL" in
  "check")
    FILE="$1"
    ailang check "$FILE" 2>&1
    ;;

  "run")
    FILE="$1"
    CAPS="${2:-IO}"
    ENTRY="${3:-main}"
    ailang run --caps "$CAPS" --entry "$ENTRY" "$FILE" 2>&1
    ;;

  "prompt")
    ailang prompt 2>&1
    ;;

  "builtins")
    SEARCH="${1:-}"
    BY_MODULE="${2:-false}"
    if [[ -n "$SEARCH" ]]; then
      ailang builtins list 2>&1 | grep -i "$SEARCH" || echo "No matches for: $SEARCH"
    elif [[ "$BY_MODULE" == "true" ]]; then
      ailang builtins list --by-module 2>&1
    else
      ailang builtins list 2>&1
    fi
    ;;

  "eval")
    EXPR="$1"
    echo "$EXPR" | ailang repl --non-interactive 2>&1 || echo "Expression: $EXPR"
    ;;

  *)
    echo "Unknown tool: $TOOL"
    echo "Available tools: check, run, prompt, builtins, eval"
    exit 1
    ;;
esac
