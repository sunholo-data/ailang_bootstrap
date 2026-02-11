# AILANG CLI Reference (v0.7.3)

> **Note:** Run `ailang --help` for the most current command list.
> This reference is auto-synced from the main AILANG repo on each release.

## Core Commands

### `ailang run`
Run an AILANG program.

```bash
ailang run [flags] <file.ail>
```

**Flags (must come BEFORE filename!):**
| Flag | Description |
|------|-------------|
| `--caps <list>` | Enable capabilities: IO, FS, Net, Clock, AI, Env, Debug, Rand |
| `--entry <name>` | Entrypoint function (default: main) |
| `--args-json <json>` | JSON arguments to pass to entrypoint |
| `--trace` | Enable execution tracing |
| `--print` | Print return value (default: true) |
| `--no-print` | Suppress output (exit code only) |
| `--relax-modules` | Allow module path mismatch |
| `--ai <model>` | AI model for AI effect (e.g., claude-haiku-4-5, gpt5-mini) |
| `--net-allow <hosts>` | Allowlist for Net capability (comma-separated hostnames) |
| `--net-timeout <dur>` | Timeout for HTTP requests (e.g., 30s) |
| `--debug-compile` | Show compilation phase timing |

**Examples:**
```bash
# Basic run with IO
ailang run --caps IO --entry main hello.ail

# Multiple capabilities
ailang run --caps IO,FS,Net --entry main server.ail

# Pass arguments
ailang run --caps IO --entry main --args-json '{"name":"Alice"}' greet.ail

# AI call with specific model
ailang run --caps IO,AI --ai claude-haiku-4-5 --entry main ai_demo.ail

# HTTP with allowlist
ailang run --caps IO,Net --net-allow=httpbin.org --entry main http.ail
```

### `ailang repl`
Start interactive REPL.

```bash
ailang repl
```

**REPL Commands:**
| Command | Description |
|---------|-------------|
| `:help` | Show help |
| `:type <expr>` | Show type of expression |
| `:quit` | Exit REPL |
| `:load <file>` | Load file into REPL |
| `:reset` | Clear REPL state |

### `ailang check`
Type-check without running.

```bash
ailang check <file.ail>
ailang check --timeout 30s <file.ail>    # With timeout (detects hangs)
ailang check --debug-compile <file.ail>  # Show phase timing
```

### `ailang watch`
Watch for changes and auto-reload.

```bash
ailang watch <file.ail>
```

### `ailang prompt`
Display teaching prompt for AI code generation.

```bash
ailang prompt                    # Current version
ailang prompt --version v0.7.3   # Specific version
ailang prompt --list             # List all versions
```

### `ailang examples` (v0.6.2+)
Search and view working code examples.

```bash
# Search examples (flags BEFORE query!)
ailang examples search "pattern matching"
ailang examples search --limit 5 "recursion"
ailang examples search --json "fold"

# List examples
ailang examples list                    # All working examples
ailang examples list --tags adt         # Filter by tag
ailang examples list --status all       # Include broken

# View specific example
ailang examples show adt_option         # Show with metadata
ailang examples show adt_option --run   # Show and execute
ailang examples show fold --expected    # Show expected output only

# List available tags
ailang examples tags
```

## Chain Execution Monitoring (v0.7.2+)

### `ailang chains`
View past and current agent execution chains. Works offline (direct SQLite).

```bash
# List chains
ailang chains list                       # All chains (most recent first)
ailang chains list --status active       # Filter by status
ailang chains list --agent design-doc-creator  # Filter by agent
ailang chains list --since 24h           # Created after time window
ailang chains list --json                # JSON output

# Active chains
ailang chains active                     # Currently running chains

# View chain details
ailang chains view <chain-id>            # Chain + stages overview
ailang chains view <chain-id> --spans    # Include session/tool details
ailang chains tree <chain-id>            # ASCII tree of chain hierarchy

# View changes
ailang chains diff <chain-id>            # Git diff across all stages

# Find chain by reference
ailang chains find --task-id <task-id>
ailang chains find --message-id <uuid>
ailang chains find --github owner/repo#123

# Cost & token stats
ailang chains stats                      # All-time summary
ailang chains stats --by-agent           # Breakdown by agent

# Diagnostics
ailang chains diagnose <chain-id>        # Health report for chain
ailang chains health                     # System-wide validation
```

## Coordinator Daemon (v0.6.1+)

### `ailang coordinator`
Manage the autonomous task delegation daemon.

```bash
# Lifecycle
ailang coordinator start                 # Start daemon
ailang coordinator stop                  # Stop daemon
ailang coordinator status                # Check if running

# Task management
ailang coordinator pending               # View pending approvals
ailang coordinator logs <task-id>        # View task logs
ailang coordinator diff <task-id>        # View git changes

# Approval
ailang coordinator approve <task-id>
ailang coordinator reject <task-id> --feedback "reason"
```

## Server (Collaboration Hub)

### `ailang serve`
Start the Collaboration Hub server.

```bash
ailang serve                    # Default port 1957
ailang serve --port 8080        # Custom port
ailang serve --db /tmp/test.db  # Custom database
```

### `ailang serve-api`
Start API-only server (no UI).

```bash
ailang serve-api --port 8080
```

## Development Tools

### `ailang builtins`
Manage builtin functions.

```bash
ailang builtins list             # List all builtins
ailang builtins list --by-module # Group by module
ailang builtins list --verbose   # Full docs with examples
ailang builtins check-migration  # Check for issues
```

### `ailang doctor`
Diagnostic tools.

```bash
ailang doctor builtins  # Validate builtin registry
```

### `ailang test`
Run test suite (including inline tests).

```bash
ailang test <file.ail>
```

### `ailang iface`
Output module interface (JSON).

```bash
ailang iface <module>
```

## Messages (Cross-Agent Communication)

### `ailang messages`
Manage agent-to-agent messages.

```bash
# List and read
ailang messages list                 # All messages
ailang messages list --unread        # Unread only
ailang messages read <id>            # Read message

# Send
ailang messages send <inbox> "message" --title "Title" --from "agent"

# Acknowledge
ailang messages ack <id>             # Mark as read
ailang messages ack --all            # Mark all as read

# Search
ailang messages search "query"       # Semantic search
ailang messages search --neural "query"  # Neural search (Ollama)

# GitHub sync
ailang messages send user "Bug" --type bug  # Auto-creates GitHub issue
ailang messages import-github               # Import issues as messages
```

## Eval Tools (AI Benchmarking)

### `ailang eval-suite`
Run AI code generation benchmarks.

```bash
ailang eval-suite                          # Dev models (fast)
ailang eval-suite --full                   # All models
ailang eval-suite --models gpt5,claude-sonnet-4-5
ailang eval-suite --skip-existing          # Resume interrupted run
```

### `ailang eval-report`
Generate benchmark reports.

```bash
ailang eval-report <results-dir> <version> --format=json
ailang eval-report <results-dir> <version> --format=markdown
```

### `ailang eval-compare`
Compare two baseline results.

```bash
ailang eval-compare <baseline1-dir> <baseline2-dir>
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `AILANG_RELAX_MODULES` | Set to `1` to relax module path matching |
| `ANTHROPIC_API_KEY` | API key for AI effect with Claude models |
| `OPENAI_API_KEY` | API key for AI effect with OpenAI models |
| `DEBUG_STRICT` | Set to `1` for strict error handling |
| `DEBUG_PARSER` | Set to `1` for parser tracing |
| `DEBUG_MONO_VERBOSE` | Set to `1` for monomorphization tracing |
| `DEBUG_CODEGEN` | Set to `1` for codegen warnings |
