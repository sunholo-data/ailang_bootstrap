# AILANG Bootstrap

Quick start package for using AILANG with Claude Code and OpenAI Codex.

AILANG is a deterministic programming language designed for AI code synthesis and reasoning.

## Installation

Install the AILANG CLI before installing either agent integration:

```bash
curl -fsSL https://ailang.sunholo.com/install.sh | bash
ailang --version
```

The plugins invoke the local `ailang` executable, so it must be available on
`PATH`.

### Claude Code

```bash
# Step 1: Add the marketplace
/plugin marketplace add sunholo-data/ailang_bootstrap

# Step 2: Install the plugin
/plugin install ailang@sunholo-data/ailang_bootstrap
```

Or clone and add locally:

```bash
git clone https://github.com/sunholo-data/ailang_bootstrap
/plugin marketplace add ./ailang_bootstrap
/plugin install ailang@ailang_bootstrap
```

### OpenAI Codex

Codex requires Node.js 18 or newer for the local MCP server:

```bash
node --version
codex plugin marketplace add sunholo-data/ailang_bootstrap --ref stable
codex plugin add ailang@ailang-marketplace
codex plugin list
```

Start a new Codex session after installation. Alternatively, add the marketplace
with the CLI, then install AILANG through `/plugins` or the Codex desktop
Plugins directory.

Codex loads the shared skills and five local MCP tools:
`ailang_prompt`, `ailang_check`, `ailang_run`, `ailang_builtins`, and
`ailang_eval`.

### Manual Installation

Download a platform-specific release from [GitHub Releases](https://github.com/sunholo-data/ailang_bootstrap/releases):

| Platform | Architecture | Asset |
|----------|-------------|-------|
| macOS | Apple Silicon | `darwin.arm64.ailang-bootstrap.tar.gz` |
| macOS | Intel | `darwin.x64.ailang-bootstrap.tar.gz` |
| Linux | x64 | `linux.x64.ailang-bootstrap.tar.gz` |
| Windows | x64 | `win32.x64.ailang-bootstrap.zip` |

Each release includes the AILANG binary pre-bundled.

## What's Included

### Skills

| Skill | Purpose |
|-------|---------|
| **ailang** | Write, run, and develop with AILANG |
| **ailang-debug** | Error recovery and debugging help |
| **ailang-inbox** | Cross-agent messaging with semantic search, deduplication, and GitHub sync |

### Slash Commands (Claude Code)

| Command | Purpose |
|---------|---------|
| `/ailang-prompt` | Load syntax teaching prompt (do this first!) |
| `/ailang-run <file>` | Run an AILANG program |
| `/ailang-check <file>` | Type-check without running |
| `/ailang-new <name> [template]` | Create new program from template |
| `/ailang-repl` | Start interactive REPL |
| `/ailang-builtins [search]` | List builtin functions |
| `/ailang-editor <editor>` | Install syntax highlighting |

### Hooks (Claude Code)

| Hook | Event | Purpose |
|------|-------|---------|
| `session_start.sh` | SessionStart | Inbox check + brain context |
| `brain_session.sh` | SessionStart | Inject relevant brain knowledge |
| `git_guard.sh` | PreToolUse(Bash) | Block destructive git ops |
| `microrag_context.sh` | PreToolUse(Edit\|Write\|Read\|MultiEdit) | JIT μRAG knowledge injection — surfaces AILANG syntax/builtin docs at tool-call time |
| `microrag_lint.sh` | PostToolUse(Edit\|Write\|MultiEdit) | First-use builtin nudge for `*.ail` edits |
| `brain_resolution.sh` | PostToolUse(Bash) | Capture command resolutions |
| `observatory_hook.sh` | All events | OTEL telemetry for AILANG Observatory |

**Disable μRAG**: `export AILANG_MICRORAG_ENABLED=0`. Requires `ailang` and `jq` on PATH; degrades silently if either is missing.

**μRAG brain corpus auto-bootstrap**: `install.sh` runs `ailang micro-rag init && ailang micro-rag bootstrap --scope user --no-embed` after the binary lands. This populates the brain DB at `~/.ailang/state/brain.db` with the `ailang-syntax` (~50 frames) and `ailang-builtins` (~280 frames) namespaces using only resources embedded in the binary — no source repo required. Works on Windows / minimal Docker images / anywhere `awk` and `python3` are absent.

Re-run manually after `install.sh` to upgrade the corpus to embedding-backed retrieval (requires Ollama):

```bash
ailang micro-rag bootstrap --scope user           # add embeddings on top of SimHash/FTS
ailang micro-rag bootstrap --scope user --reset   # full rebuild (use after AILANG version bump)
```

### MCP Servers (TWO complementary servers)

**1. Local stdio MCP** (auto-installed by this plugin) — wraps the local AILANG CLI for actually running/checking code:
- `ailang_check` - Type-check files
- `ailang_run` - Run programs
- `ailang_prompt` - Get teaching prompt (embedded copy)
- `ailang_builtins` - List builtins
- `ailang_eval` - Evaluate an expression in the non-interactive REPL

**2. Remote HTTP MCP at `mcp.ailang.sunholo.com`** — version-locked live docs, stdlib, examples, design docs, benchmarks. Available to any agent harness that supports remote MCP (Claude Desktop, Cursor, Cline, Continue, Claude Code).

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

Tools include `prompt_get`, `stdlib_modules`, `stdlib_search`, `examples_for_concept`, `limitations_list`, `effects_catalog`, and `submit_feedback` (for filing AILANG bugs from inside an agent session). Use these to **avoid stale embedded knowledge** — the snapshot is rebuilt and redeployed on every AILANG release.

See [docs/guides/agent-mcp](https://ailang.sunholo.com/docs/guides/agent-mcp) for the full tool catalog.

## Quick Start

Once installed, you can:

```bash
# CRITICAL: Load syntax before writing code
ailang prompt

# Run AILANG code
ailang run --caps IO --entry main program.ail

# Start interactive REPL
ailang repl

# Type-check without running
ailang check program.ail
```

## Example AILANG Program

```ailang
module myproject/hello

export func main() -> () ! {IO} {
  print("Hello, AILANG!")
}
```

Run with:
```bash
ailang run --caps IO --entry main hello.ail
```

## Key Syntax Rules

1. **Use `func`** - NOT `fn`, `function`, or `def`
2. **Semicolons between statements** - `let x = 1; let y = 2; x + y`
3. **Pattern matching uses `=>`** - NOT `:` or `->`
4. **No loops** - Use recursion instead
5. **`print` expects string** - Use `print(show(42))` for numbers

## Documentation

- [AILANG Website](https://sunholo-data.github.io/ailang/)
- [AILANG GitHub](https://github.com/sunholo-data/ailang)
- [Examples](https://github.com/sunholo-data/ailang/tree/main/examples)

## Repository Structure

```
ailang_bootstrap/
├── .claude-plugin/
│   ├── plugin.json         # Claude Code plugin manifest
│   └── marketplace.json    # Skills marketplace
├── .codex-plugin/
│   └── plugin.json         # Codex plugin manifest
├── .mcp.json               # Codex MCP configuration
├── .claude/commands/       # Slash commands
│   ├── ailang-run.md
│   ├── ailang-check.md
│   ├── ailang-new.md
│   └── ...
├── mcp-server/             # MCP server for AILANG tools
│   ├── server.js
│   └── package.json
├── skills/
│   ├── ailang/             # Main AILANG skill
│   │   ├── SKILL.md
│   │   └── resources/
│   ├── ailang-debug/       # Debug skill
│   │   ├── SKILL.md
│   │   └── resources/
│   └── ailang-inbox/       # Agent messaging skill
│       └── SKILL.md
├── bin/                    # AILANG binary (in releases)
└── .github/workflows/
    └── release.yml         # Platform-specific release builds
```

## License

MIT License - see [LICENSE](LICENSE)
