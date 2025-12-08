# AILANG Challenge

Load and run an AILANG coding challenge.

## Challenge: $ARGUMENTS

---

## Available Challenges

| ID | Name | Difficulty | What You'll Learn |
|----|------|------------|-------------------|
| `ask-ai` | Ask AI | Beginner | AI integration basics |
| `summarize-file` | File Summarizer | Intermediate | File I/O + AI |
| `ai-debate` | AI Debate | Intermediate | Multi-call AI orchestration |
| `game-of-life` | Game of Life | Intermediate | Pure computation, arrays, visual output |

**Suggested order:** ask-ai → summarize-file → ai-debate → game-of-life

---

## Loading a Challenge

If a challenge name was provided, load it:

```bash
cat challenges/$ARGUMENTS/challenge.md
```

Then follow the instructions in the challenge.

---

## Rules

1. **Don't peek at the solution** at `challenges/$ARGUMENTS/solution.ail`
2. **Use `/ailang-prompt`** to load syntax reference when needed
3. **Explore stdlib** with `cat /Users/mark/dev/sunholo/ailang/std/*.ail`
4. **Check hints** at `challenges/$ARGUMENTS/hints.md` if stuck (not all challenges have hints)

---

## After Completing

Compare with the reference solution:

```bash
cat challenges/$ARGUMENTS/solution.ail
```

Run the reference:

```bash
# For game-of-life:
ailang run --caps IO,FS --entry main challenges/$ARGUMENTS/solution.ail

# For AI challenges:
ailang run --caps IO,AI --ai-stub --entry demo challenges/$ARGUMENTS/solution.ail
```

---

Now load: **$ARGUMENTS**
