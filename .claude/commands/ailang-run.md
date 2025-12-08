---
description: Run an AILANG program with proper capabilities
arguments:
  - name: file
    description: The .ail file to run
    required: true
---

Run the AILANG program at `$ARGUMENTS.file`:

1. First, check if the file exists
2. Detect required capabilities from the code:
   - If it uses `print`, `println`, `readLine` → needs `IO`
   - If it uses `readFile`, `writeFile` → needs `FS`
   - If it uses `httpGet`, `httpPost` → needs `Net`
   - If it uses `now`, `sleep` → needs `Clock`
   - If it uses `AI.call` → needs `AI`
3. Run with: `ailang run --caps <detected-caps> --entry main $ARGUMENTS.file`
4. If there are errors, use the ailang-debug skill to help fix them

Example: `/ailang-run hello.ail`
