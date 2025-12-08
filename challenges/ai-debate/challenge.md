# Challenge: AI Debate

Build a program that orchestrates multiple AI calls to create a debate.

## Difficulty: Intermediate
## Features: Multiple AI Calls, Environment Variables, Conditionals, Records

---

## Your Goal

Create an AILANG program that:
- [ ] Checks for available API keys
- [ ] Runs a debate between AI personas on a topic
- [ ] Has an optimist, skeptic, and moderator
- [ ] Synthesizes the viewpoints

## The Concept

Give the AI different "personas" by crafting different prompts:
- **Optimist**: "You are an optimist. Argue FOR..."
- **Skeptic**: "You are a skeptic. Argue AGAINST..."
- **Moderator**: "Summarize both viewpoints..."

Each call to the AI is independent - you control the context through your prompts.

## Discovery Steps

### Step 1: Explore Available Modules

```bash
# Environment variables
cat /Users/mark/dev/sunholo/ailang/std/env.ail

# AI integration
cat /Users/mark/dev/sunholo/ailang/std/ai.ail
```

### Step 2: Understand Records

AILANG supports record types:

```ailang
let keys = {
    anthropic: true,
    openai: false
};
let hasAnthropic = keys.anthropic;  -- Access with dot notation
```

### Step 3: Think About Flow

1. Check which API keys are set
2. If none, print instructions
3. If available, run the debate:
   - Call AI with optimist prompt
   - Call AI with skeptic prompt
   - Call AI with moderator prompt (including previous responses)

### Step 4: Handle Effects

You'll need multiple effects:
```ailang
func main() -> () ! {IO, Env, AI} {
    -- IO for printing
    -- Env for checking environment variables
    -- AI for calling the model
}
```

## Run Your Solution

```bash
# With AI stub
ailang run --caps IO,Env,AI --ai-stub --entry main examples/my_debate.ail

# With real AI
ailang run --caps IO,Env,AI --ai claude-haiku-4-5 --entry main examples/my_debate.ail
```

## Bonus Challenges

1. Make the topic configurable
2. Add more personas (scientist, philosopher, etc.)
3. Run multiple rounds of debate

## Success Criteria

- [ ] Checks for API keys using `std/env`
- [ ] Makes multiple AI calls with different prompts
- [ ] Passes context between calls (moderator sees previous responses)
- [ ] Uses records for structured data
- [ ] Proper effect declarations

---

This teaches AI orchestration - the foundation of agent-like behavior!
