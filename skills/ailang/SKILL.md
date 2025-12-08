---
name: AILANG Development
description: Write, run, and develop with AILANG - a pure functional language for AI agents. Use when user asks about AILANG, wants to write AILANG code, run programs, use dev tools, or needs help with AILANG syntax. Includes installation, CLI commands, and development workflows.
---

# AILANG Development

AILANG is a deterministic programming language designed for AI code synthesis and reasoning.

## Quick Start

### Check Installation

```bash
# Check if ailang is installed
ailang --version

# If not installed, run the install script
./skills/ailang/scripts/install.sh
```

### Run Your First Program

```bash
# Create a hello world program
cat > hello.ail << 'EOF'
module hello

import std/io (println)

export func main() -> () ! {IO} {
  println("Hello, AILANG!")
}
EOF

# Run it
ailang run --caps IO --entry main hello.ail
```

## When to Use This Skill

Invoke this skill when:
- User asks to write AILANG code
- User needs help with AILANG syntax errors
- User wants to run AILANG programs
- User asks about AILANG CLI tools
- User wants to use AILANG dev tools (eval, benchmarks)
- User mentions installing or setting up AILANG

## Available Scripts

### `scripts/install.sh`
Install AILANG binary from GitHub releases.

```bash
./skills/ailang/scripts/install.sh
```

### `scripts/check_version.sh`
Check installed AILANG version.

```bash
./skills/ailang/scripts/check_version.sh
```

### `scripts/validate_code.sh <file.ail>`
Validate AILANG code syntax.

```bash
./skills/ailang/scripts/validate_code.sh program.ail
```

## Key Resources

### Syntax Quick Reference
See [`resources/syntax_quick_ref.md`](resources/syntax_quick_ref.md) for:
- Basic syntax rules
- Function declarations
- Pattern matching
- Effects and capabilities

### CLI Reference
See [`resources/cli_reference.md`](resources/cli_reference.md) for:
- All CLI commands
- Run flags and options
- REPL commands
- Development tools

### Common Patterns
See [`resources/common_patterns.md`](resources/common_patterns.md) for:
- Recursion patterns
- Effect handling
- Record updates
- Common mistakes

## AILANG CLI Commands

### Core Commands

```bash
# Run a program (flags BEFORE filename!)
ailang run --caps IO,FS --entry main file.ail

# Interactive REPL
ailang repl

# Type-check without running
ailang check file.ail

# Show syntax teaching prompt
ailang prompt

# Watch for changes
ailang watch file.ail
```

### Development Tools

```bash
# List all builtin functions
ailang builtins list --by-module

# Validate builtins
ailang doctor builtins

# Run tests
ailang test

# Export training data
ailang export-training
```

### Run Flags

**IMPORTANT:** Flags must come BEFORE the filename!

```bash
# Correct
ailang run --caps IO,FS --entry main file.ail

# Wrong - flags ignored!
ailang run file.ail --caps IO
```

| Flag | Description |
|------|-------------|
| `--caps <list>` | Enable capabilities (IO, FS, Net, Clock) |
| `--entry <name>` | Entrypoint function (default: main) |
| `--trace` | Enable execution tracing |
| `--no-print` | Suppress output |

## Language Overview

### What AILANG Is
- Pure functional (no mutation, no loops)
- Hindley-Milner type inference
- Algebraic effects with capability security
- Pattern matching with exhaustiveness checking
- Expression-based (everything returns a value)

### What AILANG Is NOT
- No classes or objects
- No imperative constructs (for, while, var)
- No mutable state
- No exceptions (use Result types)

## Basic Syntax

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

### Lists (Recursion)
```ailang
export func sum(xs: [int]) -> int {
  match xs {
    [] => 0,
    hd :: tl => hd + sum(tl)
  }
}
```

### Records
```ailang
type Person = {name: string, age: int}

export func birthday(p: Person) -> Person {
  {p | age: p.age + 1}
}
```

## Standard Library

**Auto-imported (std/prelude):**
- Comparisons: `<`, `>`, `==`, `!=`, `<=`, `>=`

**Available imports:**
- `std/io` - `println`, `readLine`, `readInt`
- `std/fs` - `readFile`, `writeFile`, `listDir`
- `std/json` - `json.decode`, `json.encode`
- `std/clock` - `now`, `sleep`
- `std/net` - `httpGet`, `httpPost`

## Workflow

When user asks for AILANG help:

1. **Check installation** (if needed):
   ```bash
   ./skills/ailang/scripts/check_version.sh
   ```

2. **Load syntax reference** (if needed):
   Read `resources/syntax_quick_ref.md`

3. **Write/fix code** following AILANG syntax

4. **Validate** (optional):
   ```bash
   ./skills/ailang/scripts/validate_code.sh file.ail
   ```

5. **Run** with correct flags:
   ```bash
   ailang run --caps IO --entry main file.ail
   ```

## Documentation Links

- Website: https://sunholo-data.github.io/ailang/
- GitHub: https://github.com/sunholo-data/ailang
- Examples: https://github.com/sunholo-data/ailang/tree/main/examples
