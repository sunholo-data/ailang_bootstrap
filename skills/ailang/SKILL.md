---
name: AILANG
description: Write AILANG code. ALWAYS run 'ailang prompt' first - it contains the current syntax rules and templates.
---

# AILANG

## BEFORE YOU WRITE ANY CODE

**Run this command first** - it outputs the current syntax rules and templates:

```bash
ailang prompt
```

This is the source of truth for AILANG syntax. Do not guess at syntax.

## Session Start

```bash
# 1. Check for messages from other agents
ailang messages list --unread

# 2. Load current syntax (CRITICAL!)
ailang prompt

# 3. Verify AILANG is installed
ailang --version
```

## Development Workflow

```
┌──────────────────────────────────────┐
│ 1. Run: ailang prompt                │
│    Read the template and examples    │
└──────────────────────────────────────┘
                 ↓
┌──────────────────────────────────────┐
│ 2. Write code following template     │
│    module myproject/mymodule         │
│    export func main() -> () ! {IO}   │
└──────────────────────────────────────┘
                 ↓
┌──────────────────────────────────────┐
│ 3. Type-check (fast feedback)        │
│    ailang check file.ail             │
└──────────────────────────────────────┘
                 ↓
┌──────────────────────────────────────┐
│ 4. Run with capabilities             │
│    ailang run --caps IO --entry main │
└──────────────────────────────────────┘
                 ↓
        Fix errors, repeat
```

## CLI Quick Reference

| Command | Purpose |
|---------|---------|
| `ailang prompt` | **Load syntax (DO THIS FIRST!)** |
| `ailang check file.ail` | Type-check without running |
| `ailang run --caps IO --entry main file.ail` | Run program |
| `ailang repl` | Interactive testing |
| `ailang builtins list --by-module` | List all builtins |

**Flags MUST come before filename:**
```bash
ailang run --caps IO --entry main file.ail   # Correct
ailang run file.ail --caps IO                # WRONG
```

## Capabilities

| Cap | Purpose |
|-----|---------|
| `IO` | Console I/O |
| `FS` | File system |
| `Net` | HTTP requests |
| `Clock` | Time functions |
| `AI` | AI oracle |

## When Stuck

- Run `ailang repl` for interactive testing
- See [common_patterns.md](resources/common_patterns.md) for patterns
- See [cli_reference.md](resources/cli_reference.md) for full CLI docs
- Check the [ailang-debug](../ailang-debug/SKILL.md) skill for error fixes

## Done? Notify

```bash
ailang messages send user "Task completed" --from "my-agent" --title "Status"
```
