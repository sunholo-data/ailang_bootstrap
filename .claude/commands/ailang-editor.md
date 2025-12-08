---
description: "Install syntax highlighting: /ailang-editor <vscode|vim|neovim>"
arguments:
  - name: editor
    description: Target editor
    required: true
---

Install AILANG syntax highlighting for `$1`:

```bash
ailang editor install $1
```

## Supported Editors

- **vscode** - Visual Studio Code
- **vim** - Vim
- **neovim** - Neovim

## What Gets Installed

### VS Code
- Syntax highlighting for `.ail` files
- Basic language configuration
- Extension in `~/.vscode/extensions/`

### Vim / Neovim
- Syntax file in `~/.vim/syntax/` or `~/.config/nvim/syntax/`
- Filetype detection for `.ail` files
- Basic indentation rules

## After Installation

1. Restart your editor
2. Open any `.ail` file
3. You should see syntax highlighting!

If syntax highlighting doesn't appear, check:
- VS Code: Extensions panel → AILANG should be listed
- Vim: `:set filetype?` should show `ailang`
