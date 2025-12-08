#!/bin/bash
# session_start.sh - Check for AILANG messages on session start
#
# This hook checks for unread messages from AILANG core and displays them
# in the Claude Code system reminder.
#
# Messages are stored locally in ~/.ailang/state/messages.db
# Note: Cloud messaging is not yet implemented - messages only work locally.

# Don't exit on error - we want graceful handling
set +e

# Check if ailang CLI is available
if ! command -v ailang &> /dev/null; then
    # Silently exit if ailang not installed
    exit 0
fi

# Get current project name dynamically
# Use CLAUDE_PROJECT_DIR if available, otherwise use current directory
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    PROJECT_NAME=$(basename "$CLAUDE_PROJECT_DIR")
else
    PROJECT_NAME=$(basename "$(pwd)")
fi

# Check for unread messages in the project inbox
PROJECT_OUTPUT=$(ailang messages list --unread --inbox "$PROJECT_NAME" 2>/dev/null)
UNREAD_COUNT=$(echo "$PROJECT_OUTPUT" | grep -c "^msg_" 2>/dev/null || true)
UNREAD_COUNT=${UNREAD_COUNT:-0}

if [ "$UNREAD_COUNT" -gt 0 ] 2>/dev/null; then
    echo ""
    echo "=== AILANG Messages for $PROJECT_NAME ==="
    echo "You have $UNREAD_COUNT unread message(s) from AILANG core."
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
USER_UNREAD=$(echo "$USER_OUTPUT" | grep -c "^msg_" 2>/dev/null || true)
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
