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
# Exit codes:
#   0 - Allow (no output) or Deny (with JSON permissionDecision)
#   Non-zero - Hook error (non-blocking, logged in verbose mode)
#
# When not in cloud mode (AILANG_GIT_MODE not set), this hook is a no-op.

set -euo pipefail

# ─── Early exit: not in cloud mode ───────────────────────────────────────────
GIT_MODE="${AILANG_GIT_MODE:-}"
if [ -z "$GIT_MODE" ]; then
  exit 0  # Local dev — no guardrails
fi

# ─── Read hook payload from stdin ────────────────────────────────────────────
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# Only gate Bash tool calls
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
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

# ─── Helper: emit deny response ─────────────────────────────────────────────
deny() {
  local reason="$1"
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# ─── Permissive mode: only block force push and hard reset ───────────────────
if [ "$GIT_MODE" = "permissive" ]; then
  if echo "$COMMAND" | grep -qP 'git\s+push\s+.*(-f|--force)'; then
    deny "BLOCKED: Force push is never allowed. Use regular 'git push' instead."
  fi
  if echo "$COMMAND" | grep -qP 'git\s+reset\s+--hard'; then
    deny "BLOCKED: 'git reset --hard' destroys uncommitted work. Use 'git stash' or 'git checkout -- <file>' for specific files."
  fi
  if echo "$COMMAND" | grep -qP 'git\s+clean\s+-[a-zA-Z]*f'; then
    deny "BLOCKED: 'git clean -f' permanently deletes untracked files. Remove specific files instead."
  fi
  exit 0
fi

# ─── Strict mode: block all git write operations ────────────────────────────
if [ "$GIT_MODE" = "strict" ]; then
  # Allow read-only operations
  if echo "$COMMAND" | grep -qP '^\s*git\s+(status|diff|log|show|branch\b(?!\s+-[dDmM])(?!\s+\S)|ls-files|rev-parse|describe|shortlog|blame|reflog|remote\s+-v|config\s+--get)'; then
    exit 0
  fi
  # Allow git branch (list only, no args that create/delete)
  if echo "$COMMAND" | grep -qP '^\s*git\s+branch\s*$'; then
    exit 0
  fi
  # Block everything else
  deny "BLOCKED: In strict git mode, only read-only git commands are allowed (status, diff, log, show, branch). The executor handles all git write operations after your session."
fi

# ─── Guardrails mode (default): smart validation ────────────────────────────

# Extract individual git commands from chained commands (&&, ||, ;)
# We check each segment that contains 'git'
check_git_segment() {
  local segment="$1"

  # Trim leading whitespace
  segment=$(echo "$segment" | sed 's/^[[:space:]]*//')

  # ── Always allowed: read-only operations ──
  if echo "$segment" | grep -qP 'git\s+(status|diff|log|show|ls-files|rev-parse|describe|shortlog|blame|reflog)'; then
    return 0
  fi

  # ── Always allowed: staging and committing (local operations) ──
  if echo "$segment" | grep -qP 'git\s+(add|commit|stash|restore|rm\s)'; then
    return 0
  fi

  # ── Always allowed: git config (read) ──
  if echo "$segment" | grep -qP 'git\s+config\s+--get'; then
    return 0
  fi

  # ── Always allowed: listing branches ──
  if echo "$segment" | grep -qP 'git\s+branch\s*$' || echo "$segment" | grep -qP 'git\s+branch\s+(-a|--all|-r|--remotes|-v|--verbose|-l|--list)'; then
    return 0
  fi

  # ── Always allowed: remote -v (listing) ──
  if echo "$segment" | grep -qP 'git\s+remote\s+(-v|show)'; then
    return 0
  fi

  # ── Always allowed: fetch (read-only from remote) ──
  if echo "$segment" | grep -qP 'git\s+fetch'; then
    return 0
  fi

  # ── ALWAYS BLOCKED: force push ──
  if echo "$segment" | grep -qP 'git\s+push\s+.*(-f|--force|--force-with-lease)'; then
    deny "BLOCKED: Force push is never allowed. The executor handles git push after your session."
    return 1
  fi

  # ── ALWAYS BLOCKED: hard reset ──
  if echo "$segment" | grep -qP 'git\s+reset\s+--hard'; then
    deny "BLOCKED: 'git reset --hard' destroys uncommitted work. Use 'git stash' to save work, or 'git checkout -- <file>' to discard specific files."
    return 1
  fi

  # ── ALWAYS BLOCKED: clean -f ──
  if echo "$segment" | grep -qP 'git\s+clean\s+-[a-zA-Z]*f'; then
    deny "BLOCKED: 'git clean -f' permanently deletes untracked files."
    return 1
  fi

  # ── BLOCKED: branch creation ──
  if echo "$segment" | grep -qP 'git\s+(checkout|switch)\s+(-b|-c|--create)\s'; then
    deny "BLOCKED: Creating new branches is not allowed. Work on the current branch ('$EXPECTED_BRANCH'). The executor manages branch creation."
    return 1
  fi

  # ── BLOCKED: switching branches ──
  if echo "$segment" | grep -qP 'git\s+(checkout|switch)\s+(?!--)(?!-p)(?!-q)\S'; then
    # Allow: git checkout -- <file> (restore file), git checkout -p (patch mode)
    # Block: git checkout <branch-name>
    if ! echo "$segment" | grep -qP 'git\s+(checkout)\s+--\s'; then
      deny "BLOCKED: Switching branches is not allowed. Stay on '$EXPECTED_BRANCH'. Use 'git checkout -- <file>' to discard changes to a specific file."
      return 1
    fi
  fi

  # ── BLOCKED: branch deletion ──
  if echo "$segment" | grep -qP 'git\s+branch\s+(-d|-D|--delete)\s'; then
    deny "BLOCKED: Deleting branches is not allowed. The executor manages branch lifecycle."
    return 1
  fi

  # ── VALIDATED: git push (only to expected branch) ──
  if echo "$segment" | grep -qP 'git\s+push'; then
    if [ -z "$EXPECTED_BRANCH" ]; then
      deny "BLOCKED: git push is not allowed — the executor will push your changes after your session completes. Just commit locally and the executor handles the rest."
      return 1
    fi
    # Check if pushing to the expected branch
    if echo "$segment" | grep -qP "git\s+push\s+\S+\s+$EXPECTED_BRANCH\b"; then
      return 0  # Pushing to expected branch — allowed
    fi
    # Just "git push" with no branch specified — allowed (pushes current branch)
    if echo "$segment" | grep -qP 'git\s+push\s*$' || echo "$segment" | grep -qP 'git\s+push\s+origin\s*$'; then
      return 0  # Default push — allowed
    fi
    # Pushing to a different branch
    deny "BLOCKED: git push to a different branch is not allowed. You can only push to '$EXPECTED_BRANCH'. The executor handles git push after your session — just commit locally."
    return 1
  fi

  # ── BLOCKED: remote manipulation ──
  if echo "$segment" | grep -qP 'git\s+remote\s+(add|set-url|rename|remove|rm)\s'; then
    deny "BLOCKED: Modifying git remotes is not allowed."
    return 1
  fi

  # ── BLOCKED: rebase and merge (can cause conflicts the AI wastes turns on) ──
  if echo "$segment" | grep -qP 'git\s+(rebase|merge)\s'; then
    deny "BLOCKED: git rebase/merge can cause conflicts that waste agent turns. The executor handles branch integration after your session."
    return 1
  fi

  # ── BLOCKED: cherry-pick, revert (can cause unexpected state) ──
  if echo "$segment" | grep -qP 'git\s+(cherry-pick|revert)\s'; then
    deny "BLOCKED: git cherry-pick/revert can cause unexpected merge state. Commit your changes directly instead."
    return 1
  fi

  # ── Default: allow unknown git subcommands (future-proof) ──
  return 0
}

# Split command on && || ; and check each segment containing 'git'
# Use a simple approach: replace delimiters with newlines and check each line
echo "$COMMAND" | tr '&' '\n' | tr '|' '\n' | tr ';' '\n' | while IFS= read -r segment; do
  if echo "$segment" | grep -qw 'git'; then
    check_git_segment "$segment"
  fi
done

exit 0
