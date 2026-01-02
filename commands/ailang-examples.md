---
description: Search and view 97 working AILANG code examples (v0.6.2+)
---

# AILANG Examples

Search 97 working code examples directly from the CLI.

## Search Examples

Find examples by keyword (flags BEFORE query!):

```bash
ailang examples search "pattern matching"
ailang examples search --limit 5 "recursion"
ailang examples search --json "fold"
```

## List Examples

```bash
ailang examples list                    # All working examples
ailang examples list --tags adt         # Filter by tag
ailang examples list --tags recursion   # Filter by tag
ailang examples list --status all       # Include broken
```

## View Specific Example

```bash
ailang examples show adt_option         # Show with metadata
ailang examples show adt_option --run   # Show and execute
ailang examples show fold --expected    # Show expected output only
```

## List Available Tags

```bash
ailang examples tags
```

## Search Scoring

| Match Type | Score | Description |
|------------|-------|-------------|
| Tag match | 1.0 | Query matches a tag exactly |
| Description match | 0.95 | Query found in description |
| Content match | 0.80 | Query found in .ail file |
| Partial match | 0.60-0.70 | Some query words found |

## When to Use

- Learning AILANG patterns: `ailang examples list --tags recursion`
- Checking syntax: `ailang examples search "match"`
- Finding working code: `ailang examples show NAME --run`
