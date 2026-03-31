#!/bin/bash
# brain_session.sh - Inject relevant brain context at session start
#
# User-level SessionStart hook — works in any git project.
# Queries the brain for knowledge relevant to recent work and injects
# it into the Claude Code system reminder.

set +e  # Don't exit on error — graceful degradation

# Check if brain hooks are disabled
if [ "${AILANG_BRAIN_HOOKS:-1}" = "0" ]; then
    exit 0
fi

# Check if ailang is available
if ! command -v ailang &> /dev/null; then
    exit 0
fi

# Check if any brain DB exists (graceful bootstrap)
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if [ ! -f "$PROJECT_ROOT/.ailang/state/brain.db" ] && [ ! -f "$HOME/.ailang/state/brain.db" ]; then
    exit 0
fi

# Must be in a git repo for context queries
if ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    exit 0
fi

# Get recently modified files for context query
RECENT_FILES=$(git diff --name-only HEAD~3 HEAD 2>/dev/null | head -5 | tr '\n' ',' | sed 's/,$//')

BRAIN_RESULTS=""
if [ -n "$RECENT_FILES" ]; then
    BRAIN_RESULTS=$(ailang cache search --context "$RECENT_FILES" --limit 3 2>/dev/null || echo "")
fi

# Also search based on current branch/task
BRANCH_NAME=$(git branch --show-current 2>/dev/null || echo "")
if [ -n "$BRANCH_NAME" ] && [ "$BRANCH_NAME" != "dev" ] && [ "$BRANCH_NAME" != "main" ] && [ "$BRANCH_NAME" != "master" ]; then
    BRANCH_RESULTS=$(ailang cache search "${BRANCH_NAME//-/ }" --limit 2 2>/dev/null || echo "")
    if [ -n "$BRANCH_RESULTS" ] && ! echo "$BRANCH_RESULTS" | grep -q "No results"; then
        BRAIN_RESULTS="${BRAIN_RESULTS}
${BRANCH_RESULTS}"
    fi
fi

# Only output if we got results
if [ -n "$BRAIN_RESULTS" ] && ! echo "$BRAIN_RESULTS" | grep -q "No results"; then
    # Filter to just the result lines (skip metadata)
    FILTERED=$(echo "$BRAIN_RESULTS" | grep -E '^\s+[0-9]+\.|^\s+[0-9]+[dhm] ago' | head -6)
    if [ -n "$FILTERED" ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🧠 BRAIN: Relevant knowledge for this session"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$FILTERED"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
fi

exit 0
