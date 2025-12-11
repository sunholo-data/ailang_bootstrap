---
description: Run AILANG bootstrap plugin tests to verify everything works
---

# AILANG Plugin Test Suite

Run the full test suite to verify the plugin is working correctly:

```bash
./tests/run_tests.sh
```

## What Gets Tested

1. **AILANG CLI** - Is `ailang` installed and working?
2. **Type Checking** - Do test programs type-check?
3. **Execution** - Do programs produce expected output?
4. **Skills** - Are all skills properly structured?
5. **Slash Commands** - Do all commands have proper frontmatter?
6. **MCP Server** - Can MCP tools execute?
7. **Plugin Config** - Is plugin.json valid?
8. **Gemini Extension** - Is gemini-extension.json valid?

## Manual Verification

After running tests, verify these work interactively:

### 1. Load Teaching Prompt
```bash
ailang prompt
```
Should output ~200 lines of syntax rules.

### 2. Run Test Program
```bash
ailang run --caps IO --entry main tests/programs/hello.ail
```
Should output: `Hello, AILANG!`

### 3. Check Builtins
```bash
ailang builtins list | head -20
```
Should list builtin functions.

### 4. Test MCP Server
```bash
./mcp-server/ailang-mcp.sh prompt | head -10
```
Should output AILANG prompt.

## Expected Results

All tests should pass. If any fail:
- Check AILANG is installed: `ailang --version`
- Check file permissions: `ls -la tests/run_tests.sh`
- Check skill structure: `cat skills/ailang/SKILL.md | head -10`
