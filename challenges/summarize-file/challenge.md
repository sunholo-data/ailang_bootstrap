# Challenge: File Summarizer

Build a practical tool that reads a file and summarizes it using AI.

## Difficulty: Intermediate
## Features: File I/O, AI Integration, String Manipulation, Error Handling

---

## Your Goal

Create an AILANG program that:
- [ ] Takes a file path as input
- [ ] Reads the file contents
- [ ] Sends contents to AI for summarization
- [ ] Prints a bullet-point summary

## Real-World Application

This is a genuinely useful tool! You could use it to:
- Quickly understand a README
- Get an overview of code files
- Summarize documentation

## Discovery Steps

### Step 1: Explore File System Module

```bash
cat /Users/mark/dev/sunholo/ailang/std/fs.ail
```

Key function: `readFile(path: string) -> string`

### Step 2: Understand Effect Composition

When you combine capabilities, declare them all:

```ailang
func main(path: string) -> () ! {IO, FS, AI} {
    -- IO: printing output
    -- FS: reading files
    -- AI: calling the model
}
```

### Step 3: Craft a Good Prompt

The quality of your summary depends on your prompt:

```ailang
let prompt = "Summarize in 3-5 bullet points:\n\n" ++ content;
```

### Step 4: Handle Edge Cases

What if the file is empty? What if it doesn't exist?

```ailang
let len = _str_len(content);
if len == 0 then {
    println("Error: empty file")
} else {
    -- proceed with summarization
}
```

## Run Your Solution

```bash
# With AI stub
ailang run --relax-modules --caps IO,FS,AI --ai-stub --entry demo examples/my_summarizer.ail

# With real AI on a real file
ailang run --relax-modules --caps IO,FS,AI --ai claude-haiku-4-5 --entry demo examples/my_summarizer.ail
```

## Bonus Challenges

1. Show file size before summarizing
2. Let user choose summary length (brief vs detailed)
3. Support multiple file formats with different prompts

## Success Criteria

- [ ] Reads file using `std/fs`
- [ ] Combines file content with AI prompt
- [ ] Handles empty/missing files gracefully
- [ ] Uses three effects together (`IO`, `FS`, `AI`)
- [ ] Produces useful summaries

---

Build something you'll actually use!
