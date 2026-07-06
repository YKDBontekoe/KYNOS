---
name: validate-change
description: Run the full KYNOS validation suite before opening a PR. Use before committing, before opening a PR, or when the user asks to verify changes.
---

# Validate Change

## When to Use

- Before opening a PR
- After completing implementation
- User asks "does it build" or "run tests"

## Commands (run in order)

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
flutter analyze
flutter test
bash scripts/check_design_system.sh
bash scripts/check_architecture.sh
flutter build web
```

## If Generated Files Changed

Commit any `*.g.dart`, `*.freezed.dart`, and `CODEMAP.md` updates.

## UI Changes

Attach visual proof: screen recording or screenshots of changed screens.

## Definition of Done

All commands pass with zero errors. See [AGENTS.md §4.7](../../AGENTS.md#47-definition-of-done-for-a-pr).
