---
name: health-data
description: Work on KYNOS health data integrations — HealthKit, Health Connect, imports, and health providers. Use when editing biometric data flow or health repositories.
paths:
  - "lib/infrastructure/health/**"
  - "lib/shared/providers/health*.dart"
  - "lib/domain/entities/health*.dart"
---

# Health Data

## When to Use

- Editing HealthKit / Health Connect integration
- Health import (GPX, Apple Health export)
- Health providers or `HealthSummary` aggregation

## Key Files

| File | Purpose |
|------|---------|
| `lib/infrastructure/health/` | Platform health integrations |
| `lib/domain/repositories/health_repository.dart` | Domain contract |
| `lib/shared/providers/health_providers.dart` | Health DI |
| `lib/shared/providers/health_import_providers.dart` | Import use-cases and parse exports |
| `lib/domain/entities/health_summary.dart` | Daily biometric summary |

## Rules

- Error handling: sealed `Failure` hierarchy — never throw across layers
- Return `({T? value, Failure? failure})` at repository boundaries
- Features use `shared/providers/` — never import `infrastructure/health/` directly
- Handle empty data and permission-denied states with clear UX (no blank screens)

## Privacy

Biometric data must not appear in logs. See `/privacy-audit` and AGENTS.md §11.

## Validation

```bash
flutter test test/domain/usecases/health/
flutter test test/infrastructure/health/
flutter analyze
```
