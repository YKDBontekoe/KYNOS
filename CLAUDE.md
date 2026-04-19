# KYNOS — Claude Code Instructions

## Project Overview
KYNOS is a Flutter (iOS/Android) running coach app powered by on-device AI
(Gemma 4 via LiteRT-LM). Privacy-first, Zero-Knowledge architecture.

## Architecture Rules
See `AGENTS.md` for the full rule set. Key points:
- Clean Architecture: `domain → data → infrastructure → features`
- State: Riverpod only (`flutter_riverpod` + `riverpod_annotation`)
- Navigation: `go_router` only — route paths are in `lib/app/router.dart`
- Models: `@freezed` + `@JsonSerializable` — run `build_runner` after changes
- No biometric data leaves the device

## Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed + riverpod)
dart run build_runner build --delete-conflicting-outputs

# Static analysis (must be clean before PR)
flutter analyze

# Run tests
flutter test

# Run on device
flutter run -d "iPhone 16 Pro"
flutter run --release      # for AI inference benchmarks
```

## Key Files
- `lib/app/router.dart` — all routes live here
- `lib/core/constants/app_constants.dart` — tunable constants (RAM budgets, thresholds)
- `lib/core/errors/failures.dart` — sealed Failure hierarchy
- `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` — isolate message protocol
- `AGENTS.md` — full architectural rules

## Do Not
- Add any package that transmits raw health/biometric data to a server
- Write to `.g.dart` or `.freezed.dart` files manually
- Add `print()` — use `logger` package
- Use `dynamic` anywhere — strict linting is enabled
- Commit `assets/models/*.task` — model weights are gitignored (>2 GB)
