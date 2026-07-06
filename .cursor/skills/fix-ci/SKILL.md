---
name: fix-ci
description: Diagnose and fix KYNOS CI failures on a pull request. Use when CI checks fail, build_runner drift is reported, or analyze/test/build-web jobs fail.
---

# Fix CI

## When to Use

- CI failed on your PR
- "build_runner out of sync", "analyze failed", "design system check failed"

## CI Jobs and Fixes

| Job | Common cause | Fix |
|-----|--------------|-----|
| `validate-pr-title` | Non-conventional or capitalized subject | Rename PR: `feat: lowercase subject` |
| `bootstrap` / build_runner | Generated files stale | `dart run build_runner build --delete-conflicting-outputs` then commit `*.g.dart` / `*.freezed.dart` |
| `analyze` | Lint/type errors | `flutter analyze` locally, fix issues |
| `analyze` / design system | Raw `Gap(N)`, `Colors.*` in features | Use `tokens.Spacing.*`, `context.kynosTheme` |
| `analyze` / architecture | Feature imports infrastructure | Move binding to `shared/providers/` |
| `analyze` / CODEMAP | Structural change without regen | `dart run tool/generate_codemap.dart`, commit CODEMAP.md |
| `test` | Failing tests | `flutter test`, fix or update tests |
| `build-web` | Web compile error | `flutter build web` locally |

## Workflow

1. Read the failed job log
2. Reproduce locally with the matching command
3. Fix, commit, push
4. Wait for CI green
5. Comment on PR if the failure was non-obvious

## Re-validate

```bash
flutter analyze && flutter test && flutter build web
bash scripts/check_design_system.sh
bash scripts/check_architecture.sh
```
