# Troubleshooting

Common issues agents hit in KYNOS and how to fix them.

## build_runner / generated files out of sync

**CI error:** "Generated files are out of sync"

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/**/*.g.dart lib/**/*.freezed.dart
git commit -m "chore: regenerate build_runner outputs"
```

## CODEMAP.md stale

**CI error:** CODEMAP drift after structural changes

```bash
dart run tool/generate_codemap.dart
git add CODEMAP.md
```

Or use `/regenerate-codemap`.

## PR title rejected

**CI error:** `validate-pr-title` failed

Use Conventional Commits with **lowercase** subject:
- Good: `feat: add coach readiness widgets`
- Bad: `Feat: Add Coach Widgets`

## Feature imported infrastructure

**CI error:** `check_architecture.sh` failed

Move the binding to `lib/shared/providers/` and re-export types if the feature needs them:

```dart
// shared/providers/my_providers.dart
export 'package:kynos/infrastructure/foo/bar.dart' show BarType;
```

Feature files import from `shared/providers/` only.

## Design system check failed

**CI error:** Raw `Gap(N)` or `Colors.*` in features

- Replace `Gap(8)` with `Gap(tokens.Spacing.sm)`
- Replace `Colors.red` with `context.kynosTheme` semantic colors
- Move inline `GoogleFonts` to `core/theme/typography.dart`

```bash
bash scripts/check_design_system.sh
```

## flutter analyze errors after provider change

1. Run build_runner
2. Check `part 'file.g.dart';` matches generated file name
3. Ensure `@riverpod` class extends `_$ClassName`

## flutter build web fails

Common causes:
- Missing `kIsWeb` guard for platform-only code
- Importing `dart:io` without conditional import

Run locally: `flutter build web` and fix reported errors.

## Cross-feature provider import

Features must not import another feature's `providers/`. Extract shared state to `lib/shared/providers/`.

## Domain layer has Flutter import

Move UI code to `features/` or `shared/widgets/`. `domain/` must be pure Dart.

## Tests fail with real platform APIs

Override providers in tests:

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      healthRepositoryProvider.overrideWithValue(fakeHealthRepo),
    ],
    child: const MyApp(),
  ),
);
```

## Agent abandoned PR

AGENTS.md requires monitoring until merge. Return to the PR, address feedback, 👍 resolved comments, re-run `/validate-change`.
