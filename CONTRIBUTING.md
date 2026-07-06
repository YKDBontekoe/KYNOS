# Contributing to KYNOS

Thank you for contributing! This document is a short guide for human contributors.
**AI agents** should start at [docs/agents/README.md](docs/agents/README.md).

## Before You Code

1. Read [CODEMAP.md](CODEMAP.md) to find the right files
2. Read [AGENTS.md](AGENTS.md) for architecture rules and PR workflow
3. For UI work, follow the design system in AGENTS.md §14

## Architecture

```
features/ → domain/ ← infrastructure/
features/ → shared/providers/ → domain + infrastructure
```

- `domain/` is pure Dart — no Flutter or Riverpod imports
- Features never import `infrastructure/` directly — use `shared/providers/`
- Features never import another feature's `providers/`

See [docs/architecture/folder_structure.md](docs/architecture/folder_structure.md) for rationale.

## Development Setup

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
flutter analyze
flutter test
```

## Pull Requests

- Target branch: `main`
- Title format: Conventional Commits — e.g. `feat: add coach readiness widgets`
- Fill out the PR template checklist
- Attach visual proof for UI changes
- Address all review feedback before merge

Agent branches use the pattern `cursor/<descriptive-name>-d1bd`.

## Full Rules

[AGENTS.md](AGENTS.md) is the single source of truth for architecture, testing,
validation, and the mandatory PR review process.
