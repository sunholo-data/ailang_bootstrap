#!/usr/bin/env bash
# Check for messages in AILANG agent inbox

set -euo pipefail

INBOX="${1:-user}"

if ! command -v ailang &> /dev/null; then
    echo "AILANG is not installed" >&2
    echo "Run: ./skills/ailang/scripts/install.sh" >&2
    exit 1
fi

echo "Checking inbox: $INBOX"
ailang agent inbox --unread-only "$INBOX"
