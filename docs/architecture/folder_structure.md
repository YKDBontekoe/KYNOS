# Folder Structure Rationale

## `domain/`
Contains pure Dart business logic with **no Flutter dependencies**.
Entities, repository interfaces (abstract classes), and use cases live here.
This layer is independently testable with `dart test`.

## `data/`
Implements the domain repository interfaces. Contains DTOs, JSON mappers,
and datasource adapters. Depends on `domain/` but nothing in `features/`.

## `infrastructure/`
Platform-specific integrations: HealthKit, LiteRT-LM, zk-SNARK circuits.
These are thin adapters that translate platform APIs into domain contracts.

## `features/`
Vertical slices — each feature folder owns its UI widgets and local state
(e.g. Riverpod providers). Features depend on `domain/` use cases only,
never directly on `infrastructure/` or other features.

## `shared/`
Cross-feature widgets and services that do not belong to any single feature
and are too small to warrant their own package.

## Dependency Rule
```
features → domain ← data ← infrastructure
shared → (anything below shared)
```
No arrows may point upward toward `features/`.
