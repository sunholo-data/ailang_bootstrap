# Promote Changes Between Branches

Promote changes through the branch hierarchy: `dev` → `preview` → `stable`

## Arguments
- $ARGUMENTS: Target branch to promote TO (preview or stable)

## Promotion Rules

- To `preview`: Merges from `dev`
- To `stable`: Merges from `preview`

## Task

Promote changes to the specified branch ($ARGUMENTS).

1. First check what will be merged:
   - If promoting to `preview`: `git log --oneline dev..preview` (should show commits TO merge)
   - If promoting to `stable`: `git log --oneline preview..stable`

2. If target is `preview`:
   ```bash
   git checkout preview
   git merge dev --ff-only
   git push origin preview
   ```

3. If target is `stable`:
   ```bash
   git checkout stable
   git merge preview --ff-only
   git push origin stable
   ```

4. Report what was promoted and suggest next steps.

If $ARGUMENTS is empty, show current branch status and ask which branch to promote to.
