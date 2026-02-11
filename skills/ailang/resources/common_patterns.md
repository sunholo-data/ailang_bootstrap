# Common AILANG Patterns (v0.7.3)

> **Note:** Run `ailang prompt` first for the most current syntax and examples.
> This reference shows common patterns - the CLI prompt is the source of truth.
> Auto-synced from main AILANG repo on each release.

## Recursion (No Loops!)

AILANG has no `for` or `while`. Use recursion instead.

### Sum a List
```ailang
export func sum(xs: [int]) -> int {
  match xs {
    [] => 0,
    hd :: tl => hd + sum(tl)
  }
}
```

### Map over a List
```ailang
func myMap(f: int -> int, xs: [int]) -> [int] {
  match xs {
    [] => [],
    hd :: tl => f(hd) :: myMap(f, tl)
  }
}
```
Or use stdlib: `import std/list (map)` then `map(f, xs)`

### Filter a List
```ailang
func myFilter(pred: int -> bool, xs: [int]) -> [int] {
  match xs {
    [] => [],
    hd :: tl => if pred(hd) then hd :: myFilter(pred, tl) else myFilter(pred, tl)
  }
}
```
Or use stdlib: `import std/list (filter)` then `filter(pred, xs)`

### Fold (Reduce)
```ailang
-- Use stdlib foldl with inline func syntax for reliable type inference
import std/list (foldl)
let sum = foldl(func(acc: int, x: int) -> int { acc + x }, 0, [1,2,3,4,5])
```

Or write your own:
```ailang
func myFold(f: (int, int) -> int, init: int, xs: [int]) -> int {
  match xs {
    [] => init,
    hd :: tl => myFold(f, f(init, hd), tl)
  }
}
```

## Effects and IO

### Basic IO
```ailang
-- println is in prelude (no import needed)
export func main() -> () ! {IO} {
  println("Hello, AILANG!");
  println("The answer is: " ++ show(42))
}
```

> **Note:** `readLine()` is currently broken (nullary function bug since v0.4.5).
> Use `--args-json` to pass input: `ailang run --caps IO --args-json '{"name":"Alice"}' --entry main file.ail`

### File IO
```ailang
import std/fs (readFile, writeFile)

export func copyFile(src: string, dst: string) -> () ! {FS} {
  let contents = readFile(src);
  writeFile(dst, contents)
}
```

### Multiple Effects
```ailang
import std/fs (readFile)

export func showFile(path: string) -> () ! {IO, FS} {
  let contents = readFile(path);
  println(contents)  -- println is prelude, no import needed
}
```

## Pattern Matching

### Option Type
```ailang
type Option[a] = Some(a) | None

func mapOption(f: int -> int, opt: Option[int]) -> Option[int] {
  match opt {
    Some(x) => Some(f(x)),
    None => None
  }
}

func getOrElse(opt: Option[int], default: int) -> int {
  match opt {
    Some(x) => x,
    None => default
  }
}
```

### Result Type (Polymorphic ADT)
```ailang
-- Ok uses type parameter, Err always takes string
type Result[a] = Ok(a) | Err(string)

pure func safeDivide(a: int, b: int) -> Result[int] =
  if b == 0 then Err("division by zero") else Ok(a / b)

export func main() -> () ! {IO} {
  match safeDivide(10, 0) {
    Ok(v) => println("Got: " ++ show(v)),
    Err(msg) => println("Error: " ++ msg)
  }
}
```

### Nested Patterns
```ailang
type Tree[a] = Leaf(a) | Node(Tree[a], a, Tree[a])

export func sumTree(t: Tree[int]) -> int {
  match t {
    Leaf(x) => x,
    Node(left, x, right) => sumTree(left) + x + sumTree(right)
  }
}
```

## Records

### Create and Access
```ailang
type Person = {name: string, age: int, email: string}

let alice: Person = {name: "Alice", age: 30, email: "alice@example.com"}

-- Access fields
let name = alice.name
let age = alice.age
```

### Record Updates
```ailang
export func birthday(p: Person) -> Person {
  {p | age: p.age + 1}
}

export func changeEmail(p: Person, newEmail: string) -> Person {
  {p | email: newEmail}
}
```

### Multiple Field Updates
```ailang
export func updatePerson(p: Person, newName: string, newAge: int) -> Person {
  {p | name: newName, age: newAge}
}
```

## Common Mistakes

### Wrong: Using Loops
```ailang
-- WRONG: No loops in AILANG!
for i in range(10) {
  println(i)
}
```

### Right: Use Recursion
```ailang
export func printRange(start: int, end: int) -> () ! {IO} {
  if start >= end then () else {
    println(show(start));
    printRange(start + 1, end)
  }
}
```

### Wrong: Mutable Variables
```ailang
-- WRONG: No mutation!
let mut x = 5;
x = x + 1;
```

### Right: Create New Values
```ailang
let x = 5;
let y = x + 1;  -- New binding, x is unchanged
```

### Wrong: Flags After Filename
```bash
# WRONG: Flags are ignored!
ailang run file.ail --caps IO
```

### Right: Flags Before Filename
```bash
# CORRECT
ailang run --caps IO --entry main file.ail
```

### Wrong: Missing Semicolons
```ailang
-- WRONG: Missing semicolon
export func compute() -> int {
  let x = 10   -- ERROR: missing semicolon
  let y = 20
  x + y
}
```

### Right: Semicolons Between Statements
```ailang
export func compute() -> int {
  let x = 10;  -- Semicolon after each statement
  let y = 20;
  x + y        -- No semicolon on final expression
}
```

## JSON Handling

### Decode JSON
```ailang
import std/json (decode)

type Config = {host: string, port: int}

export func parseConfig(jsonStr: string) -> Config {
  decode[Config](jsonStr)
}
```

### Encode JSON
```ailang
import std/json (encode)

export func toJson(config: Config) -> string {
  encode(config)
}
```

## HTTP / Network

### Simple GET Request
```ailang
module myproject/http_demo
import std/net (httpGet)
import std/io (println)

export func main() -> () ! {IO, Net} {
  let body = httpGet("https://httpbin.org/get");
  println(body)
}
```

Run with: `ailang run --caps IO,Net --entry main http_demo.ail`

### POST with JSON
```ailang
module myproject/post_demo
import std/net (httpPost)
import std/json (encode)
import std/io (println)

export func main() -> () ! {IO, Net} {
  let data = encode({message: "hello", count: 42});
  let response = httpPost("https://httpbin.org/post", data);
  println(response)
}
```

## FizzBuzz (Complete Example)

```ailang
module myproject/fizzbuzz
import std/io (println)

export func fb(n: int) -> () ! {IO} {
  let m3 = n % 3 == 0;
  let m5 = n % 5 == 0;
  if m3 && m5 then {
    println("FizzBuzz")
  } else {
    if m3 then {
      println("Fizz")
    } else {
      if m5 then {
        println("Buzz")
      } else {
        println(show(n))
      }
    }
  }
}

export func main() -> () ! {IO} {
  fb(1);   -- prints: 1
  fb(3);   -- prints: Fizz
  fb(5);   -- prints: Buzz
  fb(15)   -- prints: FizzBuzz
}
```

## AI Effect (Calling LLMs)

AILANG has a built-in AI effect for calling language models:

```ailang
module myproject/ai_demo
import std/ai (call)
import std/io (println)

export func main() -> () ! {IO, AI} {
  let response = call("What is 2+2? Reply with just the number.");
  println("AI says: " ++ response)
}
```

Run with: `ailang run --caps IO,AI --entry main ai_demo.ail`

**Note:** Requires environment variables for the AI provider (e.g., `ANTHROPIC_API_KEY`).

## Arrays (O(1) Access)

For performance-critical code or game grids, use Arrays instead of Lists:

```ailang
module myproject/array_demo
import std/array as A
import std/io (println)

export func main() -> () ! {IO} {
  let arr = #[1, 2, 3, 4, 5];           -- Array literal
  let val = A.get(arr, 2);               -- O(1) access, returns 3
  let safe = A.getOpt(arr, 10);          -- Safe access, returns None
  let updated = A.set(arr, 0, 100);      -- Returns new array
  println(show(val))
}
```
