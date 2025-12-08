---
name: AILANG Development
description: Use AILANG for deterministic code synthesis and AI reasoning. Invoke when writing functional code, running programs, or communicating with other AI agents. Start by loading the teaching prompt with 'ailang prompt'.
---

# AILANG for AI Agents

AILANG is a deterministic programming language designed for AI code synthesis and reasoning.

## Session Start Routine

**At the start of every session:**

1. **Check for messages from other agents:**
```bash
ailang messages list --unread
```

2. **Load the teaching prompt** (essential for writing correct code):
```bash
ailang prompt
```

3. **Check AILANG is installed:**
```bash
ailang --version
```

## Writing AILANG Code

### Step 1: Load the Teaching Prompt

**CRITICAL:** Before writing any AILANG code, always load the current syntax:

```bash
ailang prompt
```

This provides:
- Current syntax rules
- Mandatory program structure
- Working examples
- Common pitfalls to avoid

### Step 2: Write Code Following the Template

**Every AILANG program MUST follow this structure:**

```ailang
module benchmark/solution

export func main() -> () ! {IO} {
  -- YOUR CODE HERE
}
```

### Step 3: Run and Iterate

```bash
# Type-check first (fast feedback)
ailang check program.ail

# Run with required capabilities
ailang run --caps IO --entry main program.ail

# Interactive development
ailang repl
```

## CLI Quick Reference

| Command | Purpose |
|---------|---------|
| `ailang prompt` | **Load syntax teaching prompt (DO THIS FIRST!)** |
| `ailang run --caps IO --entry main file.ail` | Run a program |
| `ailang repl` | Interactive REPL |
| `ailang check file.ail` | Type-check without running |
| `ailang watch file.ail` | Watch for changes |
| `ailang builtins list --by-module` | List all builtins |

**IMPORTANT:** Flags must come BEFORE the filename!
```bash
# Correct
ailang run --caps IO --entry main file.ail

# Wrong - flags are ignored!
ailang run file.ail --caps IO
```

## Agent Messaging

AILANG includes a cross-agent messaging system for autonomous workflows.

### Check Messages

```bash
# List all messages
ailang messages list

# Only unread messages
ailang messages list --unread

# Full content (no truncation)
ailang messages list --unread --full
```

### Send Messages

```bash
# Send to user inbox
ailang messages send user "Task completed" --title "Status Update" --from "my-agent"

# Send to another agent
ailang messages send sprint-executor '{"status": "ready"}' --from "planner"
```

### Acknowledge Messages

```bash
# Mark as read
ailang messages ack MSG_ID

# Mark all as read
ailang messages ack --all
```

## Capabilities

AILANG uses capability-based security. Programs must declare required effects:

| Capability | Purpose | Example |
|------------|---------|---------|
| `IO` | Console I/O | `println`, `readLine` |
| `FS` | File system | `readFile`, `writeFile` |
| `Net` | Network | `httpGet`, `httpPost` |
| `Clock` | Time | `now`, `sleep` |
| `AI` | AI oracle | `AI.call(prompt)` |

```bash
# Enable multiple capabilities
ailang run --caps IO,FS,Net --entry main server.ail
```

## Key Syntax Rules

1. **Use `func` not `fn` or `function` or `def`**
2. **Semicolons between statements in blocks**
3. **Pattern matching uses `=>`** (not `:` or `->`)
4. **No loops** - Use recursion instead
5. **Everything is immutable**

### Quick Examples

**Print a value:**
```ailang
print(show(42))  -- Use show() to convert to string
```

**Pattern match on list:**
```ailang
match xs {
  [] => 0,
  hd :: tl => hd + sum(tl)
}
```

**Record update:**
```ailang
{person | age: person.age + 1}
```

## Available Resources

- [`resources/syntax_quick_ref.md`](resources/syntax_quick_ref.md) - Syntax reference
- [`resources/cli_reference.md`](resources/cli_reference.md) - Full CLI documentation
- [`resources/common_patterns.md`](resources/common_patterns.md) - Patterns and mistakes

## Workflow Summary

```
1. Check messages     → ailang messages list --unread
2. Load prompt        → ailang prompt
3. Write code         → Follow template from prompt
4. Type-check         → ailang check file.ail
5. Run                → ailang run --caps IO --entry main file.ail
6. Iterate            → Fix errors, re-run
7. Send completion    → ailang messages send user "Done" --from "agent"
```

## Installation

If AILANG is not installed:

```bash
# Run install script
./skills/ailang/scripts/install.sh

# Or download from GitHub releases
# https://github.com/sunholo-data/ailang/releases
```

## Documentation

- Website: https://sunholo-data.github.io/ailang/
- GitHub: https://github.com/sunholo-data/ailang
- Examples: https://github.com/sunholo-data/ailang/tree/main/examples
