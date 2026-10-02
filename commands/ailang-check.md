---
description: "Type-check AILANG code: /ailang-check <file.ail>"
arguments:
  - name: file
    description: Path to .ail file
    required: true
---

Type-check the AILANG file at `$1`:

```bash
ailang check $1
```

If there are errors, explain them and fix them. The diagnostics carry their own
hints (an undefined builtin names the module to import, e.g. `add import std/io
(print)`); `ailang check --format agent` gives one compact line per error.

Common errors:
- "undefined variable: X" → import it from the module the hint names, or define it
- "No instance for Num[string]" → a number was given where a string is expected; convert with `show()`
