# AILANG Changelog

## [Unreleased]

## [v0.8.0] - 2026-02-13

### Added
- **M-SMT-BOUNDED-RECURSION: Bounded recursion for SMT verification** (`internal/smt/unroll.go`, `codegen.go`, `cmd/ailang/verify.go`, ~230 LOC impl + ~500 LOC tests)
  - Recursive functions now verified via Dafny-style bounded unrolling (previously rejected)
  - `UnrollRecursiveFunction`: generates N+1 `define-fun` chain (level 0 uninterpreted, levels 1-N with self-calls replaced)
  - `ReplaceSelfCalls`: immutable AST rewriter handling all 16+ Core node types with Lambda/Let/LetRec shadowing
  - `--verify-recursive-depth N` flag (default 2, max 10, 0 to disable)
  - Sound by construction: uninterpreted base ensures no false positives
  - Output labeled `✓ VERIFIED (bounded: depth N)` with explanatory note
  - Example: `recursive_verify.ail` with factorial, sumTo, fibonacci
  - Fragment checker unchanged — rejection filtering in CLI layer (policy separation)

- **M-SMT-BACKEND: SMT-based contract verification with Z3** (`internal/smt/`, `cmd/ailang/verify.go`, ~2,023 LOC impl + ~1,894 LOC tests)
  - New `ailang verify` command: statically proves `requires`/`ensures` contracts using Z3
  - Fragment checker (`encodable.go`): rejects recursive, higher-order, and unencodable functions with clear hints
  - Expression encoder (`codegen.go`): Core AST → SMT-LIB translation for if/match/let/operators/ADTs
  - Type mapping (`types.go`): AILANG int→Int, float→Real, bool→Bool, enum ADTs→datatypes
  - Z3 solver integration (`solver.go`): auto-discovers Z3, runs with timeout, parses models
  - DictApp handling: type class method calls (ge, lt, add, eq) mapped to SMT-LIB operators
  - Constructor prefix stripping: Core `make_Type_Ctor` names → SMT-LIB `Ctor` names
  - CLI flags: `--verbose` (show SMT-LIB), `--json` (machine output), `--strict`, `--timeout`
  - Return sort inference from Surface AST type annotations and ADT constructor analysis
  - Counterexample display: shows variable assignments that violate postconditions
  - Pure function fixup: treats `! {}` (empty effects) as pure for verification
  - Example: `ailang verify examples/runnable/contracts/park.ail` proves admissionFee result >= 0
  - **Cross-function call verification** (`callee_resolver.go`, ~320 LOC impl + ~290 LOC tests)
    - Functions calling other user-defined functions now verified via `(define-fun)` inlining
    - Topological ordering: callees emitted before callers (handles transitive chains)
    - Cycle detection: circular function calls produce clear error messages
    - Both same-module (`Var`) and cross-module (`VarGlobal`) references resolved
    - Example: `netIncome(gross, bracket) { gross - calculateTax(gross, bracket) }` fully verified
    - New example: `cross_function.ail` demonstrates 3-level call chain verification
  - **Record type verification** (`types.go`, `codegen.go`, `encodable.go`, ~200 LOC impl + ~200 LOC tests)
    - Records mapped to SMT-LIB `declare-datatype` with single constructor and named field accessors
    - Record construction: `{x: 5, y: 10}` → `(mk_Record_x_y 5 10)`
    - Field access: `p.x` → `(x p)` using SMT-LIB auto-generated accessors
    - Functional update: `{p with x: 20}` → `(mk_Record_x_y 20 (y p))`
    - Fragment checker updated: records with encodable field types now accepted
    - Fields sorted alphabetically for deterministic SMT-LIB output
    - Named records use TypeName; anonymous records get hash-based names
    - CLI wiring: `convertASTTypeToType` handles `RecordType` → `TRecord`
    - New example: `record_verify.ail` demonstrates record field access in contracts
  - **Record type discovery** (`codegen.go`, ~130 LOC impl + ~120 LOC tests)
    - Record types now discovered from return type annotations, function body expressions, and ensures clauses
    - Previously only function parameter types were walked for record discovery
    - `collectRecordTypesFromBody`: comprehensive Core AST walker for record literals in all positions (Let, LetRec, If, Match, App, Lambda, BinOp, etc.)
    - `inferRecordTypeFromLiteral`: builds `TRecord` from Core `Record` nodes by inferring field types from literal expressions
    - `EncodeFunctionOpts` extended with `ReturnType`, `Body`, `Contracts` fields for discovery pipeline
    - New example: `record_discovery_verify.ail` demonstrates return-only, body-only, and cross-record verification
  - **String verification** (`types.go`, `codegen.go`, `encodable.go`, ~250 LOC impl + ~200 LOC tests)
    - String type now mapped to SMT-LIB `String` sort (was rejected)
    - String literals encoded with proper SMT-LIB escaping (`""` for quotes)
    - 4 standard builtins in `BuiltinToSMTOp`: `eq_String`, `ne_String`, `lt_String`, `le_String`
    - 8 special builtins via `StringBuiltinSpecial` map with declarative `StringBuiltinSpec`:
      `gt_String`/`ge_String` (flipped args), `concat_String` (str.++), `_str_len` (unary),
      `_str_find` (appended zero), `_str_slice` (substr mode), `_str_startsWith`/`_str_endsWith` (flipped)
    - `OpConcat` intrinsic (`++` operator) mapped to `str.++`
    - Fragment checker updated: `StringLit`, `OpConcat`, and supported string builtins now accepted
    - Unsupported string builtins still properly rejected: `_str_trim`, `_str_upper`, `_str_lower`, `_str_split`, `_str_chars`
    - New example: `string_verify.ail` demonstrates string concatenation, equality, and prefix verification
  - **List verification** (`types.go`, `codegen.go`, `encodable.go`, ~250 LOC impl + ~150 LOC tests)
    - List type `[T]` now mapped to SMT-LIB `(Seq T)` sort via Z3 sequence theory
    - Both `TList` and `TApp("list", T)` forms handled in `MapType`
    - List literals encoded: `[1, 2, 3]` → `(seq.++ (seq.unit 1) (seq.unit 2) (seq.unit 3))`
    - Empty lists: `[]` → `(as seq.empty (Seq Int))`
    - 5 list builtins via `ListBuiltinSpecial` map with declarative `ListBuiltinSpec`:
      `concat_List` (seq.++), `::` (cons mode), `_list_length` (seq.len), `_list_head` (seq.nth 0), `_list_nth` (seq.nth)
    - 3 new Go builtins: `_list_length`, `_list_head`, `_list_nth` for O(1) list operations
    - Fragment checker updated: list literals and supported builtins now accepted
    - CLI `convertASTTypeToType` handles `TypeApp{list, T}` → `TList{T}` for function parameters
    - stdlib updated: `length`, `nth`, `last` now use O(1) builtins instead of O(n) recursion
    - New example: `list_verify.ail` demonstrates list length, cons, head, nth verification

- **M-TRACE-EXPORT Phase 1: Program-level execution traces** (`internal/trace/`, `--emit-trace jsonl`, ~500 LOC)
  - New `internal/trace/` package: schema, collector, JSONL serializer
  - Event types: `function_enter`, `function_exit`, `effect`, `contract_check`, `budget_delta`, `module_start/end`, `error`
  - Call depth tracking with function entry/exit duration
  - Trace collector on `EffContext.Trace` — zero-cost when disabled
  - `--emit-trace jsonl` flag on `ailang run` — JSONL to stdout, program output to stderr
  - Function tracing via `TraceRecorder` interface in eval (follows `BudgetEnforcer` pattern)
  - Contract check recording in `CheckRequires`/`CheckEnsures` delegates
  - Effect + budget delta recording in `effects.Call()`
  - IO output respects `IOWriter` on EffContext (stderr when tracing)
  - 12 unit tests for collector, JSONL round-trip, depth tracking
  - Design doc: `design_docs/planned/v0_8_0/m-trace-export.md`

- **M-TRACE-EXPORT Phase 2: OTEL span emission** (`internal/trace/otel_emitter.go`, ~190 LOC impl + ~320 LOC tests)
  - `EmitOTELSpans()` converts collected trace events to OTEL spans with parent-child hierarchy
  - Batch post-execution: walks event list, reconstructs span tree from depth tracking
  - Span mapping: `eval.function.*`, `eval.effect.*`, `eval.module.*`
  - Contract checks → span events; budget deltas → span attributes; errors → error status
  - `--emit-trace` extended: `otel`, `jsonl,otel`, `auto` modes
  - Auto-enable: when OTEL is configured, program traces emit automatically (zero flags)
  - `BaseTime()` exposed on Collector for timestamp reconstruction
  - 11 tests with `tracetest.InMemoryExporter` (nesting, parent context, nil safety, full trace)
