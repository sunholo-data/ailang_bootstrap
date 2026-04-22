#!/usr/bin/env bash
# microrag_context.sh — PreToolUse hook for Edit | Write | Read | MultiEdit
#
# Just-in-time knowledge injection on tool calls. Shells into
# `ailang micro-rag context` and wraps the resulting injection
# in a Claude Code additionalContext envelope.
#
# Engine handles all the heavy lifting (glob routing, cache search,
# token-window dedup, relevance filtering, session budget). This
# script is a thin shim; on any error it exits 0 silently so the
# tool call is never blocked.
#
# Master switch: set AILANG_MICRORAG_ENABLED=0 to disable entirely.
# Per-engine env vars (passed through):
#   AILANG_MICRORAG_ROUTES   namespace allowlist
#   AILANG_MICRORAG_DRYRUN   1 = log only, no injection
#   AILANG_MICRORAG_SESSION  session id (defaults to CLAUDE_SESSION_ID)

set +e

# Master switch
[ "${AILANG_MICRORAG_ENABLED:-1}" = "0" ] && exit 0

# Required tools
command -v ailang >/dev/null 2>&1 || exit 0
command -v jq     >/dev/null 2>&1 || exit 0

# Stable session id so the engine's dedup ledger is contiguous
# across hook invocations within a Claude Code session.
if [ -z "${AILANG_MICRORAG_SESSION:-}" ] && [ -n "${CLAUDE_SESSION_ID:-}" ]; then
    export AILANG_MICRORAG_SESSION="$CLAUDE_SESSION_ID"
fi

HOOK_JSON=$(cat 2>/dev/null || echo "{}")
TOOL_NAME=$(echo "$HOOK_JSON" | jq -r '.tool_name // ""' 2>/dev/null)
case "$TOOL_NAME" in
    Edit|Write|Read|MultiEdit) ;;
    *) exit 0 ;;
esac

FILE_PATH=$(echo "$HOOK_JSON" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# Cheap exclusions before reaching the engine
case "$FILE_PATH" in
    */node_modules/*|*/.git/*|*/vendor/*|*/__pycache__/*) exit 0 ;;
    *.png|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.webp)          exit 0 ;;
    *.pdf|*.wasm|*.bin|*.exe|*.dylib|*.so)                exit 0 ;;
    *.zip|*.tar|*.gz|*.bz2)                               exit 0 ;;
esac

# Pull the content the tool will write/edit so the engine can build a
# meaningful retrieval query. Fields differ by tool.
case "$TOOL_NAME" in
    Write)     CONTENT=$(echo "$HOOK_JSON" | jq -r '.tool_input.content // ""' 2>/dev/null) ;;
    Edit)      CONTENT=$(echo "$HOOK_JSON" | jq -r '.tool_input.new_string // ""' 2>/dev/null) ;;
    MultiEdit) CONTENT=$(echo "$HOOK_JSON" | jq -r '[.tool_input.edits[]?.new_string] | join("\n")' 2>/dev/null) ;;
    Read)      CONTENT="" ;;
esac

# Truncate giant contents to keep argv small
if [ "${#CONTENT}" -gt 4096 ]; then
    CONTENT="${CONTENT:0:4096}"
fi

# Build args; only pass --content when non-empty (prevents shell quoting issues)
ARGS=(micro-rag context --tool "$TOOL_NAME" --file "$FILE_PATH")
if [ -n "$CONTENT" ]; then
    ARGS+=(--content "$CONTENT")
fi

# Bound execution; engine should respond well under 1s on cache hit.
# Prefer GNU timeout (gtimeout on macOS via coreutils); fall back to
# unbounded call if neither is available.
if command -v gtimeout >/dev/null 2>&1; then
    RESULT=$(gtimeout 3s ailang "${ARGS[@]}" 2>/dev/null)
elif command -v timeout >/dev/null 2>&1; then
    RESULT=$(timeout 3s ailang "${ARGS[@]}" 2>/dev/null)
else
    RESULT=$(ailang "${ARGS[@]}" 2>/dev/null)
fi
[ -z "$RESULT" ] && exit 0

# Validate envelope shape and pull injection_text
INJECTION_TEXT=$(echo "$RESULT" | jq -r '.injection.injection_text // ""' 2>/dev/null)
[ -z "$INJECTION_TEXT" ] && exit 0

# Wrap as Claude Code PreToolUse additionalContext
jq -n --arg ctx "$INJECTION_TEXT" '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        additionalContext: $ctx
    }
}' 2>/dev/null

exit 0
