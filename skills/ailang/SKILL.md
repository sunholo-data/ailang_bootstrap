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

## Practical Examples

Offer to create these working examples for users:

| Example | What It Does | Run Command |
|---------|--------------|-------------|
| **AI Debate** | AI models debate a topic | `ailang run --caps IO,Env,AI --ai claude-haiku-4-5 --entry main ai_debate.ail` |
| **Ask AI** | Simple CLI Q&A tool | `ailang run --caps IO,AI --ai claude-haiku-4-5 --entry demo ask_ai.ail` |
| **File Summarizer** | Summarize files with AI | `ailang run --caps IO,FS,AI --ai gpt5-mini --entry demo summarize_file.ail` |
| **Game of Life** | Conway's simulation | `ailang run --caps IO --entry main game_of_life.ail` |

### AI Debate Example
```ailang
module my_debate
import std/ai (call)
import std/env (hasEnv)
import std/io (println)

export func main() -> () ! {IO, Env, AI} {
  println("=== AI Debate ===");
  let optimist = call("Argue FOR AI benefits in 2 sentences");
  println("Optimist: " ++ optimist);
  let skeptic = call("Argue AGAINST AI risks in 2 sentences");
  println("Skeptic: " ++ skeptic)
}
```

### File Summarizer Example
```ailang
module summarizer
import std/ai (call)
import std/fs (readFile)
import std/io (println)

export func main(path: string) -> () ! {IO, FS, AI} {
  let content = readFile(path);
  let summary = call("Summarize in 3 bullets: " ++ content);
  println(summary)
}
```

## When Stuck

- Run `ailang repl` for interactive testing
- See [common_patterns.md](resources/common_patterns.md) for patterns
- See [cli_reference.md](resources/cli_reference.md) for full CLI docs
- See [editor_support.md](resources/editor_support.md) for VS Code, Vim, Neovim setup
- Check the [ailang-debug](../ailang-debug/SKILL.md) skill for error fixes

## Done? Notify

```bash
ailang messages send user "Task completed" --from "my-agent" --title "Status"
```
