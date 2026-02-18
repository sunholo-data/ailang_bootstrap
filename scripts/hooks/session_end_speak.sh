#!/usr/bin/env bash
# Claude Code Stop hook — speak gives a voice debrief
#
# Summarizes Claude's last response and current git status via speak.
#
# Runs on: Claude Code Stop event
# Receives JSON on stdin: {session_id, transcript_path, stop_hook_active, cwd, ...}
#
# Serializes overlapping sessions with a lockfile.

set -euo pipefail

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Prevent infinite loops
STOP_HOOK_ACTIVE=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('stop_hook_active', False))" 2>/dev/null || echo "False")
if [ "$STOP_HOOK_ACTIVE" = "True" ]; then
  exit 0
fi

# Check speak is available
if ! command -v speak &>/dev/null; then
  exit 0
fi

# --- Extract last Claude response from transcript ---
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('transcript_path', ''))" 2>/dev/null || echo "")
CWD=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('cwd', ''))" 2>/dev/null || echo "$(pwd)")

LAST_CLAUDE_MSG=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  LAST_CLAUDE_MSG=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1 | python3 -c "
import sys, json
d = json.loads(sys.stdin.read().strip())
content = d.get('message', {}).get('content', [])
texts = []
for c in content:
    if isinstance(c, dict) and c.get('type') == 'text':
        texts.append(c['text'])
full = ' '.join(texts)
# Truncate to keep prompt reasonable
print(full[:600])
" 2>/dev/null || echo "")
fi

# --- Lockfile: serialize overlapping sessions ---
LOCKDIR="$HOME/.ailang/speak/hook.lock"
MAX_WAIT=50

acquire_lock() {
  local waited=0
  while ! mkdir "$LOCKDIR" 2>/dev/null; do
    if [ -f "$LOCKDIR/pid" ]; then
      local lock_pid
      lock_pid=$(cat "$LOCKDIR/pid" 2>/dev/null || echo "")
      if [ -n "$lock_pid" ] && ! kill -0 "$lock_pid" 2>/dev/null; then
        rm -rf "$LOCKDIR"
        continue
      fi
    fi
    sleep 1
    waited=$((waited + 1))
    if [ "$waited" -ge "$MAX_WAIT" ]; then
      return 1
    fi
  done
  echo $$ > "$LOCKDIR/pid"
  return 0
}

release_lock() { rm -rf "$LOCKDIR"; }

if ! acquire_lock; then
  exit 0
fi
trap release_lock EXIT

# --- Resolve speak session ---
if git rev-parse --show-toplevel &>/dev/null; then
  PROJECT="$(basename "$(git rev-parse --show-toplevel)")"
else
  PROJECT="$(basename "$(pwd)")"
fi

SESSIONS_ROOT="$HOME/.ailang/speak/sessions"
SESSION_DIR="$SESSIONS_ROOT/$PROJECT"
TURN_TEXT="$SESSION_DIR/turn_text.txt"

# --- Build prompt ---
DIR_NAME=$(basename "$CWD")

if [ -n "$LAST_CLAUDE_MSG" ]; then
  PROMPT="Claude Code session just ended in the ${DIR_NAME} directory. Here is what Claude last said: '${LAST_CLAUDE_MSG}'. Give a concise 2-3 sentence spoken summary of what Claude did, then check git status and mention any uncommitted changes. Keep it under 20 seconds."
else
  PROMPT="Claude Code session just ended in the ${DIR_NAME} directory. Check git status and give a brief spoken summary of the current state. Keep it under 15 seconds."
fi

# --- Run speak + print transcript ---
# speak uses `exec` internally so we run it in a subshell to regain control
> "$TURN_TEXT" 2>/dev/null || true

(speak --tools "$PROMPT")

# Show transcript as macOS notification (hook stdout isn't displayed by Claude Code)
if [ -f "$TURN_TEXT" ] && [ -s "$TURN_TEXT" ]; then
  DEBRIEF=$(cat "$TURN_TEXT")
  osascript -e "display notification \"$DEBRIEF\" with title \"speak debrief\"" 2>/dev/null || true
fi
