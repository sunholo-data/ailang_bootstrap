# Challenge: Ask AI

Build the simplest possible AI-powered AILANG program.

## Difficulty: Beginner
## Features: AI Integration, Basic I/O, Function Parameters

---

## Your Goal

Create an AILANG program that:
- [ ] Takes a question as input
- [ ] Sends it to an AI model
- [ ] Prints the response

That's it! The simplest AI integration possible.

## Discovery Steps

### Step 1: Explore AI Capabilities

```bash
# What AI functions are available?
ailang builtins list --verbose --by-module | grep -A 20 "std/ai"
```

Or view the source on GitHub: https://github.com/sunholo-data/ailang/blob/main/std/ai.ail

### Step 2: Load the Syntax Reference

```
/ailang-prompt
```

### Step 3: Understand the Effect System

AILANG uses effects to track capabilities. AI calls require the `AI` effect:

```ailang
func myFunc() -> string ! {AI} {
    -- This function can call AI
}
```

### Step 4: Build It

You need:
1. Import from `std/ai`
2. Import from `std/io` for printing
3. A function that takes a question and prints the answer

## Run Your Solution

```bash
# With AI stub (no API key needed for testing)
ailang run --caps IO,AI --ai-stub --entry demo examples/my_ask_ai.ail

# With real AI
ailang run --caps IO,AI --ai claude-haiku-4-5 --entry demo examples/my_ask_ai.ail
```

## Bonus Challenges

1. Add a `demo` entry point with a default question
2. Accept the question as a function parameter
3. Format the output nicely (Q: ... A: ...)

## Success Criteria

- [ ] Program compiles and runs
- [ ] Uses AILANG's `std/ai` module
- [ ] Correctly declares effects (`! {IO, AI}`)
- [ ] Prints AI response to console

---

This is the "Hello World" of AILANG AI integration!
