# KYNOS — Claude Code Instructions

## Project Overview
KYNOS is a Flutter (iOS/Android) running coach app powered by on-device AI
(Gemma 4 via LiteRT-LM). Privacy-first, Zero-Knowledge architecture.

## Start Here
1. **[CODEMAP.md](CODEMAP.md)** — feature index, entry points, hot files
2. **[AGENTS.md](AGENTS.md)** — full architectural rules and PR workflow

## Architecture Rules
- Clean Architecture: `domain` ← `infrastructure`, with `shared/providers/` as DI
- Features never import `infrastructure/` — use `shared/providers/`
- State: Riverpod (`flutter_riverpod` + `riverpod_annotation`)
- Navigation: `go_router` only — route paths are in `lib/app/router.dart`
- Models: `@freezed` + `@JsonSerializable` — run `build_runner` after changes
- Keep hand-written files under ~250 lines; extract widgets to `presentation/widgets/`
- No biometric data leaves the device

## Commands

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart   # refresh CODEMAP.md auto sections
flutter analyze
flutter test
flutter run -d "iPhone 16 Pro"
```

## Key Files
- `CODEMAP.md` — agent navigation index
- `lib/app/router.dart` — all routes
- `lib/shared/providers/` — repository DI bindings
- `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` — isolate protocol
- `AGENTS.md` — full rules

## Do Not
- Import `infrastructure/` from `features/`
- Import one feature's providers from another feature
- Write to `.g.dart` or `.freezed.dart` files manually
- Add `print()` — use `logger` package
- Commit `assets/models/*.task` — model weights are gitignored (>2 GB)
