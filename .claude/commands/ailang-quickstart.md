---
description: Complete AILANG hello world tutorial - create, check, and run
---

# AILANG Quickstart Tutorial

This is a complete hands-on tutorial to verify AILANG works.

## Step 1: Load the Teaching Prompt

First, get the AILANG syntax reference:

```bash
ailang prompt | head -50
```

This outputs the syntax rules. The full prompt is ~200 lines - you now have AILANG syntax in context.

## Step 2: Create hello.ail

Create a file named `hello.ail` with this content:

```ailang
module hello

export func main() -> () ! {IO} {
  print("Hello from AILANG!")
}
```

## Step 3: Type-Check the Program

```bash
ailang check hello.ail
```

Expected output:
```
→ Type checking hello.ail...
→ Effect checking...
✓ No errors found!
```

## Step 4: Run the Program

```bash
ailang run --caps IO --entry main hello.ail
```

Expected output:
```
→ Type checking...
→ Effect checking...
✓ Running hello.ail
Hello from AILANG!
```

## Step 5: Verify Builtins Work

```bash
ailang builtins list | head -10
```

Should show available builtin functions.

## Success Criteria

If all steps complete without errors, AILANG is working correctly.

## ACTION REQUIRED

Execute each step above in order:
1. Run `ailang prompt | head -50` to verify CLI works
2. Create the `hello.ail` file with the content shown
3. Run `ailang check hello.ail`
4. Run `ailang run --caps IO --entry main hello.ail`
5. Report success or any errors encountered

## Quick Reference

| Command | Purpose |
|---------|---------|
| `ailang prompt` | Get syntax reference |
| `ailang check FILE` | Type-check without running |
| `ailang run --caps X --entry main FILE` | Run with capabilities |
| `ailang builtins list` | List available functions |
| `ailang repl` | Interactive REPL |

## Common Capabilities

| Capability | When Needed |
|------------|-------------|
| `IO` | `print`, `println`, `readLine` |
| `FS` | `readFile`, `writeFile` |
| `Net` | `httpGet`, `httpPost` |
| `Clock` | `now`, `sleep` |
| `AI` | `call` (AI effect) |
