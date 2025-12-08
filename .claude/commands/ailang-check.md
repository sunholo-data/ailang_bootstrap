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

If there are type errors, explain what they mean and suggest fixes using the ailang-debug skill patterns.

Common errors:
- "undefined variable" → Need to import or define the function
- "expected }, got let" → Missing semicolon between statements
- "No instance for Num[string]" → Use `show()` to convert numbers to strings
