# AILANG Syntax Quick Reference (v0.7.3)

> **Source of truth:** Always run `ailang prompt` first for the most current syntax.
> This file is auto-synced from the main AILANG repo on each release.

## Basic Syntax Rules
- Use `func` NOT `fn`, `function`, or `def`
- Semicolons REQUIRED between statements in blocks
- Pattern matching uses `=>` NOT `:` or `->`
- NO `for`, `while`, `var`, `const`, or any imperative constructs
- NO namespace syntax (`::`), use names directly
- `not` for boolean negation (NOT `!`)

## println vs print

| Function | Import Required? | Behavior |
|----------|-----------------|----------|
| `println` | **NO** (prelude) | WITH newline |
| `print` | YES (`import std/io (print)`) | NO newline |

**Use `println` for most output.** Use `show(x)` to convert numbers to strings.

## Required Program Structure

```ailang
module myproject/mymodule

export func main() -> () ! {IO} {
  println(show(42))  -- println is in prelude, no import needed!
}
```

**Rules:**
1. First line MUST be `module path/name`
2. Use `println(show(value))` for numbers, `println(str)` for strings
3. Inside `{ }` blocks: use `let x = e;` (semicolons). NEVER use `let x = e in`!
4. No loops - use recursion

## Functions

### Named Function
```ailang
export func add(x: int, y: int) -> int {
  x + y
}
```

### Pure Function (no effects)
```ailang
pure func double(x: int) -> int = x * 2
```

### With Effects
```ailang
export func greet(name: string) -> () ! {IO} {
  println("Hello, " ++ name)
}
```

### Anonymous Function (Lambda)
```ailang
let double = \x. x * 2
let add = \a. \b. a + b    -- curried, call with add(1)(2)
```

## Pattern Matching

```ailang
type Option[a] = Some(a) | None

export func getOr[a](opt: Option[a], default: a) -> a {
  match opt {
    Some(x) => x,
    None => default
  }
}
```

**On lists:**
```ailang
match xs {
  [] => 0,
  hd :: tl => hd + sum(tl)
}
```

**On records (destructuring):**
```ailang
match person {
  {name, age} => name ++ " is " ++ show(age)
}
```

## Lists (Recursive Processing)

```ailang
export func sum(xs: [int]) -> int {
  match xs {
    [] => 0,
    hd :: tl => hd + sum(tl)
  }
}
```

## Records

```ailang
type Person = {name: string, age: int}

-- Record update (immutable)
export func birthday(p: Person) -> Person {
  {p | age: p.age + 1}
}
```

### Open Records (width subtyping)
```ailang
-- Accepts any record with at least a name field
pure func getName(p: {name: string | r}) -> string = p.name

-- Ellipsis sugar (equivalent)
pure func getEmail(u: {email: string, ...}) -> string = u.email
```

## Block Expressions

```ailang
export func compute() -> int {
  let x = 10;  -- Semicolons between statements!
  let y = 20;
  x + y        -- Last expression is the return value
}
```

## ADTs (Algebraic Data Types)

```ailang
type Tree[a] = Leaf(a) | Node(Tree[a], a, Tree[a])

-- With derived equality
type Color = Red | Green | Blue deriving (Eq)

-- Polymorphic with mixed field types
type Result[a] = Ok(a) | Err(string)
```

## Import Aliasing

```ailang
import std/list as L           -- Module alias: L.map, L.filter
import std/list (length as listLength)  -- Symbol alias
```

## Effects

| Effect | Functions | Import |
|--------|-----------|--------|
| `IO` | `println` (prelude), `print`, `readLine` | `std/io` |
| `FS` | `readFile`, `writeFile` | `std/fs` |
| `Net` | `httpGet`, `httpPost`, `httpRequest` | `std/net` |
| `AI` | `call` | `std/ai` |
| `Env` | `getEnv`, `getEnvOr` | `std/env` |
| `Clock` | `now`, `sleep` | `std/clock` |
| `Rand` | `rand_int`, `rand_float` | `std/rand` |
| `Debug` | `log`, `check` | `std/debug` |

## Standard Library

**Auto-imported (no import needed):**
- `println(s)` - print with newline
- `show(x)` - convert to string
- Comparison operators: `<`, `>`, `<=`, `>=`, `==`, `!=`

**Common imports:**
```ailang
import std/io (print)
import std/fs (readFile, writeFile)
import std/net (httpGet, httpPost)
import std/json (encode, decode, jo, kv, js, jnum, getString, getInt)
import std/list (map, filter, foldl, length, sortBy, nth, last)
import std/string (split, chars, contains, stringToInt, intToStr, join)
import std/math (floatToInt, intToFloat, floor, ceil, round, sqrt)
import std/ai (call)
import std/zip (_zip_listEntries, _zip_readEntry)
import std/xml (_xml_parse, _xml_findAll, _xml_getText, _xml_getAttr)
import std/option (Option, Some, None)
import std/result (Result, Ok, Err)
```

## Operators

| Type | Operators |
|------|-----------|
| Arithmetic | `+`, `-`, `*`, `/`, `%`, `**` |
| Comparison | `<`, `>`, `<=`, `>=`, `==`, `!=` |
| Logical | `&&`, `\|\|`, `not` |
| String/List | `++` (concatenation) |
| List | `::` (cons/prepend) |

## Limitations (Things That DON'T Work)

- NO `for`, `while`, `var`, `const`, `break`, `continue`
- NO `?` error propagation operator
- NO classes or objects
- NO mutable state
- NO `!` for boolean negation (use `not`)
- NO `f(a)(b)` for multi-arg `func` (use `f(a, b)`)
