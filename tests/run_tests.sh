#!/usr/bin/env bash
# AILANG Bootstrap Test Runner
# Tests AILANG programs and plugin components

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0

# Print section header
section() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

# Test result helpers
pass() {
  echo -e "  ${GREEN}✓${NC} $1"
  PASSED=$((PASSED + 1))
}

fail() {
  echo -e "  ${RED}✗${NC} $1"
  FAILED=$((FAILED + 1))
}

skip() {
  echo -e "  ${YELLOW}○${NC} $1 (skipped)"
  SKIPPED=$((SKIPPED + 1))
}

# ═══════════════════════════════════════════════════════════
# AILANG CLI Tests
# ═══════════════════════════════════════════════════════════

section "1. AILANG CLI Availability"

if command -v ailang &> /dev/null; then
  VERSION=$(ailang --version 2>&1 | head -1)
  pass "ailang installed: $VERSION"
else
  fail "ailang not found in PATH"
  echo ""
  echo "Install AILANG first:"
  echo "  curl -L https://github.com/sunholo-data/ailang/releases/latest/download/darwin.arm64.ailang.tar.gz | tar -xz"
  echo "  sudo mv ailang /usr/local/bin/"
  exit 1
fi

# ═══════════════════════════════════════════════════════════
# Type Checking Tests
# ═══════════════════════════════════════════════════════════

section "2. Type Checking Tests"

for prog in "$SCRIPT_DIR/programs"/*.ail; do
  name=$(basename "$prog" .ail)
  if AILANG_RELAX_MODULES=1 ailang check "$prog" &> /dev/null; then
    pass "check: $name"
  else
    fail "check: $name"
    AILANG_RELAX_MODULES=1 ailang check "$prog" 2>&1 | head -5
  fi
done

# ═══════════════════════════════════════════════════════════
# Execution Tests
# ═══════════════════════════════════════════════════════════

section "3. Execution Tests"

for prog in "$SCRIPT_DIR/programs"/*.ail; do
  name=$(basename "$prog" .ail)
  expected="$SCRIPT_DIR/expected/$name.txt"

  if [[ ! -f "$expected" ]]; then
    skip "run: $name (no expected output)"
    continue
  fi

  # Run with relaxed modules for test directory
  # Filter out AILANG progress/warning lines (→, ✓, WARNING, Running under, etc.)
  actual=$(AILANG_RELAX_MODULES=1 ailang run --caps IO --entry main "$prog" 2>&1 | grep -v '^→\|^✓\|^WARNING\|Running under\|^  ' | head -20 || true)
  expected_content=$(cat "$expected")

  if [[ "$actual" == "$expected_content" ]]; then
    pass "run: $name"
  else
    fail "run: $name"
    echo "    Expected: ${expected_content:0:50}..."
    echo "    Actual:   ${actual:0:50}..."
  fi
done

# ═══════════════════════════════════════════════════════════
# Skill Tests (Claude Code)
# ═══════════════════════════════════════════════════════════

section "4. Skill Structure Tests"

# Check skill files exist
for skill in ailang ailang-debug ailang-inbox; do
  skill_file="$ROOT_DIR/skills/$skill/SKILL.md"
  if [[ -f "$skill_file" ]]; then
    # Check YAML frontmatter
    if head -1 "$skill_file" | grep -q '^---$'; then
      pass "skill: $skill (has frontmatter)"
    else
      fail "skill: $skill (missing YAML frontmatter)"
    fi
  else
    fail "skill: $skill (SKILL.md not found)"
  fi
done

# ═══════════════════════════════════════════════════════════
# Slash Command Tests
# ═══════════════════════════════════════════════════════════

section "5. Slash Command Tests"

COMMANDS_DIR="$ROOT_DIR/.claude/commands"

if [[ -d "$COMMANDS_DIR" ]]; then
  for cmd in "$COMMANDS_DIR"/*.md; do
    name=$(basename "$cmd" .md)
    # Check for YAML frontmatter with description
    if head -5 "$cmd" | grep -q 'description:'; then
      pass "command: /$name"
    else
      fail "command: /$name (missing description)"
    fi
  done
else
  skip "slash commands directory not found"
fi

# ═══════════════════════════════════════════════════════════
# MCP Server Tests
# ═══════════════════════════════════════════════════════════

section "6. MCP Server Tests"

MCP_SCRIPT="$ROOT_DIR/mcp-server/ailang-mcp.sh"

if [[ -x "$MCP_SCRIPT" ]]; then
  pass "MCP script is executable"

  # Test prompt command
  if "$MCP_SCRIPT" prompt 2>&1 | grep -q "AILANG"; then
    pass "MCP: prompt command works"
  else
    fail "MCP: prompt command failed"
  fi

  # Test builtins command (no args = list all)
  MCP_OUTPUT=$("$MCP_SCRIPT" builtins 2>&1) || true
  if echo "$MCP_OUTPUT" | grep -q "builtins\|_io"; then
    pass "MCP: builtins command works"
  else
    fail "MCP: builtins command failed"
    echo "    Output: ${MCP_OUTPUT:0:100}..."
  fi
else
  fail "MCP script not executable"
fi

# ═══════════════════════════════════════════════════════════
# Plugin Configuration Tests
# ═══════════════════════════════════════════════════════════

section "7. Plugin Configuration Tests"

PLUGIN_JSON="$ROOT_DIR/.claude-plugin/plugin.json"

if [[ -f "$PLUGIN_JSON" ]]; then
  # Check it's valid JSON
  if python3 -m json.tool "$PLUGIN_JSON" &> /dev/null; then
    pass "plugin.json is valid JSON"
  else
    fail "plugin.json is invalid JSON"
  fi

  # Check required fields
  if grep -q '"name"' "$PLUGIN_JSON" && grep -q '"version"' "$PLUGIN_JSON"; then
    pass "plugin.json has required fields"
  else
    fail "plugin.json missing required fields"
  fi
else
  fail "plugin.json not found"
fi

# ═══════════════════════════════════════════════════════════
# Gemini Extension Tests
# ═══════════════════════════════════════════════════════════

section "8. Gemini Extension Tests"

GEMINI_JSON="$ROOT_DIR/gemini-extension.json"
GEMINI_MD="$ROOT_DIR/GEMINI.md"

if [[ -f "$GEMINI_JSON" ]]; then
  if python3 -m json.tool "$GEMINI_JSON" &> /dev/null; then
    pass "gemini-extension.json is valid JSON"
  else
    fail "gemini-extension.json is invalid JSON"
  fi
else
  skip "gemini-extension.json not found"
fi

if [[ -f "$GEMINI_MD" ]]; then
  if grep -q "ailang prompt" "$GEMINI_MD"; then
    pass "GEMINI.md mentions ailang prompt"
  else
    fail "GEMINI.md missing ailang prompt guidance"
  fi
else
  skip "GEMINI.md not found"
fi

# Check if Gemini CLI is available
if command -v gemini &> /dev/null; then
  pass "Gemini CLI installed"
else
  skip "Gemini CLI not installed (install later)"
fi

# ═══════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════

section "Test Summary"

TOTAL=$((PASSED + FAILED + SKIPPED))
echo ""
echo -e "  ${GREEN}Passed:${NC}  $PASSED"
echo -e "  ${RED}Failed:${NC}  $FAILED"
echo -e "  ${YELLOW}Skipped:${NC} $SKIPPED"
echo -e "  Total:   $TOTAL"
echo ""

if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi
