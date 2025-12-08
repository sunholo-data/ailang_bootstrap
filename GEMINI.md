# AILANG Extension for Gemini CLI

This extension provides AILANG, a deterministic programming language designed for AI code synthesis and reasoning.

## Quick Start

```bash
# Check if AILANG is installed
ailang --version

# Run AILANG code
ailang run --caps IO --entry main program.ail

# Start interactive REPL
ailang repl

# Type-check without running
ailang check program.ail
```

## What is AILANG?

AILANG is a pure functional programming language with:
- **Hindley-Milner type inference** - Types are inferred automatically
- **Algebraic effects** - Side effects are tracked in the type system
- **Pattern matching** - Exhaustive matching on ADTs
- **Capability-based security** - Effects require explicit capability grants

## Key Syntax

### Functions
```ailang
export func add(x: int, y: int) -> int {
  x + y
}

-- With effects
export func greet(name: string) -> () ! {IO} {
  println("Hello, " ++ name)
}
```

### Pattern Matching
```ailang
type Option[a] = Some(a) | None

export func getOr[a](opt: Option[a], default: a) -> a {
  match opt {
    Some(x) => x,
    None => default
  }
}
```

### Lists
```ailang
export func sum(xs: [int]) -> int {
  match xs {
    [] => 0,
    hd :: tl => hd + sum(tl)
  }
}
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `ailang run [flags] file.ail` | Run a program |
| `ailang repl` | Interactive REPL |
| `ailang check file.ail` | Type-check only |
| `ailang prompt` | Show syntax teaching prompt |
| `ailang builtins list` | List all builtin functions |

### Run Flags
- `--caps IO,FS,Net,Clock` - Enable capabilities
- `--entry main` - Entrypoint function (default: main)
- `--trace` - Enable execution tracing

**Important:** Flags must come BEFORE the filename!

## Syntax Rules

- Use `func` NOT `fn`, `function`, or `def`
- Semicolons REQUIRED between statements in blocks
- Pattern matching uses `=>` NOT `:` or `->`
- NO `for`, `while`, `var`, `const` - use recursion instead
- Everything is immutable

## Standard Library

Auto-imported from `std/prelude`:
- Comparisons: `<`, `>`, `==`, `!=`, `<=`, `>=`

Available imports:
- `std/io` - `println`, `readLine`, `readInt`
- `std/fs` - `readFile`, `writeFile`, `listDir`
- `std/json` - `json.decode`, `json.encode`
- `std/clock` - `now`, `sleep`
- `std/net` - `httpGet`, `httpPost`

## Documentation

- Website: https://sunholo-data.github.io/ailang/
- GitHub: https://github.com/sunholo-data/ailang
- Examples: See `examples/` in the AILANG repository
