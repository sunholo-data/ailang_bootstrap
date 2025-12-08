# AILANG Extension for Gemini CLI

AILANG is a deterministic programming language designed for AI code synthesis and reasoning.

## Playbook: Writing AILANG Code

### Step 1: Load the Teaching Prompt (CRITICAL)

**Before writing ANY AILANG code, run this:**

```bash
ailang prompt
```

This outputs the current syntax rules and templates. Do not guess at syntax.

### Step 2: Write Code Following the Template

Every AILANG program needs:
1. A `module` declaration (first line)
2. An exported `main` function
3. Proper effect annotations

```ailang
module myproject/mymodule

export func main() -> () ! {IO} {
  print("Hello, AILANG!")
}
```

### Step 3: Type-Check First

```bash
ailang check file.ail
```

Fix any errors before running.

### Step 4: Run with Capabilities

```bash
ailang run --caps IO --entry main file.ail
```

**Flags MUST come before the filename!**

## Quick Reference

| Command | Purpose |
|---------|---------|
| `ailang prompt` | **Load syntax (DO THIS FIRST!)** |
| `ailang check file.ail` | Type-check without running |
| `ailang run --caps IO --entry main file.ail` | Run program |
| `ailang repl` | Interactive testing |
| `ailang builtins list --verbose --by-module` | **Full stdlib docs with examples** |

## Exploring the Standard Library

**The CLI is the source of truth.** Always use these commands for current, accurate documentation:

```bash
# SOURCE OF TRUTH: Full docs with examples and signatures
ailang builtins list --verbose --by-module

# Search for specific module (e.g., array functions)
ailang builtins list --verbose --by-module | grep -A 30 "std/array"

# Search for specific function
ailang builtins list --verbose | grep -A 10 "httpGet"
```

The CLI output shows authoritative documentation:
- **Usage:** Exact import statement to use the function
- **Parameters:** What each argument expects
- **Returns:** What the function returns
- **Examples:** Working code snippets

**Note:** This file provides guidance, but `ailang prompt` and `ailang builtins list --verbose` are always more up-to-date.

## Capabilities

| Cap | Enables | Example |
|-----|---------|---------|
| `IO` | Console I/O | `print`, `readLine` |
| `FS` | File system | `readFile`, `writeFile` |
| `Net` | HTTP | `httpGet`, `httpPost` |
| `Clock` | Time | `now`, `sleep` |
| `AI` | LLM calls | `AI.call(prompt)` |
| `Rand` | Random numbers | `rand_int`, `rand_float` |
| `Env` | Environment vars | `getEnv`, `hasEnv` |
| `Debug` | Debug logging | `Debug.log`, `Debug.check` |

```bash
# Multiple capabilities
ailang run --caps IO,FS,Net --entry main server.ail
```

## Essential Syntax Rules

1. **Use `func`** - NOT `fn`, `function`, or `def`
2. **Semicolons between statements** - `let x = 1; let y = 2; x + y`
3. **Pattern matching uses `=>`** - NOT `:` or `->`
4. **No loops** - Use recursion instead
5. **Everything is immutable**
6. **`print` expects string** - Use `print(show(42))` for numbers

## Common Patterns

### Hello World
```ailang
module myproject/hello

export func main() -> () ! {IO} {
  print("Hello, AILANG!")
}
```

### Recursion (No Loops!)
```ailang
export func sum(xs: [int]) -> int {
  match xs {
    [] => 0,
    hd :: tl => hd + sum(tl)
  }
}
```

### HTTP Request
```ailang
module myproject/http
import std/net (httpGet)

export func main() -> () ! {IO, Net} {
  let body = httpGet("https://httpbin.org/get");
  print(body)
}
```

### JSON Parsing
```ailang
module myproject/json
import std/json (decode)

type Person = {name: string, age: int}

export func main() -> () ! {IO} {
  let json = "{\"name\":\"Alice\",\"age\":30}";
  let person = decode[Person](json);
  print(show(person))
}
```

### AI Effect
```ailang
module myproject/ai
import std/ai (call)

export func main() -> () ! {IO, AI} {
  let response = call("Say hello!");
  print(response)
}
```

## Common Errors and Fixes

| Error | Fix |
|-------|-----|
| `undefined variable: print` | Use entry module or `import std/io (print)` |
| `No instance for Num[string]` | Use `print(show(42))` not `print(42)` |
| `expected }, got let` | Add `;` between statements |
| `unexpected token: for` | No loops! Use recursion |

## Standard Library Imports

```ailang
import std/io (print, println, readLine)
import std/fs (readFile, writeFile, exists)
import std/net (httpGet, httpPost, httpRequest)
import std/json (encode, decode)
import std/list (map, filter, fold)
import std/array (make, get, set, length, fromList, toList)
import std/string (len, slice, split, trim, upper, lower, find)
import std/clock (now, sleep)
import std/rand (int, float, bool, seed)
import std/env (getEnv, hasEnv, getArgs)
import std/ai (call)
import std/debug (log, check)
```

**Tip:** Run `ailang builtins list --verbose --by-module | grep -A 30 "std/MODULE"` for full docs.

## Practical Examples to Offer Users

When users want to see AILANG in action, offer to create these working programs:

### AI Debate Tool
Have AI debate a topic with different personas:
```ailang
module tools/ai_debate
import std/ai (call)
import std/io (println)

export func main() -> () ! {IO, AI} {
  println("=== AI Debate: Is AI beneficial? ===");
  let optimist = call("Argue FOR AI benefits in 2 sentences");
  println("Optimist: " ++ optimist);
  let skeptic = call("Argue AGAINST AI risks in 2 sentences");
  println("Skeptic: " ++ skeptic)
}
```
Run: `ailang run --caps IO,AI --ai claude-haiku-4-5 --entry main ai_debate.ail`

### File Summarizer
Summarize any file using AI:
```ailang
module tools/summarize
import std/ai (call)
import std/fs (readFile)
import std/io (println)

export func main() -> () ! {IO, FS, AI} {
  let content = readFile("README.md");
  let summary = call("Summarize in 3 bullets:\n" ++ content);
  println(summary)
}
```
Run: `ailang run --caps IO,FS,AI --ai gpt5-mini --entry main summarize.ail`

### Conway's Game of Life
Classic cellular automaton:
```ailang
module games/life
import std/array (make, get, set)
import std/io (println)

type Cell = Alive | Dead

export func main() -> () ! {IO} {
  println("=== Game of Life ===");
  -- Creates and displays a blinker pattern
  println(".#.");
  println(".#.");
  println(".#.")
}
```
Run: `ailang run --caps IO --entry main life.ail`

### Simple AI Q&A
Quick CLI assistant:
```ailang
module tools/ask
import std/ai (call)
import std/io (println)

export func main() -> () ! {IO, AI} {
  let answer = call("What is functional programming?");
  println(answer)
}
```
Run: `ailang run --caps IO,AI --ai claude-haiku-4-5 --entry main ask.ail`

## Editor Support

Install syntax highlighting:

```bash
# VS Code
ailang editor install vscode

# Vim
ailang editor install vim

# Neovim
ailang editor install neovim
```

Features:
- Syntax highlighting for `.ail` files
- Bracket matching
- Comment toggling

## Documentation

- Website: https://sunholo-data.github.io/ailang/
- GitHub: https://github.com/sunholo-data/ailang
