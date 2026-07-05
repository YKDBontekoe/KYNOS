# KYNOS — Agent Operating Manual

This document is the single source of truth for how AI agents, code-generation
tools, and human contributors must work in the KYNOS repository. It covers
architecture, coding standards, validation, and the full pull-request lifecycle
—including mandatory review follow-up.

When in doubt, ask before breaking a rule.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Repository Map](#2-repository-map)
3. [Agent Workflow](#3-agent-workflow)
4. [Pull Request & Review Process](#4-pull-request--review-process)
5. [Dependency Rule (strictly enforced)](#5-dependency-rule-strictly-enforced)
6. [State Management](#6-state-management)
7. [Navigation](#7-navigation)
8. [Models — Immutability & Serialisation](#8-models--immutability--serialisation)
9. [Error Handling](#9-error-handling)
10. [On-Device AI](#10-on-device-ai)
11. [Privacy — Zero-Knowledge Invariant](#11-privacy--zero-knowledge-invariant)
12. [File & Naming Conventions](#12-file--naming-conventions)
13. [Testing](#13-testing)
14. [UI Components & Design System](#14-ui-components--design-system)
15. [What NOT to Do](#15-what-not-to-do)
16. [Validation & Iteration](#16-validation--iteration)
17. [Adding a New Feature — Checklist](#17-adding-a-new-feature--checklist)
18. [Essential Commands](#18-essential-commands)

---

## 1. Project Overview

**KYNOS** is a privacy-first Flutter running coach app (iOS / Android / Web)
powered by on-device AI (Gemma via LiteRT-LM). It combines health data,
biomechanics, gamification, and an AI coach — all without transmitting raw
biometric data off the device.

| Property | Value |
|---|---|
| Framework | Flutter 3.41+ / Dart ^3.11 |
| State | Riverpod (`flutter_riverpod` + `riverpod_annotation`) |
| Navigation | `go_router` via `routerProvider` |
| Architecture | Clean Architecture (domain-centric) |
| AI inference | Background isolate only |
| Privacy | Zero-Knowledge — no raw biometrics leave the device |

---

## 2. Repository Map

**Read [CODEMAP.md](CODEMAP.md) first** — machine-navigable index of features, entry points, and hot files.

```
lib/
├── app/                  # App shell, router, theme wiring
├── core/                 # Constants, errors, theme tokens
├── domain/               # Entities, repository interfaces, use-cases (pure Dart)
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   └── utils/            # Pure domain helpers (e.g. readiness_score)
├── infrastructure/       # Platform integrations — implements domain repos
│   ├── ai/
│   ├── gamification/
│   ├── health/
│   └── privacy/
├── features/             # UI + feature-scoped providers
│   └── <feature>/
│       ├── presentation/
│       │   ├── pages/    # Top-level screens
│       │   └── widgets/  # Feature-scoped widgets
│       └── providers/
└── shared/               # Cross-feature widgets & DI composition
    ├── providers/        # Binds infrastructure → Riverpod (DI layer)
    ├── utils/
    └── widgets/
```

**Note:** There is no separate `data/` layer yet. Repository implementations live in
`infrastructure/`; `shared/providers/` is the DI composition root.

**Layer dependency direction (never invert):**

```
features/  ──►  domain/  ◄──  infrastructure/
shared/providers/  ──►  domain/ + infrastructure/  (DI composition only)
shared/widgets/    ──►  domain/  (no infrastructure)
shared/utils/      ──►  domain/  (no infrastructure)
```

Features must **never** import `infrastructure/` directly — use `shared/providers/`.

---

## 3. Agent Workflow

Every agent task follows this lifecycle:

```
Understand → Plan → Implement → Validate → Open PR → Monitor Review → Done
```

| Phase | Requirements |
|---|---|
| **Understand** | Read relevant code before editing. Match existing patterns. |
| **Plan** | Identify affected layers. Keep diffs focused — no drive-by refactors. |
| **Implement** | Follow all rules in this document. Run `build_runner` when models/providers change. |
| **Validate** | `flutter analyze`, `flutter test`, and `flutter build web` must pass. |
| **Open PR** | Push to a feature branch and open a PR against `main`. |
| **Monitor Review** | **Mandatory** — see [§4 Pull Request & Review Process](#4-pull-request--review-process). |
| **Done** | All review threads resolved, CI green, visual proof attached. |

A task is **not complete** until the PR is open, CI passes, review feedback
is addressed, and every resolved comment has been acknowledged.

---

## 4. Pull Request & Review Process

This section is **mandatory** for all agents. Creating a PR is only the
beginning — you must actively shepherd it through review.

### 4.1 Before Opening a PR

- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — zero failures
- [ ] `dart run build_runner build --delete-conflicting-outputs` — generated files committed if changed
- [ ] `flutter build web` — succeeds (see [§16 Validation & Iteration](#16-validation--iteration))
- [ ] Visual proof attached (screenshots or screen recording of changed UI)
- [ ] Commit messages are clear, descriptive sentences
- [ ] PR title follows [Conventional Commits](#42-opening-the-pr) (CI blocks non-conforming titles)
- [ ] Branch pushed with `git push -u origin <branch-name>`

### 4.2 Opening the PR

- Target branch: **`main`**
- **PR title must use [Conventional Commits](https://www.conventionalcommits.org/)** — enforced by the `validate-pr-title` CI job
- Format: `type` or `type(scope): subject`
- Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- Subject must be **lowercase** after the type prefix (no leading capital letter)
- Use an optional scope when the change is platform- or area-specific (e.g. `ios`, `android`, `ci`, `release`)
- Examples:
  - `feat: add coach readiness widgets`
  - `fix(ios): healthkit permission snackbar shows settings hint`
  - `fix(ci): unblock semantic-release for non-conventional squash commits`
- Body should explain **what** changed and **why**
- Link related issues when applicable
- Mark as draft only if explicitly requested

### 4.3 Watch the PR (Required)

After opening a PR, the agent **must monitor it continuously** until it is
merged or explicitly closed by a human:

1. **Poll for new activity** — check the PR for:
   - Review comments from human reviewers
   - Inline code review threads
   - Comments from **CodeRabbit** (`coderabbitai`) or other automated review bots
   - CI / check-run failures
   - Requested changes from CODEOWNERS

2. **Do not abandon the PR** — if review feedback arrives minutes or hours
   later, the agent responsible for the PR must return and address it.

3. **Re-run validation** after every fix push:
   - `flutter analyze`
   - `flutter test`
   - Confirm CI checks turn green

### 4.4 Responding to Review Comments (Required)

When **any** reviewer — human or bot — leaves actionable feedback:

| Step | Action |
|---|---|
| 1 | Read the full comment thread and understand the requested change |
| 2 | Implement the fix on the same feature branch |
| 3 | Commit and push (`git push origin <branch-name>`) |
| 4 | Reply on the **same comment thread** explaining what you changed |
| 5 | React to the original comment with a **👍 (thumbs up)** to signal it is resolved |

**Thumbs-up rule:** Every review comment you have addressed must receive a 👍
reaction on the original comment. This applies equally to:

- Human reviewer comments
- **CodeRabbit AI** (`coderabbitai`) suggestions
- Bot-generated inline review notes

If you disagree with feedback, reply with your reasoning — do **not** silently
ignore it. A human must make the final call on disputed items.

### 4.5 Handling CodeRabbit AI Specifically

CodeRabbit often posts:

- Nitpick suggestions (naming, formatting)
- Architecture or security observations
- Missing test coverage notes
- Summary reviews with a checklist

Treat CodeRabbit feedback with the same seriousness as human feedback:

- Fix valid issues — do not dismiss because the author is a bot
- 👍 every addressed CodeRabbit comment
- If CodeRabbit flags an architectural violation (e.g. layer import), fix it
  immediately — these align with this document's rules

### 4.6 CI Failures on the PR

If CI fails after your push:

1. Read the failed job logs
2. Fix locally, commit, push
3. Wait for CI to re-run and confirm green
4. Comment on the PR if the failure was non-obvious (brief explanation)

### 4.7 Definition of Done for a PR

A PR is done only when **all** of the following are true:

- [ ] All CI checks pass
- [ ] Every review comment thread is resolved
- [ ] Every addressed comment has a 👍 reaction
- [ ] No unresolved "Request changes" reviews remain
- [ ] Visual proof of the change is available in the PR or agent output

---

## 5. Dependency Rule (strictly enforced)

- `domain/` has **zero** dependencies on Flutter, Riverpod, or any package.
- `features/` depends on `domain/` use-cases only — never on `infrastructure/`.
- `data/` implements `domain/` interfaces — never imports from `features/`.
- `infrastructure/` implements `data/` or `domain/` interfaces using platform APIs.

**Violation examples to refuse:**

- Importing `package:health` inside `domain/`
- Importing a Riverpod provider inside `domain/` or `data/`
- A feature importing another feature's internals

---

## 6. State Management

- Use **Riverpod** (`flutter_riverpod` + `riverpod_annotation`) exclusively.
- All providers live inside the feature they serve, or in `shared/providers/`.
- Never use `StatefulWidget` + `setState` for async or shared state — use providers.
- `AsyncNotifierProvider` for async operations; `NotifierProvider` for sync state.
- Generate providers with `@riverpod` annotations and `build_runner`.

---

## 7. Navigation

- All routing goes through `go_router` via `routerProvider` in `lib/app/router.dart`.
- Route paths are string constants in `Routes` — never hard-code path strings.
- Use `context.go()` / `context.push()` — never `Navigator.push()` directly.
- Deep-link and shell routes are configured in `router.dart` only.

---

## 8. Models — Immutability & Serialisation

- All data models use `@freezed` (immutable, `copyWith`, `==`, `hashCode`).
- All models that touch an API or storage use `@JsonSerializable`.
- Run `dart run build_runner build --delete-conflicting-outputs` after changes.
- Never write `.g.dart` or `.freezed.dart` files by hand.

---

## 9. Error Handling

- Domain errors extend the `Failure` sealed class in `core/errors/failures.dart`.
- Use named record returns `({T? value, Failure? failure})` at repository boundaries.
- Never `throw` across layer boundaries — use return types.
- Use `AsyncValue` from Riverpod to represent loading/data/error in UI.

---

## 10. On-Device AI

- All LLM inference runs in a **Background Isolate** — never on the UI thread.
- The `AiCoachRepository` interface is the only way features touch the model.
- The isolate bridge protocol lives in `infrastructure/ai/gemma/ai_isolate_bridge.dart`.
- Thermal / RAM checks must be done before loading the model (see `AppConstants`).

---

## 11. Privacy — Zero-Knowledge Invariant

- **No biometric data leaves the device** unless the user explicitly exports it.
- Never add HTTP calls that transmit raw health, GPS, or biometric data.
- The `zeroKnowledgeMode` constant in `AppConstants` must remain `true`.
- Any cloud-sync feature must use ZK proofs (zk-SNARK) — never raw data.

---

## 12. File & Naming Conventions

| Thing | Convention |
|---|---|
| Files | `snake_case.dart` |
| Classes / Enums | `PascalCase` |
| Variables / functions | `camelCase` |
| Constants | `camelCase` (inside `abstract final class`) |
| Feature folders | `snake_case/presentation/`, `snake_case/providers/` |
| Generated files | `*.g.dart`, `*.freezed.dart` — excluded from lint |
| Branches | `cursor/<descriptive-name>-<suffix>` for agent branches |

---

## 13. Testing

- Every use-case in `domain/usecases/` has a corresponding unit test.
- Repository contracts are tested with `mocktail` fakes.
- Widget tests use `ProviderScope` with overridden fakes — never real repos.
- Run `flutter test` before every PR; zero failures required.
- Aim for > 80 % line coverage on `domain/` and `data/`.

---

## 14. UI Components & Design System

Import tokens and theme via `package:kynos/core/theme/theme.dart`. Access semantic
tokens with `context.kynosTheme` from `KynosThemeExtension`.

### Shared widgets (`lib/shared/widgets/`)

| Widget | Use for |
|--------|---------|
| `KynosCard` | Default content container |
| `MetricTile` | 2-column metric grids (null `value` → shimmer) |
| `KynosSectionHeader` | Uppercase section labels |
| `KynosHeroBanner` | Coloured tab hero banners |
| `KynosChip` | Badges, metric chips, accent rewards |
| `KynosLoadingLine` | In-card async loading (shimmer, not spinners) |
| `KynosSkeleton` | Full-page / block loading placeholders |
| `KynosPrivacyFooter` | On-device privacy trust line |
| `GlassCard` | Coach assistant bubbles, floating nav |
| `KynosUserBubble` | Coach chat user messages |
| `RunCard` | Workout session list items |

Barrel import: `package:kynos/shared/widgets/widgets.dart`.

### Rules

- All spacing uses tokens from `core/theme/spacing.dart` — never raw numbers in `Gap()`.
- Use `Gap` from `package:gap` instead of `SizedBox` for semantic spacing.
- Typography: prefer `Theme.of(context).textTheme` or `context.kynosTheme` styles.
  Inline `GoogleFonts` calls belong only in `core/theme/typography.dart`.
- Numeric metrics use DM Mono via `kynosTheme.metricValueStyle`.
- Loading states use `shimmer` skeleton animations (`KynosLoadingLine`, `KynosSkeleton`,
  `MetricTile(value: null)`), not spinners inside cards.
- Charts are built with `fl_chart` — never custom-painted unless strictly necessary.
- SVG assets use `flutter_svg`.
- Glass effects are reserved for nav bar and conversational UI — data screens use flat cards.

---

## 15. What NOT to Do

- Do not add `print()` — use `logger` from `package:logger`.
- Do not use `dynamic` — enable `strict-casts`, `strict-inference`.
- Do not use `BuildContext` across `async` gaps without a mounted guard.
- Do not commit `.task` / `.bin` / `.tflite` model files (they are `.gitignore`d).
- Do not disable lint rules project-wide — suppress per-line with justification.
- Do not open a PR and walk away — review follow-up is mandatory (see [§4](#4-pull-request--review-process)).
- Do not ignore CodeRabbit or bot review comments.

---

## 16. Validation & Iteration

- **Prove it works:** Every significant update must be verified using the Flutter **web build** (`flutter build web`).
- **Visual Proof:** After building, the agent must navigate through the changed feature and generate a **video/screen recording** (or detailed screenshots if video is unavailable) to demonstrate functionality and UI fidelity.
- **Iterative Improvement:** Use the visual evidence to identify UX friction or UI polish issues and iterate on the code until the result is high-quality.
- **Mandatory Check:** A task is not considered complete until the agent has verified the build, documented the visual outcome, and completed PR review follow-up.

---

## 17. Adding a New Feature — Checklist

1. Create `lib/features/<name>/presentation/<name>_page.dart`
2. Create `lib/features/<name>/providers/<name>_provider.dart`
3. Add use-case in `lib/domain/usecases/<name>/`
4. Add repository interface in `lib/domain/repositories/`
5. Add data model with `@freezed` in `lib/data/models/`
6. Implement repository in `lib/data/repositories/` or `lib/infrastructure/`
7. Register route in `lib/app/router.dart`
8. Write unit tests for use-case and widget smoke test for page
9. Open PR, monitor review, 👍 all addressed comments

---

## 18. Essential Commands

```bash
# Bootstrap
cp .env.example .env
flutter pub get

# Code generation (after model / provider changes)
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Tests
flutter test
flutter test --coverage

# Build verification
flutter build web
flutter build apk --release

# Run locally
flutter run -d "iPhone 16 Pro"
flutter run --release   # AI inference benchmarks
```

---

## Key Reference Files

| File | Purpose |
|---|---|
| `lib/app/router.dart` | All routes and `Routes` constants |
| `lib/core/constants/app_constants.dart` | RAM budgets, thresholds, privacy flags |
| `lib/core/errors/failures.dart` | Sealed `Failure` hierarchy |
| `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` | Isolate message protocol |
| `.github/workflows/ci.yml` | CI pipeline (analyze, test, build) |
| `CLAUDE.md` | Quick-reference companion to this file |
