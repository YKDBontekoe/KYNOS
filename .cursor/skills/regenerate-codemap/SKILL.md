---
name: regenerate-codemap
description: Regenerate CODEMAP.md after structural changes under lib/. Use when adding features, moving files, or CODEMAP CI drift check fails.
---

# Regenerate Codemap

## When to Use

- Added/removed/renamed files under `lib/`
- CI reports CODEMAP.md is out of date
- After completing `/add-feature`

## Command

```bash
dart run tool/generate_codemap.dart
```

This updates the auto-generated sections between `<!-- CODEMAP_AUTO_BEGIN/END -->` in [CODEMAP.md](../../../CODEMAP.md):
- Layer map (per-file line counts and class summaries)
- Hot files (>250 lines)

## Commit

If `git diff CODEMAP.md` shows changes, commit them with your feature work.

## Verify

```bash
git diff --exit-code CODEMAP.md   # should exit 0 after commit
```
