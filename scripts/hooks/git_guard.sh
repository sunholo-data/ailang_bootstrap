#!/bin/bash
# git_guard.sh — PreToolUse hook that enforces git guardrails for cloud agents
#
# Intercepts Bash tool calls containing git commands and validates them
# against the expected branch/repo for the current task.
#
# Environment variables (set by Cloud Run Job executor):
#   AILANG_GIT_MODE      - "guardrails" (default), "strict", or "permissive"
#   AILANG_PUSH_BRANCH   - Expected push branch (e.g., "main")
#   AILANG_TASK_ID       - Task ID (for coordinator/{taskID} branch name)
#   AILANG_BRANCH        - Base branch that was cloned
#
# IMPORTANT: This script must work WITHOUT jq (not installed in agent container).
# Uses grep/sed for JSON parsing instead. Also avoids grep -P (Perl regex)
# since it may not be available on Debian slim.
#
# Exit codes:
#   0 - Allow (no output) or Deny (with JSON permissionDecision)
#   Non-zero - Hook error (non-blocking, logged in verbose mode)
#
# When not in cloud mode (AILANG_GIT_MODE not set), this hook is a no-op.

# ─── Early exit: not in cloud mode ───────────────────────────────────────────
GIT_MODE="${AILANG_GIT_MODE:-}"
if [ -z "$GIT_MODE" ]; then
  exit 0  # Local dev — no guardrails
fi

# ─── Read hook payload from stdin ────────────────────────────────────────────
INPUT=$(cat)

# Extract tool_name from JSON without jq (look for "tool_name": "...")
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# Only gate Bash tool calls
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

# Extract command from tool_input.command (look for "command": "...")
# Handle escaped quotes and newlines in the command value
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
if [ -z "$COMMAND" ]; then
  exit 0
fi

# ─── Check if command contains git ───────────────────────────────────────────
# Quick exit for non-git commands (vast majority of Bash calls)
if ! echo "$COMMAND" | grep -qw 'git'; then
  exit 0
fi

# ─── Environment ─────────────────────────────────────────────────────────────
PUSH_BRANCH="${AILANG_PUSH_BRANCH:-}"
TASK_ID="${AILANG_TASK_ID:-}"
BASE_BRANCH="${AILANG_BRANCH:-dev}"

# Derive expected branch: push branch if set, otherwise coordinator/{taskID}
if [ -n "$PUSH_BRANCH" ]; then
  EXPECTED_BRANCH="$PUSH_BRANCH"
elif [ -n "$TASK_ID" ]; then
  EXPECTED_BRANCH="coordinator/$TASK_ID"
else
  EXPECTED_BRANCH=""
fi

# ─── Helper: emit deny response (no jq needed) ──────────────────────────────
deny() {
  local reason="$1"
  # Escape any double quotes and backslashes in the reason for valid JSON
  reason=$(echo "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
  cat <<DENY_EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"${reason}"}}
DENY_EOF
  exit 0
}

# ─── Permissive mode: only block force push and hard reset ───────────────────
if [ "$GIT_MODE" = "permissive" ]; then
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+push[[:space:]].*(-f|--force)'; then
    deny "BLOCKED: Force push is never allowed. Use regular 'git push' instead."
  fi
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard'; then
    deny "BLOCKED: 'git reset --hard' destroys uncommitted work. Use 'git stash' or 'git checkout -- <file>' for specific files."
  fi
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f'; then
    deny "BLOCKED: 'git clean -f' permanently deletes untracked files. Remove specific files instead."
  fi
  exit 0
fi

# ─── Strict mode: block all git write operations ────────────────────────────
if [ "$GIT_MODE" = "strict" ]; then
  # Allow read-only operations
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+(status|diff|log|show|ls-files|rev-parse|describe|shortlog|blame|reflog)'; then
    exit 0
  fi
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+branch[[:space:]]*$'; then
    exit 0
  fi
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+branch[[:space:]]+(-a|--all|-r|--remotes|-v|--verbose|-l|--list)'; then
    exit 0
  fi
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+remote[[:space:]]+(-v|show)'; then
    exit 0
  fi
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+config[[:space:]]+--get'; then
    exit 0
  fi
  deny "BLOCKED: In strict git mode, only read-only git commands are allowed (status, diff, log, show, branch). The executor handles all git write operations after your session."
fi

# ─── Guardrails mode (default): smart validation ────────────────────────────

# ── ALWAYS BLOCKED: force push ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+push[[:space:]].*(-f|--force|--force-with-lease)'; then
  deny "BLOCKED: Force push is never allowed. The executor handles git push after your session."
fi

# ── ALWAYS BLOCKED: hard reset ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard'; then
  deny "BLOCKED: 'git reset --hard' destroys uncommitted work. Use 'git stash' to save work, or 'git checkout -- <file>' to discard specific files."
fi

# ── ALWAYS BLOCKED: clean -f ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f'; then
  deny "BLOCKED: 'git clean -f' permanently deletes untracked files."
fi

# ── BLOCKED: branch creation ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+(checkout|switch)[[:space:]]+(-b|-c|--create)[[:space:]]'; then
  deny "BLOCKED: Creating new branches is not allowed. Work on the current branch ('$EXPECTED_BRANCH'). The executor manages branch creation."
fi

# ── BLOCKED: switching branches (but allow checkout -- <file>) ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+checkout[[:space:]]+[a-zA-Z]' ; then
  # Allow: git checkout -- <file> (restore file)
  if ! echo "$COMMAND" | grep -qE 'git[[:space:]]+checkout[[:space:]]+--[[:space:]]'; then
    deny "BLOCKED: Switching branches is not allowed. Stay on '$EXPECTED_BRANCH'. Use 'git checkout -- <file>' to discard changes to a specific file."
  fi
fi
if echo "$COMMAND" | grep -qE 'git[[:space:]]+switch[[:space:]]+[a-zA-Z]'; then
  if ! echo "$COMMAND" | grep -qE 'git[[:space:]]+switch[[:space:]]+(-c|--create)'; then
    deny "BLOCKED: Switching branches is not allowed. Stay on '$EXPECTED_BRANCH'."
  fi
fi

# ── BLOCKED: branch deletion ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+branch[[:space:]]+(-d|-D|--delete)[[:space:]]'; then
  deny "BLOCKED: Deleting branches is not allowed. The executor manages branch lifecycle."
fi

# ── VALIDATED: git push (only to expected branch) ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+push'; then
  if [ -z "$EXPECTED_BRANCH" ]; then
    deny "BLOCKED: git push is not allowed — the executor will push your changes after your session completes. Just commit locally and the executor handles the rest."
  fi
  # Just "git push" or "git push origin" with no branch — allowed
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+push[[:space:]]*$'; then
    exit 0
  fi
  if echo "$COMMAND" | grep -qE 'git[[:space:]]+push[[:space:]]+origin[[:space:]]*$'; then
    exit 0
  fi
  # Pushing to the expected branch — allowed
  if echo "$COMMAND" | grep -qE "git[[:space:]]+push[[:space:]]+[^[:space:]]+[[:space:]]+${EXPECTED_BRANCH}"; then
    exit 0
  fi
  # Pushing to a different branch — blocked
  deny "BLOCKED: git push to a different branch is not allowed. You can only push to '$EXPECTED_BRANCH'. The executor handles git push after your session — just commit locally."
fi

# ── BLOCKED: remote manipulation ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+remote[[:space:]]+(add|set-url|rename|remove|rm)[[:space:]]'; then
  deny "BLOCKED: Modifying git remotes is not allowed."
fi

# ── BLOCKED: rebase and merge ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+(rebase|merge)[[:space:]]'; then
  deny "BLOCKED: git rebase/merge can cause conflicts that waste agent turns. The executor handles branch integration after your session."
fi

# ── BLOCKED: cherry-pick, revert ──
if echo "$COMMAND" | grep -qE 'git[[:space:]]+(cherry-pick|revert)[[:space:]]'; then
  deny "BLOCKED: git cherry-pick/revert can cause unexpected merge state. Commit your changes directly instead."
fi

# ── Default: allow (git status, diff, log, add, commit, stash, etc.) ──
exit 0
