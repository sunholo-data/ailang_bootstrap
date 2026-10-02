---
description: "Run AILANG program: /ailang-run <file.ail> (auto-detects caps)"
arguments:
  - name: file
    description: Path to .ail file
    required: true
---

Run the AILANG program at `$1`:

1. First, check if the file exists
2. Detect required capabilities from the code:
   - If it uses `print`, `println`, `readLine` → needs `IO`
   - If it uses `readFile`, `writeFile` → needs `FS`
   - If it uses `httpGet`, `httpPost` → needs `Net`
   - If it uses `now`, `sleep` → needs `Clock`
   - If it uses `AI.call` → needs `AI`
3. Run with: `ailang run --caps <detected-caps> --entry main $1`
4. If there are errors, read the diagnostic's hint, fix, and run `ailang check $1` before running again

Example: `/ailang-run hello.ail`
