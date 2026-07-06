---
name: ai-isolate
description: Work on KYNOS on-device AI inference and the background isolate bridge. Use when editing Gemma, LiteRT-LM, coach chat streaming, or AI repository code.
paths:
  - "lib/infrastructure/ai/**"
  - "lib/features/coach_chat/**"
  - "lib/shared/providers/ai*.dart"
---

# AI Isolate

## When to Use

- Editing AI inference, Gemma model loading, or coach chat streaming
- Touching `ai_isolate_bridge.dart` or `IsolateAiCoachRepository`

## Key Files

| File | Purpose |
|------|---------|
| `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` | Isolate message protocol |
| `lib/infrastructure/ai/isolate_ai_coach_repository.dart` | Repository impl |
| `lib/domain/repositories/ai_coach_repository.dart` | Domain contract |
| `lib/shared/providers/ai_repository_providers.dart` | DI binding |
| `lib/core/constants/app_constants.dart` | RAM budgets, thermal thresholds |

## Rules (AGENTS.md §10)

- **All LLM inference runs in a Background Isolate** — never on the UI thread
- Features access AI only via `AiCoachRepository` through `shared/providers/`
- Thermal / RAM checks before loading model
- UI streaming via `Stream` — avoid full-page rebuilds on each token

## RAM Probe

Use `GemmaDeviceRamProbe` via `ai_repository_providers.dart` export — features must not import infrastructure directly.

## Validation

```bash
flutter analyze
flutter test test/infrastructure/ai/
flutter build web
```

See [docs/architecture/ai_isolate_design.md](../../docs/architecture/ai_isolate_design.md).
