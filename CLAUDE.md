# KYNOS — Claude Code Instructions

## Project Overview
KYNOS is a privacy-first Flutter running coach app (iOS / Android / Web)
powered by on-device AI (Gemma via LiteRT-LM). Zero-Knowledge architecture.

## Start Here
1. **[docs/agents/README.md](docs/agents/README.md)** — agent hub (skills, validation, PR checklist)
2. **[CODEMAP.md](CODEMAP.md)** — feature index, entry points, hot files
3. **[AGENTS.md](AGENTS.md)** — full architectural rules and PR workflow

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
flutter build web                   # mandatory before PR (see AGENTS.md §16)
flutter run -d "iPhone 16 Pro"
```

## PR Workflow (mandatory)

- PR titles: Conventional Commits — `type` or `type(scope): subject` with lowercase subject
- Branch naming for agents: `cursor/<descriptive-name>-d1bd`
- After opening a PR: monitor review, address all feedback, 👍 every resolved comment
- Attach visual proof for UI changes (screenshots or screen recording)
- See [AGENTS.md §4](AGENTS.md#4-pull-request--review-process) for full lifecycle

## Key Files
- `docs/agents/README.md` — agent documentation hub
- `CODEMAP.md` — agent navigation index
- `.cursor/skills/` — reusable agent workflows
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
- Open a PR and walk away — review follow-up is mandatory
