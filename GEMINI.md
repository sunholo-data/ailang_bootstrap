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
| `ailang builtins list --by-module` | List all builtins |

## Capabilities

| Cap | Enables | Example |
|-----|---------|---------|
| `IO` | Console I/O | `print`, `readLine` |
| `FS` | File system | `readFile`, `writeFile` |
| `Net` | HTTP | `httpGet`, `httpPost` |
| `Clock` | Time | `now`, `sleep` |
| `AI` | LLM calls | `AI.call(prompt)` |

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
import std/fs (readFile, writeFile)
import std/net (httpGet, httpPost)
import std/json (encode, decode)
import std/list (map, filter, fold)
import std/clock (now, sleep)
import std/ai (call)
```

## Documentation

- Website: https://sunholo-data.github.io/ailang/
- GitHub: https://github.com/sunholo-data/ailang
