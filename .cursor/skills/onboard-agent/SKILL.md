---
name: onboard-agent
description: Onboard to the KYNOS repository. Use when starting your first task, when unfamiliar with the codebase, or when the user asks how agents should work in this repo.
---

# Onboard Agent

## When to Use

- First task in this repository
- User asks "how do I contribute" or "where do I start"
- You need the read order, bootstrap commands, or PR definition of done

## Read Order

1. [docs/agents/README.md](../../../docs/agents/README.md) — hub
2. [CODEMAP.md](../../../CODEMAP.md) — file locations, feature index
3. [AGENTS.md](../../../AGENTS.md) — full rules and PR lifecycle

## Bootstrap

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
flutter analyze
flutter test
```

## Key Rules

- Features **never** import `infrastructure/` — use `shared/providers/`
- Features **never** import another feature's `providers/`
- Hand-written files stay under ~250 lines
- PR titles: Conventional Commits with lowercase subject
- Agent branches: `cursor/<descriptive-name>-d1bd`

## Before Finishing Any Task

Run `/validate-change`, open a PR with `/open-pr`, and monitor review until merged.
