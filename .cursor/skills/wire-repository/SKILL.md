---
name: wire-repository
description: Wire a repository through Clean Architecture layers in KYNOS. Use when adding DI providers, repository implementations, or connecting domain use-cases to infrastructure.
---

# Wire Repository

## When to Use

- "Wire a repository", "add provider", "DI binding", "connect use-case"
- Touching `lib/shared/providers/` or `lib/infrastructure/`

## Layer Flow

```
domain/repositories/<name>_repository.dart   ← abstract interface
domain/usecases/<name>/                      ← business logic
infrastructure/<area>/<name>_repository.dart ← platform impl
shared/providers/<name>_providers.dart       ← Riverpod binding
features/<feature>/providers/                ← feature-scoped state only
```

## Steps

1. Define `abstract interface class` in `lib/domain/repositories/`
2. Implement in `lib/infrastructure/` — return `({T? value, Failure? failure})` at boundaries
3. Create or extend provider in `lib/shared/providers/`:

```dart
final myRepositoryProvider = Provider<MyRepository>((ref) {
  return MyRepositoryImpl(/* deps from other providers */);
});
```

4. Feature providers import `shared/providers/` — **never** `infrastructure/`
5. Use-case tests with `mocktail` fakes of the repository interface

## Re-export Pattern

When features need infrastructure types (parse results, probes), re-export from `shared/providers/`:

```dart
export 'package:kynos/infrastructure/...' show SomeType;
```

## Validation

```bash
bash scripts/check_architecture.sh
flutter analyze
flutter test
```
