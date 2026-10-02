# Archived

Kept for history; not loaded by any plugin (only `skills/` is) and not listed
in the marketplace.

| What | Archived | Why |
|------|----------|-----|
| `skills/ailang-debug` | 2026-10-02 | Written for AILANG ~v0.10 (March 2026). Checked against v0.51: one fix is wrong (`println` exists in `std/io`), one is obsolete (newline-separated `let`s no longer need `;`), one quotes a message the compiler no longer prints (`for` now reports `PAR020`), and the rest are diagnostics the compiler now gives itself (`undefined variable: map` names the module to import). `ailang prompt`, `ailang check` and the `ailang` skill cover it. |
