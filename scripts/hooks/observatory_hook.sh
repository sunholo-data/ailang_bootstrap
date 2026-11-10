#!/usr/bin/env bash
# observatory_hook.sh — Forward Claude Code hook events to AILANG Observatory
#
# Called by command hooks in .claude-plugin/hooks/hooks.json
# Reads hook payload from stdin, POSTs to ${AILANG_OBSERVATORY_URL}/api/hooks/claude
#
# Usage: observatory_hook.sh <event_type>
#   event_type: SessionStart, PreToolUse, PostToolUse, PostToolUseFailure,
#               SubagentStart, SubagentStop, Stop
#
# Environment:
#   AILANG_OBSERVATORY_URL  — Dashboard URL (default: http://localhost:1957)
#   AILANG_TASK_ID          — Current task ID
#   AILANG_CHAIN_ID         — Current chain ID
#   AILANG_STAGE_ID         — Current stage ID
#   AILANG_MESSAGE_ID       — Original message ID
#   AILANG_HUB_TOKEN        — Dashboard ingest secret; sent as X-AILANG-Ingest-Token
#                             when set (a non-loopback dashboard enforcing ingest
#                             auth refuses /api/hooks/claude writes without it)

URL="${AILANG_OBSERVATORY_URL:-http://localhost:1957}"
EVENT_TYPE="${1:-unknown}"

# Ingest auth header only when the token is set; otherwise no header at all.
# Expanded as ${AUTH_HEADER[@]+...} so an empty array is safe on bash 3.2.
AUTH_HEADER=()
if [ -n "${AILANG_HUB_TOKEN:-}" ]; then
  AUTH_HEADER=(-H "X-AILANG-Ingest-Token: ${AILANG_HUB_TOKEN}")
fi

# Skip if no observatory configured
[ -z "$URL" ] && exit 0

# Read hook payload from stdin (Claude passes JSON via stdin for command hooks)
PAYLOAD=$(cat 2>/dev/null || echo '{}')

# POST to observatory — fire-and-forget, never block Claude
curl -s -m 4 -X POST "${URL}/api/hooks/claude" \
  -H "Content-Type: application/json" ${AUTH_HEADER[@]+"${AUTH_HEADER[@]}"} \
  -H "X-Ailang-Event-Type: ${EVENT_TYPE}" \
  -H "X-Ailang-Task-Id: ${AILANG_TASK_ID:-}" \
  -H "X-Ailang-Chain-Id: ${AILANG_CHAIN_ID:-}" \
  -H "X-Ailang-Stage-Id: ${AILANG_STAGE_ID:-}" \
  -H "X-Ailang-Message-Id: ${AILANG_MESSAGE_ID:-}" \
  -d "$PAYLOAD" >/dev/null 2>&1 || true

exit 0
