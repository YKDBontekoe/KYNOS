# Folder Structure Rationale

## `domain/`
Contains pure Dart business logic with **no Flutter dependencies**.
Entities, repository interfaces (abstract classes), use cases, and pure
helpers (`domain/utils/`) live here. Independently testable with `dart test`.

## `infrastructure/`
Platform-specific integrations and **repository implementations**: HealthKit,
LiteRT-LM, zk-SNARK circuits, local persistence. These adapters implement
domain repository interfaces and translate platform APIs into domain contracts.

## `shared/providers/`
**DI composition root.** Binds `infrastructure/` implementations to Riverpod
providers. Features import shared providers — never `infrastructure/` directly.

## `features/`
Vertical slices — each feature folder owns its UI and local state
(Riverpod providers). Features depend on `domain/` use cases and
`shared/providers/` — never directly on `infrastructure/` or other features.

Standard layout per feature:

```
features/<name>/
├── presentation/
│   ├── pages/       # Top-level screens
│   └── widgets/     # Feature-scoped widgets
└── providers/
```

## `shared/widgets/` and `shared/utils/`
Cross-feature UI and helpers that do not belong to a single feature.

## Dependency Rule

```
features → domain ← infrastructure
features → shared/providers → domain + infrastructure
```

No arrows may point upward toward `features/`.

## `data/` layer (future)

When JSON/Isar DTOs are introduced, a `data/` layer may be added between
`domain/` and `infrastructure/`. It is **not present today** — do not create
an empty `data/` folder.

## Agent navigation

See [CODEMAP.md](../../CODEMAP.md) for feature entry points, hot files, and
cross-cutting concern locations. Regenerate with:

```bash
dart run tool/generate_codemap.dart
```
