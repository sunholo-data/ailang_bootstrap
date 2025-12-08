---
description: "List/search builtins: /ailang-builtins [function-name]"
arguments:
  - name: search
    description: Function to find (optional)
    required: false
---

List AILANG builtin functions.

If `$ARGUMENTS.search` is provided, search for that function:

```bash
ailang builtins list | grep -i "$ARGUMENTS.search"
```

Otherwise, list all builtins by module:

```bash
ailang builtins list --by-module
```

## Common Modules

| Module | Functions |
|--------|-----------|
| `std/io` | `print`, `println`, `readLine`, `readInt` |
| `std/fs` | `readFile`, `writeFile`, `listDir` |
| `std/net` | `httpGet`, `httpPost`, `httpRequest` |
| `std/json` | `encode`, `decode`, `jo`, `ja`, `kv`, `js` |
| `std/list` | `map`, `filter`, `fold`, `length`, `reverse` |
| `std/clock` | `now`, `sleep` |
| `std/ai` | `call` |

## Finding Imports

If you get "undefined variable: X", use this command to find what module to import:

```bash
ailang builtins list | grep functionName
```
