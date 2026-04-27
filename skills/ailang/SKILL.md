---
name: ailang
description: Write AILANG code. ALWAYS run 'ailang prompt' first - it contains the current syntax rules and templates.
---

# AILANG

## Source of Truth — TWO MCP Servers

**1. Local stdio MCP** (auto-installed by this plugin) — wraps the local AILANG CLI.
Tools: `ailang_check`, `ailang_run`, `ailang_repl`, etc. Use these to type-check
and run the user's code.

**2. Remote HTTP MCP at `mcp.ailang.sunholo.com`** — version-locked live docs,
stdlib, examples, design docs, benchmarks. **Prefer this for any reference
question** so you never get stale content.

If your harness supports remote MCP, the user can add it via the one-click
buttons at [ailang.sunholo.com](https://ailang.sunholo.com/), or paste:

```json
{
  "mcpServers": {
    "ailang-docs": {
      "url": "https://mcp.ailang.sunholo.com/mcp/",
      "transport": "streamable-http"
    }
  }
}
```

Useful remote tools (call these instead of guessing):

| Tool | When to call |
|---|---|
| `prompt_get(for_version, kind="agent")` | Need full syntax reference |
| `stdlib_modules(for_version)` | Discover what's in stdlib |
| `stdlib_module(name, for_version)` | Inspect a specific module's exports |
| `stdlib_search(query, for_version)` | Find a function by name or keyword |
| `examples_for_concept(concept, for_version)` | Find a working example for a feature |
| `limitations_list(for_version)` | Check what AILANG can't do before proposing it |
| `effects_catalog(for_version)` | Find which capability a function needs |
| `submit_feedback(...)` | File a bug / feature request mid-session |

If the remote MCP isn't reachable: `ailang prompt`, `ailang docs --list`, and
`ailang docs std/<module>` all work locally as the offline fallback.

## BEFORE YOU WRITE ANY CODE

```bash
ailang prompt          # current syntax (or call prompt_get via remote MCP)
ailang --version       # confirm CLI is installed
ailang messages list --unread   # any messages from other agents?
```

## Development Workflow

```
1. ailang prompt           → load syntax (do this once per session)
2. write code              → follow the template
3. ailang check file.ail   → type-check (fast feedback)
4. ailang run --caps IO --entry main file.ail  → run with capabilities
                             ↓
                       fix errors, repeat
```

## CLI Quick Reference

| Command | Purpose |
|---------|---------|
| `ailang prompt` | Load syntax (`--source mcp` to force fresh from remote MCP) |
| `ailang devtools-prompt` | Toolchain reference (debugging, tracing, eval, chains) |
| `ailang mcp status` | Check remote MCP reachability + drift |
| `ailang check file.ail` | Type-check without running |
| `ailang run --caps IO --entry main file.ail` | Run program (flags BEFORE filename!) |
| `ailang repl` | Interactive testing |
| `ailang docs --list` | List all stdlib modules (or call `stdlib_modules` via MCP) |
| `ailang docs std/<module>` | Show exports + signatures (or `stdlib_module` via MCP) |
| `ailang examples search "query"` | Find working examples (or `examples_for_concept` via MCP) |
| `ailang examples show NAME --run` | View + run example with expected output |
| `ailang search "query"` | Search package registry |
| `ailang install vendor/name` | Install a package |

**Critical:** `ailang run` flags MUST come before the filename:
```bash
ailang run --caps IO --entry main file.ail   # ✓
ailang run file.ail --caps IO                # ✗ flags ignored silently
```

## Capabilities (cheat sheet)

| Cap | Purpose | Example imports |
|---|---|---|
| `IO` | Console I/O | `println` (prelude), `print` |
| `FS` | File system | `readFile`, `writeFile` |
| `Net` | HTTP | `httpGet`, `httpPost` |
| `Clock` | Time | `now`, `sleep` |
| `AI` | LLM calls | `call(prompt)` |
| `Rand` | Random | `rand_int`, `rand_float` |
| `Env` | Env vars | `getEnv`, `getEnvOr` |
| `Debug` | Debug logging | `log`, `check` |

For the canonical list with introduction versions: call `effects_catalog` via remote MCP.

## Practical Examples

Offer to create one of these working examples for the user:

| Example | What | Run command |
|---|---|---|
| **AI Debate** | Two LLMs argue a topic | `ailang run --caps IO,Env,AI --ai claude-haiku-4-5 --entry main ai_debate.ail` |
| **Ask AI** | Simple CLI Q&A | `ailang run --caps IO,AI --ai claude-haiku-4-5 --entry demo ask_ai.ail` |
| **File Summarizer** | Summarize a file with AI | `ailang run --caps IO,FS,AI --ai gpt5-mini --entry demo summarize_file.ail` |
| **Game of Life** | Conway's simulation | `ailang run --caps IO --entry main game_of_life.ail` |

Quick AI Debate template:

```ailang
module my_debate
import std/ai (call)

export func main() -> () ! {IO, AI} {
  println("=== AI Debate ===");
  let optimist = call("Argue FOR AI benefits in 2 sentences");
  println("Optimist: ${optimist}");
  let skeptic = call("Argue AGAINST AI risks in 2 sentences");
  println("Skeptic: ${skeptic}")
}
```

## Packages & Registry

```bash
ailang search "auth"                        # discover
ailang pkg-docs sunholo/auth                # AI usage guide for a package
ailang install sunholo/auth@0.1.0           # install
ailang init package --name vendor/name      # create new package
ailang publish --dry-run                    # preview
ailang publish                              # ship
```

## When Stuck

- Call `examples_for_concept` via remote MCP, or `ailang examples search`
- Run `ailang devtools-prompt` for the full toolchain reference
- Run `ailang repl` for interactive testing
- Check the [ailang-debug](../ailang-debug/SKILL.md) skill for error diagnosis
- File a report from inside this session: call `submit_feedback` via remote MCP
- Docs: https://ailang.sunholo.com/

## Done? Notify

```bash
ailang messages send user "Task completed" --from "my-agent" --title "Status"
```

## Migration Note (M-AGENT-MCP)

This skill used to embed a long stdlib module table and version history that
went stale per release. The remote MCP server (`mcp.ailang.sunholo.com`) is
now the canonical source for all of that — it ships per-AILANG-release with
version-locked content. The local stdio MCP server bundled with this plugin
remains the way to actually run/check the user's code. See
[docs/guides/agent-mcp.md](https://ailang.sunholo.com/docs/guides/agent-mcp).
