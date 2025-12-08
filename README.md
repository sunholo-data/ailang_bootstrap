# AILANG Bootstrap

Quick start package for using AILANG with AI coding agents (Claude Code, Gemini CLI).

AILANG is a deterministic programming language designed for AI code synthesis and reasoning.

## Installation

### Gemini CLI

```bash
gemini extensions install sunholo-data/ailang_bootstrap
```

The extension automatically downloads the correct AILANG binary for your platform.

### Claude Code

```bash
# Add as a plugin
claude plugin install sunholo-data/ailang_bootstrap
```

Or clone and add locally:
```bash
git clone https://github.com/sunholo-data/ailang_bootstrap
claude plugin add ./ailang_bootstrap
```

### Manual Installation

Download a platform-specific release from [GitHub Releases](https://github.com/sunholo-data/ailang_bootstrap/releases):

| Platform | Architecture | Asset |
|----------|-------------|-------|
| macOS | Apple Silicon | `darwin.arm64.ailang-bootstrap.tar.gz` |
| macOS | Intel | `darwin.x64.ailang-bootstrap.tar.gz` |
| Linux | x64 | `linux.x64.ailang-bootstrap.tar.gz` |
| Linux | ARM64 | `linux.arm64.ailang-bootstrap.tar.gz` |
| Windows | x64 | `win32.x64.ailang-bootstrap.zip` |

Each release includes the AILANG binary pre-bundled.

## What's Included

### Skills (Claude Code)

- **ailang** - Write, run, and develop with AILANG
- **agent-inbox** - Cross-agent messaging and notifications

### Extension Features (Gemini CLI)

- AILANG syntax guidance via `GEMINI.md` context
- Pre-bundled `ailang` binary (platform-specific)

## Quick Start

Once installed, you can:

```bash
# Run AILANG code
ailang run --caps IO --entry main program.ail

# Start interactive REPL
ailang repl

# Type-check without running
ailang check program.ail

# Show syntax teaching prompt
ailang prompt
```

## Example AILANG Program

```ailang
module hello

import std/io (println)

export func main() -> () ! {IO} {
  println("Hello, AILANG!")
}
```

Run with:
```bash
ailang run --caps IO --entry main hello.ail
```

## Documentation

- [AILANG Website](https://sunholo-data.github.io/ailang/)
- [AILANG GitHub](https://github.com/sunholo-data/ailang)
- [Examples](https://github.com/sunholo-data/ailang/tree/main/examples)

## Repository Structure

```
ailang_bootstrap/
├── .claude-plugin/
│   ├── plugin.json         # Claude Code plugin manifest
│   └── marketplace.json    # Skills marketplace
├── gemini-extension.json   # Gemini CLI extension manifest
├── GEMINI.md               # Gemini CLI context file
├── skills/
│   ├── ailang/             # Main AILANG skill
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   └── resources/
│   └── agent-inbox/        # Agent messaging skill
│       ├── SKILL.md
│       └── scripts/
├── bin/                    # AILANG binary (in releases)
└── .github/workflows/
    └── release.yml         # Platform-specific release builds
```

## License

MIT License - see [LICENSE](LICENSE)
