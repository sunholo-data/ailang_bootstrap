---
description: Start the AILANG interactive REPL
---

Start the AILANG REPL for interactive development:

```bash
ailang repl
```

## REPL Commands

| Command | Description |
|---------|-------------|
| `:help` | Show help |
| `:type <expr>` | Show type of expression |
| `:load <file>` | Load file into REPL |
| `:reset` | Clear REPL state |
| `:quit` | Exit REPL |

## Quick Tests in REPL

```
> 1 + 2
3

> show(42)
"42"

> :type \x. x * 2
int -> int

> let double = \x. x * 2
> double(5)
10
```

The REPL is great for:
- Testing expressions quickly
- Checking types with `:type`
- Experimenting with syntax
- Debugging functions
