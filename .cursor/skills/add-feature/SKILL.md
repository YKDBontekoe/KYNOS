---
name: add-feature
description: Add a new feature vertical slice to KYNOS. Use when creating a new screen, tab, page, or feature folder under lib/features/.
---

# Add Feature

## When to Use

- "Add a feature", "new screen", "new tab", "new page"
- Creating `lib/features/<name>/`

## Checklist (AGENTS.md §17)

1. **Page** — `lib/features/<name>/presentation/pages/<name>_page.dart`
2. **Provider** — `lib/features/<name>/providers/<name>_provider.dart` (`@riverpod`)
3. **Use-case** — `lib/domain/usecases/<name>/`
4. **Repository interface** — `lib/domain/repositories/` (if new data source)
5. **Entity** — `lib/domain/entities/` with `@freezed` (if needed)
6. **Infrastructure impl** — `lib/infrastructure/` (if new platform integration)
7. **DI provider** — `lib/shared/providers/` binding infra → Riverpod
8. **Route** — register in `lib/app/router.dart` (`Routes` constant)
9. **Tests** — unit test for use-case, widget smoke test for page
10. **Codemap** — `dart run tool/generate_codemap.dart`

## Scaffold Templates

See [docs/agents/file-templates.md](../../docs/agents/file-templates.md).

## UI Rules

- Import design system: `package:kynos/core/theme/theme.dart`
- Use `KynosCard`, `MetricTile`, `Gap(tokens.Spacing.*)` — never raw numbers
- Loading: shimmer (`KynosLoadingLine`, `MetricTile(value: null)`), not spinners in cards

## Validation

```bash
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
flutter analyze
flutter test
flutter build web
```
