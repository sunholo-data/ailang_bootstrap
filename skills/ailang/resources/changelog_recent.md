# AILANG Changelog

## [Unreleased]

## [v0.8.1] - 2026-02-20

### Added
- **M-WASM-STREAM-BRIDGE: WASM stream builtins use effect handler registry** (`internal/builtins/stream.go`, `cmd/wasm/effects.go`, `web/ailang-repl.js`, `internal/repl/apply_closure.go`, ~255 LOC)
  - All 9 stream builtins now dispatch through `effects.Call()` instead of direct function references, allowing WASM JS handlers registered via `ailangSetEffectHandler("Stream", {...})` to override native Go implementations
  - `ailang-repl.js` `setEffectHandler` supports both 2-arg (`capability, {op: fn}`) and 3-arg (`capability, op, fn`) calling conventions with internal accumulator — no more panic on 3-arg calls
  - `ailangValueToJS` wraps `*eval.FunctionValue` closures as callable `js.FuncOf` functions, enabling the `onEvent(conn, handler)` pattern where AILANG callbacks are invoked by JS on each WebSocket message
  - New `REPL.ApplyClosure()` method for curried function application from WASM bridge (4 tests)
  - WASM binary builds successfully (`GOOS=js GOARCH=wasm`)
  - **Phase 2: ADT wrapping for JS handler returns** (~165 LOC)
    - `jsToAILANGValue` now converts JS objects with `{_ctor, _fields}` convention to `eval.TaggedValue` — enables JS effect handlers to return ADT values that AILANG can pattern-match on (e.g., `Ok(StreamConn(1))`)
    - `jsToAILANGValue` also converts JS `Array` → `eval.ListValue` and plain objects → `eval.RecordValue`
    - `ailangValueToJS` converts `TaggedValue` → `{_ctor, _fields}`, `ListValue` → `Array`, `RecordValue` → plain object (full round-trip)
    - New `ailangADT(ctor, ...fields)` global JS helper for ergonomic ADT construction in effect handlers
    - Static `AilangREPL.adt()`, `streamOk()`, `streamErr()`, `streamConn()` convenience methods in `ailang-repl.js`
  - **Phase 3: Closure environment resolution fix** (`internal/repl/apply_closure.go`, ~40 LOC)
    - `ApplyClosure` now creates a `RegistryResolver`-backed evaluator when the REPL has a `ModuleRegistry`, so closures containing `core.VarGlobal` references (imported functions) resolve correctly
    - Previously, closures invoked from JS via `js.FuncOf` would fail with "undefined variable" for any cross-module import — only same-module sibling bindings worked
    - New `makeRegistryEvaluator()` helper mirrors the pattern from `InvokeExport` (builtins + registry + effect context + dictionaries)
    - 2 new tests: sibling binding resolution + imported function resolution via ApplyClosure
  - Design doc: `design_docs/planned/v0_8_2/m-wasm-stream-bridge.md`

- **M-SEMANTIC-ENVELOPE: Multi-aspect semantic embeddings for agent messaging** (`internal/messaging/envelope.go`, `envelope_builder.go`, `embedder_openai.go`, `embedder_gemini.go`, `cmd/ailang/messages_triage.go`, ~1,450 LOC)
  - Messages carry a **semantic envelope** — 5 named embedding vector slots: `intent`, `code`, `context`, `skill`, `resolution`
  - `intent` auto-computed from title + payload on send (if embedder configured)
  - `code` via `--envelope-code FILE` flag — embeds file content for code-region clustering
  - `context` via `--envelope-context "description"` — embeds sender's working context
  - `resolution` auto-populated on coordinator task completion from git diff + commit message
  - Provider-agnostic embedder factory: `NewEmbedderFromConfig()` supports Ollama, OpenAI (`text-embedding-3-small`), and Gemini (`text-embedding-004`)
  - Multi-space search: `ailang messages search --space code "internal/types"` — same query returns different results per envelope slot
  - `SearchByEnvelope()` method on Store for envelope-aware retrieval
  - `ailang messages triage` subcommand — clusters unread messages by envelope slot similarity
    - Flags: `--cluster-by SLOT`, `--top N`, `--threshold`, `--inbox`, `--json`
    - Greedy threshold-based clustering algorithm
  - Resolution feedback loop in coordinator: `enrichResolutionEnvelope()` runs after successful task completion
  - `UpdateMessageEnvelope()` on `MessageStore` interface (SQLite + Firestore implementations)
  - Schema migration v1.8.0: `ALTER TABLE inbox_messages ADD COLUMN envelope TEXT DEFAULT '{}'`
  - Backward compatible: messages without envelopes work identically to previous behavior
  - Design doc: `design_docs/planned/v0_8_1/m-semantic-envelope.md`

- **M-PROCESS: External command execution** (`internal/effects/process.go`, `internal/builtins/process.go`, `std/process.ail`, ~450 LOC impl + ~200 LOC tests)
  - New `Process` effect with `--caps Process` capability grant
  - `ProcessContext` security model: path-pinned allowlist, configurable timeout (default 30s), output size limits (default 10MB)
  - **Completion semantics**: `Ok(ProcessOutput)` for ALL completed processes (even non-zero exit), `Err(ProcessError)` only for infrastructure failures
  - `ProcessOutput` record: `stdout: bytes`, `stderr: bytes`, `exitCode: int`, `truncated: bool`, `resolvedPath: string`
  - `ProcessError` ADT: `NotAllowed`, `NotFound`, `PermissionDenied`, `Timeout`, `OutputLimitExceeded`, `SpawnFailed`, `AbnormalExit`
  - No shell expansion: uses `os/exec.Command` directly (command injection safe)
  - Path-pinned allowlist: `--process-allowlist echo,git` resolves absolute paths at startup via `exec.LookPath`
  - CLI flags: `--process-timeout`, `--process-allowlist`, `--process-max-output`
  - `limitedWriter` utility: caps stdout/stderr capture at `maxOutput` bytes, sets `truncated` flag
  - 1 builtin registered: `_process_exec` (179 total builtins)
  - `std/process.ail` module: `exec(cmd, args)` wrapper + `ProcessError`/`ProcessOutput` type exports
  - Example: `examples/runnable/process_demo.ail` — echo, non-zero exit, NotFound, stderr capture
  - 12 tests: echo success, non-zero exit, NotFound, missing capability, allowlist (allowed/blocked), timeout, stderr, resolvedPath, ResolveAllowlist, absolute paths, limitedWriter
  - `Process` added to parser known effects, type checker known effects, and effect ops registry

- **M-STREAM-PHASE2-DX: Typed ADT exports for std/stream** (`std/stream.ail`, `internal/builtins/stream.go`, `internal/effects/stream.go`, `internal/parser/parser_type.go`, ~280 LOC)
  - 5 ADT types exported from `std/stream`: `StreamConn`, `StreamEvent`, `StreamErrorKind`, `StreamMessage`, `StreamStatus`
  - All 7 builtin type signatures updated to use `T.Con()`/`T.App()` instead of `T.String()`
  - `eventToADT` constructors renamed: `Error` → `StreamError`, `Closed` → `StreamClosed` to match type declarations
  - SSE support: `_stream_sse_connect` builtin + `sseConnect`/`withSSE` wrappers in std/stream.ail
  - Examples: `stream_websocket.ail` and `stream_sse.ail` use typed imports and pattern matching
  - **Parser bug fix:** Single-constructor ADTs with fields (e.g., `export type Wrap = Wrap(int)`) no longer cause the next `export` keyword to be skipped — cursor convention violation in `parseTypeDeclBody` fixed
  - Regression test added: `TestExportFlagPreservedAfterSingleConstructorADT`
  - Design doc: `design_docs/planned/v0_8_1/m-parser-export-multiline-adt.md`

- **M-STREAM-BIDI: Bidirectional WebSocket streaming primitives** (`internal/effects/stream.go`, `internal/effects/stream_context.go`, `internal/builtins/stream.go`, `std/stream.ail`, ~1,242 LOC impl + ~1,001 LOC tests)
  - New `Stream` effect with `--caps Stream` capability grant
  - `StreamContext` security model: connection limits (default 4), message size limits (1MB), TLS enforcement (wss:// only), domain allowlists, private IP blocking (RFC1918)
  - `StreamConnection` with bounded event buffer (cap 1000), backpressure on full, serialized dispatch
  - WebSocket backend via `gorilla/websocket`: connect, send (text/binary), receive, close
  - Callback-based event dispatch: `onEvent` registers handler, `runEventLoop` blocks and dispatches
  - Handler panic recovery: panics caught, delivered as `Error(ProtocolError(...))` events
  - Idle timeout + max duration ceiling with configurable timeouts
  - `FnCaller` callback on `EffContext` enables effects to invoke AILANG handler functions
  - 6 builtins registered: `_stream_connect`, `_stream_send`, `_stream_onEvent`, `_stream_runEventLoop`, `_stream_close`, `_stream_status`
  - `std/stream.ail` module: `connect`, `transmit`, `onEvent`, `runEventLoop`, `disconnect`, `status`, `defaultConfig`
  - Note: `transmit` (not `send`) because `send` is a reserved keyword for future CSP channels
  - `Stream` added to parser known effects list
  - ADT return values: `Ok(StreamConn(id))`, `Err(ConnectionFailed(...))`, `Message(text)`, `Opened(info)`, etc.
  - Example: `examples/runnable/stream_websocket.ail` — WebSocket echo client
  - 4 integration tests with real WebSocket echo server (connect, multi-message, connection limit, server close)
  - Total: 167 registered builtins (was 161)

- **Codex CLI executor**: OpenAI Codex added as third CLI agent alongside Claude Code and Gemini CLI (`design_docs/planned/v0_8_1/m-coord-codex-executor.md`)

- **Firestore storage backend**: Cloud-native storage option for coordinator and messaging (`cmd/ailang/storage.go`, `internal/coordinator/`, `internal/messaging/`)
  - `AILANG_CLOUD_PROJECT` env var for GCP project ID (separate from telemetry)
  - SQLite remains default for local development

- **OTEL tracing for all effect operations**: Instruments IO, FS, Net, Clock, Stream, Process effects with OpenTelemetry spans via callback injection pattern (`internal/effects/context.go`)
  - `GoCtx` + `SpanWrapperFunc` added to `EffContext` — avoids import cycles

- **Agent coding prompt** (`ailang agent-prompt`): Minimal iterative coding guide (~240 lines) for agentic write/check/run/fix workflows
  - Three-prompt architecture: `ailang prompt` (syntax), `ailang devtools-prompt` (toolchain), `ailang agent-prompt` (agent coding)
  - `ailang chains chat` subcommand for viewing per-turn conversation text
