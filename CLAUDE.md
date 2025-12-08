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
├── skills/
│   ├── ailang/             # Main AILANG skill
│   │   ├── SKILL.md        # Skill definition
│   │   ├── scripts/        # install.sh, check_version.sh, validate_code.sh
│   │   └── resources/      # syntax_quick_ref.md, cli_reference.md, common_patterns.md
│   └── agent-inbox/        # Agent messaging skill
│       ├── SKILL.md
│       └── scripts/
├── bin/                    # AILANG binary (populated in releases)
└── .github/workflows/
    └── release.yml         # Platform-specific release builds
```

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

### agent-inbox
Cross-agent messaging for autonomous agent workflows.

## Development Commands

```bash
# Test skills locally (Claude Code)
claude plugin add ./

# Create a release
git tag v0.1.0
git push origin v0.1.0
```

## Related Repositories

- **AILANG Core**: https://github.com/sunholo-data/ailang
- **AILANG Docs**: https://sunholo-data.github.io/ailang/
