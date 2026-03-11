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

URL="${AILANG_OBSERVATORY_URL:-http://localhost:1957}"
EVENT_TYPE="${1:-unknown}"

# Skip if no observatory configured
[ -z "$URL" ] && exit 0

# Read hook payload from stdin (Claude passes JSON via stdin for command hooks)
PAYLOAD=$(cat 2>/dev/null || echo '{}')

# POST to observatory — fire-and-forget, never block Claude
curl -s -m 4 -X POST "${URL}/api/hooks/claude" \
  -H "Content-Type: application/json" \
  -H "X-Ailang-Event-Type: ${EVENT_TYPE}" \
  -H "X-Ailang-Task-Id: ${AILANG_TASK_ID:-}" \
  -H "X-Ailang-Chain-Id: ${AILANG_CHAIN_ID:-}" \
  -H "X-Ailang-Stage-Id: ${AILANG_STAGE_ID:-}" \
  -H "X-Ailang-Message-Id: ${AILANG_MESSAGE_ID:-}" \
  -d "$PAYLOAD" >/dev/null 2>&1 || true

exit 0
