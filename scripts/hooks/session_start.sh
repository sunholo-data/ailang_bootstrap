#!/bin/bash
# session_start.sh - Check for AILANG messages on session start
#
# This hook checks for unread messages from AILANG core and displays them
# in the Claude Code system reminder.
#
# Messages live in the CANONICAL store: prod Firestore (project ailang-multivac).
# Every machine reads and writes that one inbox.
#
# The default without these vars is this machine's LOCAL SQLite, which nobody else
# can see. Hooks do not inherit a login shell, so profile exports are not in scope
# here — pin the store explicitly. Measured 2026-08-26: reports from several
# projects sat unread in private local databases for months because this hook, and
# the skill beside it, read local only.
#
# Override with AILANG_MESSAGES_STORE=local to inspect this machine's private inbox.
export AILANG_MESSAGES_STORE="${AILANG_MESSAGES_STORE:-gcp}"
export AILANG_MESSAGES_PROJECT="${AILANG_MESSAGES_PROJECT:-ailang-multivac}"

# Don't exit on error - we want graceful handling
set +e

# Check if ailang CLI is available
if ! command -v ailang &> /dev/null; then
    # Silently exit if ailang not installed
    exit 0
fi

# A binary older than v0.34.0 ignores AILANG_MESSAGES_STORE silently: it reads local
# SQLite and exits 0, so the counts below would be local-only with no error anywhere.
# Control: an INVALID value must be REFUSED by a current binary.
STORE_NOTE=""
if AILANG_MESSAGES_STORE=__invalid__ ailang messages list --unread >/dev/null 2>&1; then
    STORE_NOTE=" (LOCAL ONLY - ailang predates v0.34.0; upgrade to see the shared inbox)"
fi


# Count unread from the CLI's own summary line ("  Unread: N").
#
# The previous method was `grep -c "^msg_"`, which counted ZERO against any real
# inbox: listings render as "● [inbox] sender • time (id)" and never begin with
# msg_. That format assumption predates the current CLI, so the hook reported an
# empty inbox even when the store was right — two independent bugs stacked, and
# the store fix alone would not have surfaced anything. Measured 2026-08-26
# against 8 genuinely unread messages: old method 0, this method 8.
#
# Reads the summary rather than counting rows so it is not capped by the display
# limit, and needs no jq (this hook ships to end users).
count_unread() {
    printf '%s\n' "$1" | sed -n 's/^[[:space:]]*Unread:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -1
}

# Get current project name dynamically
# Use CLAUDE_PROJECT_DIR if available, otherwise use current directory
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    PROJECT_NAME=$(basename "$CLAUDE_PROJECT_DIR")
else
    PROJECT_NAME=$(basename "$(pwd)")
fi

# Check for unread messages in the project inbox
PROJECT_OUTPUT=$(ailang messages list --unread --inbox "$PROJECT_NAME" 2>/dev/null)
UNREAD_COUNT=$(count_unread "$PROJECT_OUTPUT")
UNREAD_COUNT=${UNREAD_COUNT:-0}

if [ "$UNREAD_COUNT" -gt 0 ] 2>/dev/null; then
    echo ""
    echo "=== AILANG Messages for $PROJECT_NAME ==="
    echo "You have $UNREAD_COUNT unread message(s) from AILANG core.$STORE_NOTE"
    echo ""
    echo "To read messages:"
    echo "  ailang messages list --unread --inbox $PROJECT_NAME"
    echo "  ailang messages read MSG_ID"
    echo ""
    echo "To acknowledge:"
    echo "  ailang messages ack MSG_ID"
    echo "  ailang messages ack --all --inbox $PROJECT_NAME"
    echo ""
fi

# Also check the 'user' inbox (general messages)
USER_OUTPUT=$(ailang messages list --unread --inbox user 2>/dev/null)
USER_UNREAD=$(count_unread "$USER_OUTPUT")
USER_UNREAD=${USER_UNREAD:-0}

if [ "$USER_UNREAD" -gt 0 ] 2>/dev/null; then
    echo ""
    echo "=== General Messages ==="
    echo "You have $USER_UNREAD unread message(s) in your inbox."
    echo ""
    echo "  ailang messages list --unread --inbox user"
    echo ""
fi

exit 0
