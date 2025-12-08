# AILANG Challenges

A library of coding challenges designed to teach AILANG by doing.

Each challenge guides you to build something real while learning AILANG's key features.

## Available Challenges

| ID | Challenge | Difficulty | Features Demonstrated |
|----|-----------|------------|----------------------|
| `ask-ai` | Ask AI | Beginner | AI integration, basic I/O |
| `ai-debate` | AI Debate | Intermediate | Multiple AI calls, environment variables, records |
| `summarize-file` | File Summarizer | Intermediate | File I/O, AI, error handling |
| `game-of-life` | Conway's Game of Life | Intermediate | Arrays, ADTs, pattern matching, pure functions, file output |

## Usage

```
/ailang-challenge game-of-life
```

## Suggested Learning Path

1. **ask-ai** - Start here. Simplest AI integration.
2. **summarize-file** - Add file I/O to AI calls.
3. **ai-debate** - Orchestrate multiple AI calls.
4. **game-of-life** - Pure computation, no AI, visual output.

## Challenge Structure

Each challenge folder contains:

```
challenges/<name>/
├── challenge.md    # The guided prompt (what the AI sees)
└── solution.ail    # Working reference (don't peek!)
```

Some also have `hints.md` for progressive hints.

## Rules for Solving

1. **Don't peek at the solution** - Try to solve it yourself first
2. **Use hints progressively** - Check `hints.md` one hint at a time if stuck
3. **Run `/ailang-prompt`** - Load the syntax reference when needed
4. **Explore the stdlib** - Use `ailang builtins list --verbose --by-module`
5. **View stdlib source** - https://github.com/sunholo-data/ailang/tree/main/std

## Adding New Challenges

1. Create folder: `challenges/<name>/`
2. Add `challenge.md` with guided discovery prompts
3. Add working `solution.ail`
4. Optionally add `hints.md`
5. Update this README

## Testing Solutions

```bash
# Game of Life
ailang run --caps IO,FS --entry main examples/game_of_life.ail

# AI examples (with stub for testing)
ailang run --caps IO,AI --ai-stub --entry demo examples/ask_ai.ail
ailang run --caps IO,Env,AI --ai-stub --entry main examples/ai_debate.ail
ailang run --relax-modules --caps IO,FS,AI --ai-stub --entry demo examples/summarize_file.ail
```
