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

# Skip sub-agents — only debrief top-level sessions
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('transcript_path', ''))" 2>/dev/null || echo "")
if [[ "$TRANSCRIPT_PATH" == *"/agent-"* ]]; then
  exit 0
fi

# Clear any pending interaction alert for this session
SESSION_ID=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('session_id', 'default'))" 2>/dev/null || echo "default")
rm -f "$HOME/.ailang/speak/pending_${SESSION_ID}"
ALERT_PID_FILE="$HOME/.ailang/speak/alert_pid_${SESSION_ID}"
if [ -f "$ALERT_PID_FILE" ]; then
  pid=$(cat "$ALERT_PID_FILE" 2>/dev/null || echo "")
  [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  rm -f "$ALERT_PID_FILE"
fi

# --- Folder exclusion ---
CWD=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('cwd', ''))" 2>/dev/null || echo "$(pwd)")

# Default excludes: /tmp, /private/var (sandbox evals), eval directories
EXCLUDES="/tmp:/private/tmp:/private/var:/ailang_eval"

# Merge with env var if set
if [ -n "${CLAUDE_ALERT_EXCLUDE:-}" ]; then
  EXCLUDES="$EXCLUDES:$CLAUDE_ALERT_EXCLUDE"
fi

# Merge with global AILANG config file
CONF="$HOME/.ailang/config/hook_excludes.conf"
if [ -f "$CONF" ]; then
  while IFS= read -r pattern; do
    pattern=$(echo "$pattern" | sed 's/#.*//' | xargs)  # strip comments + trim
    [ -n "$pattern" ] && EXCLUDES="$EXCLUDES:$pattern"
  done < "$CONF"
fi

# Check if CWD matches any exclude pattern
if [ -n "$CWD" ]; then
  IFS=':' read -ra PATTERNS <<< "$EXCLUDES"
  for pat in "${PATTERNS[@]}"; do
    [ -z "$pat" ] && continue
    if [[ "$CWD" == *"$pat"* ]]; then
      exit 0
    fi
  done
fi

# Check speak is available
if ! command -v speak &>/dev/null; then
  exit 0
fi

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
if [ -n "$CWD" ] && git -C "$CWD" rev-parse --show-toplevel &>/dev/null 2>&1; then
  PROJECT="$(basename "$(git -C "$CWD" rev-parse --show-toplevel)")"
elif [ -n "$CWD" ]; then
  PROJECT="$(basename "$CWD")"
else
  PROJECT="$(basename "$(pwd)")"
fi

SESSIONS_ROOT="$HOME/.ailang/speak/sessions"
SESSION_DIR="$SESSIONS_ROOT/$PROJECT"
TURN_TEXT="$SESSION_DIR/turn_text.txt"
DEBRIEF_FILE="$SESSION_DIR/last_debrief.txt"

# --- Pre-fetch git status so speak doesn't need to tool-call for it ---
GIT_STATUS=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  GIT_STATUS=$(git -C "$CWD" status --short 2>/dev/null | head -20)
fi

# --- Build prompt ---
# Include git status inline so speak can just read it out (no tool call needed).
# Only mention git if there are changes to report.
GIT_SECTION=""
if [ -n "$GIT_STATUS" ]; then
  GIT_SECTION=" Git status: ${GIT_STATUS}. Briefly mention what files changed."
else
  GIT_SECTION=" Git is clean — no uncommitted changes."
fi

if [ -n "$LAST_CLAUDE_MSG" ]; then
  PROMPT="You are debriefing the ${PROJECT} project (${CWD}). Claude Code just finished. Claude's last response: '${LAST_CLAUDE_MSG}'. Summarise in 2 sentences what Claude did.${GIT_SECTION} Keep it under 20 seconds. Do NOT use tools — all info is provided."
else
  PROMPT="You are debriefing the ${PROJECT} project (${CWD}). Claude Code just finished.${GIT_SECTION} Give a brief summary. Keep it under 15 seconds. Do NOT use tools — all info is provided."
fi

# --- Run speak + print transcript ---
# speak uses `exec` internally so we run it in a subshell to regain control
> "$TURN_TEXT" 2>/dev/null || true

(speak "$PROMPT")

# --- Save debrief and show notification ---
if [ -f "$TURN_TEXT" ] && [ -s "$TURN_TEXT" ]; then
  DEBRIEF=$(cat "$TURN_TEXT")

  # Save full debrief to a file (clickable from notification via terminal-notifier)
  {
    echo "=== AILANG Debrief: ${PROJECT} ==="
    echo "Directory: ${CWD}"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "$DEBRIEF"
    echo ""
    if [ -n "$GIT_STATUS" ]; then
      echo "--- git status ---"
      echo "$GIT_STATUS"
    fi
  } > "$DEBRIEF_FILE"

  ICON="$HOME/.claude/hooks/assets/sunholo-logo.png"

  if command -v terminal-notifier &>/dev/null; then
    # terminal-notifier: rich notification
    #   -group: replaces previous notification for same project (no stacking)
    #   -appIcon: sunholo logo
    #   -execute: Quick Look the debrief on click (non-modal, dismisses with Esc)
    terminal-notifier \
      -title "AILANG: ${PROJECT}" \
      -subtitle "$(date '+%H:%M') — ${CWD}" \
      -message "$DEBRIEF" \
      -sound Glass \
      -appIcon "$ICON" \
      -group "ailang-debrief-${PROJECT}" \
      -execute "qlmanage -p '${DEBRIEF_FILE}' &>/dev/null &" \
      2>/dev/null || true
  else
    # osascript fallback (no click action — Apple limitation)
    SHORT_DEBRIEF="${DEBRIEF:0:200}"
    osascript -e "display notification \"$SHORT_DEBRIEF\" with title \"AILANG: ${PROJECT}\" subtitle \"${CWD}\" sound name \"Glass\"" 2>/dev/null || true
  fi
fi
