# KYNOS — Architecture Rules for AI Agents

This file defines the non-negotiable architectural rules for KYNOS. All AI
agents, code-generation tools, and human contributors must follow these rules.
When in doubt, ask before breaking them.

---

## 1. Dependency Rule (strictly enforced)

```
features/  ──►  domain/  ◄──  data/  ◄──  infrastructure/
shared/    ──►  (any layer below shared)
```

- `domain/` has **zero** dependencies on Flutter, Riverpod, or any package.
- `features/` depends on `domain/` use-cases only — never on `infrastructure/`.
- `data/` implements `domain/` interfaces — never imports from `features/`.
- `infrastructure/` implements `data/` or `domain/` interfaces using platform APIs.

**Violation examples to refuse:**
- Importing `package:health` inside `domain/`
- Importing a Riverpod provider inside `domain/` or `data/`
- A feature importing another feature's internals

---

## 2. State Management

- Use **Riverpod** (`flutter_riverpod` + `riverpod_annotation`) exclusively.
- All providers live inside the feature they serve, or in `shared/providers/`.
- Never use `StatefulWidget` + `setState` for async or shared state — use providers.
- `AsyncNotifierProvider` for async operations; `NotifierProvider` for sync state.
- Generate providers with `@riverpod` annotations and `build_runner`.

---

## 3. Navigation

- All routing goes through `go_router` via `routerProvider` in `lib/app/router.dart`.
- Route paths are string constants in `Routes` — never hard-code path strings.
- Use `context.go()` / `context.push()` — never `Navigator.push()` directly.
- Deep-link and shell routes are configured in `router.dart` only.

---

## 4. Models — Immutability & Serialisation

- All data models use `@freezed` (immutable, `copyWith`, `==`, `hashCode`).
- All models that touch an API or storage use `@JsonSerializable`.
- Run `dart run build_runner build --delete-conflicting-outputs` after changes.
- Never write `.g.dart` or `.freezed.dart` files by hand.

---

## 5. Error Handling

- Domain errors extend the `Failure` sealed class in `core/errors/failures.dart`.
- Use named record returns `({T? value, Failure? failure})` at repository boundaries.
- Never `throw` across layer boundaries — use return types.
- Use `AsyncValue` from Riverpod to represent loading/data/error in UI.

---

## 6. On-Device AI

- All LLM inference runs in a **Background Isolate** — never on the UI thread.
- The `AiCoachRepository` interface is the only way features touch the model.
- The isolate bridge protocol lives in `infrastructure/ai/gemma/ai_isolate_bridge.dart`.
- Thermal / RAM checks must be done before loading the model (see `AppConstants`).

---

## 7. Privacy — Zero-Knowledge Invariant

- **No biometric data leaves the device** unless the user explicitly exports it.
- Never add HTTP calls that transmit raw health, GPS, or biometric data.
- The `zeroKnowledgeMode` constant in `AppConstants` must remain `true`.
- Any cloud-sync feature must use ZK proofs (zk-SNARK) — never raw data.

---

## 8. File & Naming Conventions

| Thing | Convention |
|---|---|
| Files | `snake_case.dart` |
| Classes / Enums | `PascalCase` |
| Variables / functions | `camelCase` |
| Constants | `camelCase` (inside `abstract final class`) |
| Feature folders | `snake_case/presentation/`, `snake_case/providers/` |
| Generated files | `*.g.dart`, `*.freezed.dart` — excluded from lint |

---

## 9. Testing

- Every use-case in `domain/usecases/` has a corresponding unit test.
- Repository contracts are tested with `mocktail` fakes.
- Widget tests use `ProviderScope` with overridden fakes — never real repos.
- Run `flutter test` before every PR; zero failures required.
- Aim for > 80 % line coverage on `domain/` and `data/`.

---

## 10. UI Components & Design System

- Use `MetricTile` and `KynosCard` from `shared/widgets/` for data display.
- All spacing uses tokens from `core/theme/spacing.dart` — never raw numbers.
- Use `Gap` from `package:gap` instead of `SizedBox` for semantic spacing.
- Charts are built with `fl_chart` — never custom-painted unless strictly necessary.
- SVG assets use `flutter_svg`.
- Typography: Inter (body) + DM Mono (numeric metrics) via `google_fonts`.
- Loading states use `shimmer` skeleton animations, not spinners inside cards.

---

## 11. What NOT to Do

- Do not add `print()` — use `logger` from `package:logger`.
- Do not use `dynamic` — enable `strict-casts`, `strict-inference`.
- Do not use `BuildContext` across `async` gaps without a mounted guard.
- Do not commit `.task` / `.bin` / `.tflite` model files (they are `.gitignore`d).
- Do not disable lint rules project-wide — suppress per-line with justification.

---

## 12. Validation & Iteration

- **Prove it works:** Every significant update must be verified using the Flutter **web build** (`flutter build web`).
- **Visual Proof:** After building, the agent must navigate through the changed feature and generate a **video/screen recording** (or detailed screenshots if video is unavailable) to demonstrate functionality and UI fidelity.
- **Iterative Improvement:** Use the visual evidence to identify UX friction or UI polish issues and iterate on the code until the result is high-quality.
- **Mandatory Check:** A task is not considered complete until the agent has verified the build and documented the visual outcome.

---

## Adding a New Feature — Checklist

1. Create `lib/features/<name>/presentation/<name>_page.dart`
2. Create `lib/features/<name>/providers/<name>_provider.dart`
3. Add use-case in `lib/domain/usecases/<name>/`
4. Add repository interface in `lib/domain/repositories/`
5. Add data model with `@freezed` in `lib/data/models/`
6. Implement repository in `lib/data/repositories/` or `lib/infrastructure/`
7. Register route in `lib/app/router.dart`
8. Write unit tests for use-case and widget smoke test for page
