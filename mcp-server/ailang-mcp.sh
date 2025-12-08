#!/usr/bin/env bash
# AILANG MCP Server - Simple shell-based implementation
# Executes AILANG CLI commands and returns results

set -uo pipefail

# Parse the tool call from stdin (JSON-RPC format)
# This is a simplified implementation for demonstration

TOOL="${1:-help}"
shift || true

case "$TOOL" in
  "check")
    FILE="${1:-}"
    if [[ -z "$FILE" ]]; then
      echo "Error: check requires a file path"
      exit 1
    fi
    ailang check "$FILE" 2>&1
    ;;

  "run")
    FILE="${1:-}"
    if [[ -z "$FILE" ]]; then
      echo "Error: run requires a file path"
      exit 1
    fi
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
    EXPR="${1:-}"
    if [[ -z "$EXPR" ]]; then
      echo "Error: eval requires an expression"
      exit 1
    fi
    echo "$EXPR" | ailang repl --non-interactive 2>&1 || echo "Expression: $EXPR"
    ;;

  "help"|*)
    echo "AILANG MCP Server"
    echo ""
    echo "Usage: ailang-mcp.sh <tool> [args...]"
    echo ""
    echo "Tools:"
    echo "  check <file>              Type-check an AILANG file"
    echo "  run <file> [caps] [entry] Run an AILANG program"
    echo "  prompt                    Get teaching prompt"
    echo "  builtins [search]         List builtin functions"
    echo "  eval <expr>               Evaluate expression in REPL"
    echo "  help                      Show this help"
    ;;
esac
