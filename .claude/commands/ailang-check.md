---
description: Type-check an AILANG file without running it
arguments:
  - name: file
    description: The .ail file to check
    required: true
---

Type-check the AILANG file at `$ARGUMENTS.file`:

```bash
ailang check $ARGUMENTS.file
```

If there are type errors, explain what they mean and suggest fixes using the ailang-debug skill patterns.

Common errors:
- "undefined variable" → Need to import or define the function
- "expected }, got let" → Missing semicolon between statements
- "No instance for Num[string]" → Use `show()` to convert numbers to strings
