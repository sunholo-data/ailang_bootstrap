# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository serves as a bootstrap/plugin package for AILANG, enabling AI coding agents (Claude Code, Gemini CLI) to easily import and use AILANG capabilities.

## Structure

```
ailang_bootstrap/
├── .claude-plugin/
│   ├── plugin.json         # Claude Code plugin manifest
│   └── marketplace.json    # Skills marketplace
├── gemini-extension.json   # Gemini CLI extension manifest
├── GEMINI.md               # Gemini CLI context file
├── commands/               # Slash commands (DISTRIBUTED with plugin)
│   ├── *.md                # Claude Code commands (markdown)
│   └── *.toml              # Gemini CLI commands (TOML)
├── skills/
│   ├── ailang/             # Main AILANG skill
│   │   ├── SKILL.md        # Skill definition
│   │   ├── scripts/        # install.sh, check_version.sh, validate_code.sh
│   │   └── resources/      # syntax_quick_ref.md, cli_reference.md, common_patterns.md
│   ├── ailang-inbox/       # Agent messaging skill
│   │   └── SKILL.md
│   └── ailang-debug/       # Error debugging skill
│       └── SKILL.md
├── bin/                    # AILANG binary (populated in releases)
├── .claude/commands/       # LOCAL dev commands only (NOT distributed)
│   ├── branch.md           # Branch status checker
│   └── promote.md          # Promote changes between branches
└── .github/workflows/
    ├── release.yml         # Platform-specific release builds
    └── sync-ailang.yml     # Auto-sync with AILANG releases
```

## Plugin vs Local Commands

**IMPORTANT:** Commands are distributed differently depending on location:

| Location | Purpose | Distributed? |
|----------|---------|--------------|
| `commands/*.md` | User-facing slash commands | **YES** - installed with plugin |
| `commands/*.toml` | Gemini CLI commands | **YES** - installed with extension |
| `.claude/commands/` | Dev-only commands for this repo | **NO** - local only |

When users install this plugin, they get:
- All skills in `skills/`
- All commands in `commands/` (both .md and .toml)
- MCP servers defined in plugin.json

They do NOT get `.claude/commands/` - those are for repo maintainers only.

## Dual Distribution

This repo supports both:
- **Claude Code Plugin**: Via `.claude-plugin/plugin.json` and `skills/` directory
- **Gemini CLI Extension**: Via `gemini-extension.json` manifest with platform-specific binary bundles

## Release Process

Platform-specific releases are built via GitHub Actions:
1. Tag with `v*` pattern triggers release workflow
2. Downloads AILANG binaries from sunholo-data/ailang releases
3. Creates platform-specific archives with bundled binaries:
   - `darwin.arm64.ailang-bootstrap.tar.gz`
   - `darwin.x64.ailang-bootstrap.tar.gz`
   - `linux.x64.ailang-bootstrap.tar.gz`
   - `linux.arm64.ailang-bootstrap.tar.gz`
   - `win32.x64.ailang-bootstrap.zip`

## Available Skills

### ailang
Main skill for writing, running, and developing AILANG code. Includes:
- Installation script
- Syntax reference
- CLI command reference
- Common patterns guide

### ailang-debug
Debug AILANG code errors. Use when encountering type errors, parse errors, or runtime failures.

### ailang-inbox
Cross-agent messaging for autonomous agent workflows. Features:
- **Semantic search**: Find messages by meaning (`ailang messages search "query"`)
- **Neural search**: Use Ollama embeddings (`--neural` flag)
- **Deduplication**: Find and mark duplicate messages (`ailang messages dedupe`)
- **GitHub sync**: Sync with GitHub Issues (`--github` flag, `import-github`)
- **Asynchronous communication**: AI agents communicate across sessions

## Branch Workflow

This repo uses a three-tier branch structure for Gemini CLI distribution:

| Branch | Purpose | Install Command |
|--------|---------|-----------------|
| `dev` | Active development | `gemini extensions install ... --ref=dev` |
| `preview` | Testing/staging | `gemini extensions install ... --ref=preview` |
| `stable` | **Production (default)** | `gemini extensions install ...` |

**Workflow:** `dev` → `preview` → `stable`

Use `/branch` to check status and `/promote` to move changes through the pipeline.

## Development Commands

```bash
# Test skills locally (Claude Code)
claude plugin add ./

# Check branch status
/branch

# Promote changes to preview or stable
/promote preview
/promote stable

# Create a release (auto-synced from AILANG releases)
# The sync-ailang.yml workflow handles this automatically
```

## Related Repositories

- **AILANG Core**: https://github.com/sunholo-data/ailang
- **AILANG Docs**: https://sunholo-data.github.io/ailang/
