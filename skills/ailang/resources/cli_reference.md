# AILANG CLI Reference (v0.10.0)

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
ailang check src/                    # Type-check directory
ailang check --timeout 30s <file.ail>    # With timeout (detects hangs)
ailang check --debug-compile <file.ail>  # Show phase timing
```

### `ailang ai-check`
Unified check + verify with JSON output for AI agents.

```bash
ailang ai-check <file.ail>
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
ailang prompt --version v0.8.2   # Specific version
ailang prompt --list             # List all versions
```

### `ailang devtools-prompt`
Display full dev tools reference (debugging, tracing, eval, chains, coordinator).

```bash
ailang devtools-prompt
```

## Standard Library Docs

### `ailang docs`
Show stdlib module documentation.

```bash
ailang docs --list              # List all stdlib modules
ailang docs std/string          # Show module exports with signatures
ailang docs std/list            # Show list operations
ailang docs std/net             # Show network operations
```

**Available modules:**
`std/ai`, `std/array`, `std/bytes`, `std/clock`, `std/crypto`, `std/datetime`,
`std/debug`, `std/embedding`, `std/env`, `std/fs`, `std/game`, `std/io`,
`std/json`, `std/jwt`, `std/list`, `std/map`, `std/math`, `std/net`,
`std/option`, `std/process`, `std/rand`, `std/result`, `std/sem`,
`std/sharedindex`, `std/sharedmem`, `std/simhash`, `std/stream`

### `ailang builtins`
Manage builtin functions.

```bash
ailang builtins list             # List all builtins
ailang builtins list --by-module # Group by module
ailang builtins list --verbose   # Full docs with examples
ailang builtins check-migration  # Check for issues
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

## Packages & Registry

### `ailang search`
Search the AILANG package registry.

```bash
ailang search auth              # Search by keyword
ailang search --tag gcp         # Filter by tag
ailang search                   # List all packages
```

### `ailang install`
Install a package.

```bash
ailang install sunholo/auth@0.1.0   # Specific version
ailang install sunholo/auth         # Latest version
```

### `ailang publish`
Publish current package to the registry.

```bash
ailang publish --dry-run    # Preview first
ailang publish
```

### `ailang pkg-docs`
Display a package's AGENT.md (AI usage guide).

```bash
ailang pkg-docs sunholo/auth
```

### `ailang init package`
Create `ailang.toml` for a new package.

```bash
ailang init package --name vendor/name
```

### `ailang add`
Add a dependency.

```bash
ailang add --path ./local/pkg
ailang add --git https://github.com/org/repo
ailang add --registry vendor/name@0.1.0
```

### `ailang lock`
Resolve dependencies and generate lockfile.

```bash
ailang lock
```

### `ailang tree`
Show dependency tree.

```bash
ailang tree
```

### Package Coordination

```bash
# Notify dependents of an upgrade
ailang pkg notify-upgrade vendor/name@0.2.0

# List workspaces depending on a package
ailang pkg affected-by vendor/name
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
ailang chains tree <chain-id> --json     # Tree with chat history

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
ailang coordinator status                # Check if running (summary)
ailang coordinator watcher-status        # ApprovalWatcher / GitHub polling status

# Task lists
ailang coordinator list                  # All tasks
ailang coordinator list --running        # Running tasks
ailang coordinator list --pending        # Pending approval
ailang coordinator pending               # Interactive approval queue

# Task detail
ailang coordinator logs <task-id>        # View streaming task logs/events
ailang coordinator diff <task-id>        # View git changes
ailang coordinator worktree <task-id>    # Show worktree directory
ailang coordinator worktree <task-id> --open  # Open worktree

# Approval
ailang coordinator approve <task-id>
ailang coordinator reject <task-id> --feedback "reason"
ailang coordinator reopen <task-id>      # Reopen rejected/cancelled task
ailang coordinator retry <task-id>       # Reset failed task to pending

# Maintenance
ailang coordinator cleanup               # Cancel stale running/queued tasks
ailang coordinator sync-threads          # Sync thread agent from coordinator tasks
```

## Tracing & Telemetry

### `ailang trace`
Manage execution traces.

```bash
ailang trace status                      # Show telemetry configuration
ailang trace list --limit 10             # List recent traces (GCP)
ailang trace list --filter compile --hours 2  # Filter by type/time
ailang trace view <trace-id>             # View specific trace (GCP)
ailang trace hierarchy --limit 5         # Span hierarchy from local DB
```

**Env vars for tracing:**
```bash
OTEL_EXPORTER_OTLP_ENDPOINT=<url>   # Enable OTLP telemetry export
GOOGLE_CLOUD_PROJECT=<id>           # Enable GCP Cloud Trace
AILANG_PARENT_TASK_ID=<id>          # Set parent task for trace hierarchy
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
Serve modules as REST API.

```bash
ailang serve-api ./api/         # Serve modules in directory
ailang serve-api --port 8080
```

## Development Tools

### `ailang test`
Run test suite (including inline tests).

```bash
ailang test <file.ail>
ailang test src/
```

### `ailang iface`
Output module interface (JSON).

```bash
ailang iface <module>
```

### `ailang debug`
Debug AST and type information.

```bash
ailang debug ast <file.ail>
ailang debug ast --flags <file.ail>
```

### `ailang editor`
Install syntax highlighting.

```bash
ailang editor install vscode
ailang editor install vim
ailang editor install neovim
```

### `ailang axioms`
Show design axiom compliance scorecard.

```bash
ailang axioms
ailang axioms --json
```

### `ailang doctor`
Diagnostic tools.

```bash
ailang doctor builtins  # Validate builtin registry
```

### `ailang export-training`
Export traces as AI training data.

```bash
ailang export-training <traces>
```

### `ailang replay`
Replay and verify against a recorded trace.

```bash
ailang replay <trace.jsonl>
```

## Eval Tools (AI Benchmarking)

### `ailang eval`
Run AI benchmarks (AILANG vs Python).

```bash
ailang eval --benchmark fizzbuzz --mock
ailang eval --benchmark all
```

### `ailang eval-suite`
Run full benchmark suite (parallel).

```bash
ailang eval-suite                          # Dev models (fast)
ailang eval-suite --full                   # All models
ailang eval-suite --models gpt5,claude-sonnet-4-6
ailang eval-suite --skip-existing          # Resume interrupted run
```

### `ailang eval-analyze`
Analyze eval results and generate design docs.

```bash
ailang eval-analyze <results-dir>
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

### `ailang eval-matrix`
Performance matrix with stats.

```bash
ailang eval-matrix <results-dir> <version>
```

### `ailang eval-summary`
Summarize eval results.

```bash
ailang eval-summary <results-dir>
```

## Messages (Cross-Agent Communication)

### `ailang messages`
Manage agent-to-agent messages. See [ailang-inbox SKILL.md](../../ailang-inbox/SKILL.md) for full details.

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
ailang messages unack <id>           # Mark as unread

# Reply and forward
ailang messages reply <id> "text" --from agent   # Reply to GitHub issue thread
ailang messages forward <id> --to <inbox>         # Forward to another inbox

# Triage (v0.10.0+)
ailang messages triage               # Cluster unread by intent
ailang messages triage --cluster-by code  # Cluster by code region
ailang messages triage --top 5       # Top 5 clusters

# Search
ailang messages search "query"       # Semantic search (SimHash)
ailang messages search --neural "query"  # Neural search (Ollama)
ailang messages search --space code "internal/types"  # Search specific envelope slot

# Deduplication
ailang messages dedupe               # Report duplicates
ailang messages dedupe --apply       # Mark duplicates

# Cleanup
ailang messages cleanup --older-than 7d
ailang messages cleanup --dry-run

# GitHub sync
ailang messages send user "Bug" --type bug  # Auto-creates GitHub issue
ailang messages import-github               # Import issues as messages
```

## WebAssembly (Browser)

```bash
# Download WASM build
gh release download --repo sunholo-data/ailang -p 'ailang-wasm.tar.gz'

# JS API
repl.loadModule('math', 'let add = \x. \y. x + y')  # Load module
repl.call('math', 'add', 1, 2)                        # Call function
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
| `DEBUG_APPROVAL_WATCHER` | Set to `1` for verbose GitHub label detection |
| `DEBUG_CONCURRENCY` | Set to `1` for per-request eval tracing |
| `AILANG_PARENT_TASK_ID` | Set parent task ID for trace hierarchy |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Enable OTLP telemetry export |
| `GOOGLE_CLOUD_PROJECT` | Enable GCP Cloud Trace |
| `AILANG_REGISTRY` | Registry URL (default: GCS bucket) |
| `AILANG_REGISTRY_VALIDATOR` | Cloud Run validator endpoint (for publish) |
| `AILANG_REGISTRY_API_KEY` | API key for publish/rebuild-index |
