# Branch Management for ailang_bootstrap

This repo uses a three-tier branch structure for Gemini CLI extension distribution:

## Branch Structure

| Branch | Purpose | Users Install With |
|--------|---------|-------------------|
| `dev` | Active development | `--ref=dev` |
| `preview` | Testing/staging | `--ref=preview` |
| `stable` | **Production (default)** | (default) |

## Workflow

1. **Development**: Work on `dev` branch
2. **Testing**: Merge `dev` → `preview` for testing
3. **Release**: Merge `preview` → `stable` for production

## Current Task

Please help me with branch management. Check the current state and guide me on:

1. Which branch am I on?
2. What's the status of each branch?
3. Are there any commits that need to be promoted?

Run these commands to assess:
```bash
git branch -v
git log --oneline dev..preview  # commits in preview not in dev
git log --oneline preview..stable  # commits in stable not in preview
git log --oneline stable..dev  # commits in dev not in stable
```

Then recommend what actions to take based on what I'm trying to accomplish.
