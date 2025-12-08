---
name: Agent Inbox
description: Check and process messages from autonomous AILANG agents. Use when starting a session, after agent handoffs, or when checking for completion notifications from AI agents.
---

# Agent Inbox

Check for messages from autonomous agents at session start and process completion notifications.

## Quick Start

```bash
# Check for messages in user inbox
ailang agent inbox user

# Show only unread messages (flags BEFORE agent ID!)
ailang agent inbox --unread-only user

# Show full message content (no truncation)
ailang agent inbox --full user

# Archive messages after processing
ailang agent inbox --archive user
```

## When to Use This Skill

Invoke this skill when:
- **Session starts** - Check for agent messages
- **After handoffs** - When you've sent work to autonomous agents
- **Periodic checks** - User asks "any updates from agents?"
- **Debugging** - To see agent communication history

## Commands

### Check Inbox

```bash
# View all messages (auto-marks as read)
ailang agent inbox user

# Show only unread messages
ailang agent inbox --unread-only user

# Show full message content (no truncation)
ailang agent inbox --full user

# Full content, limited to 5 messages
ailang agent inbox --full --limit 5 user

# Show archived messages
ailang agent inbox --archived user

# Archive messages after viewing
ailang agent inbox --archive user
```

### Send Messages

```bash
# Send to user inbox (for agent → user communication)
ailang agent send --to-user --from "agent-name" '{"message": "Task complete"}'

# Send to specific agent
ailang agent send agent-name '{"task": "do_something"}'
```

## Workflow

### 1. Session Start Check

At the start of each session:
```bash
ailang agent inbox user
```

If messages exist:
1. Read and summarize each message
2. Identify message type (completion, error, handoff)
3. Ask user if they want action taken
4. Archive after handling: `ailang agent inbox --archive user`

### 2. Process Completion Notifications

```bash
# 1. Check messages with full payload
ailang agent inbox --full --unread-only user

# 2. Review results based on payload
# 3. Report to user
# 4. Archive after processing
ailang agent inbox --archive user
```

### 3. Handle Errors

```bash
# 1. Check messages for error details
ailang agent inbox --full --unread-only user

# 2. Review logs if specified in payload
# 3. Diagnose and report to user
```

## Message Types

### Completion Notification
```json
{
  "type": "sprint_complete",
  "from": "sprint-executor",
  "payload": {
    "result": "All tests passing",
    "artifacts": ["results/"]
  }
}
```

### Error Report
```json
{
  "type": "error",
  "from": "agent-name",
  "payload": {
    "error": "Tests failing",
    "details": "path/to/logs"
  }
}
```

## CLI Flags

**IMPORTANT: Flags must come BEFORE the agent ID!**

| Flag | Description |
|------|-------------|
| `--full` | Show full message content without truncation |
| `--unread-only` | Show only unread messages |
| `--read-only` | Show only already-read messages |
| `--archived` | Show archived messages |
| `--archive` | Move messages to archive after viewing |
| `--limit N` | Maximum number of messages (default: 10) |

## Notes

- **Inbox location**: `~/.ailang/state/messages/inbox/user/`
- **Auto-marking**: Messages automatically marked as read when viewed
- **Message lifecycle**: Unread → Read → Archived
