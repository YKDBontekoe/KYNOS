# KYNOS — Agent Documentation Hub

> **Start here** if you are an AI agent or automated contributor working in this repository.

## Read Order

1. **[CODEMAP.md](../../CODEMAP.md)** — where things live (features, routes, hot files)
2. **[AGENTS.md](../../AGENTS.md)** — architecture rules, PR lifecycle, validation
3. **[CLAUDE.md](../../CLAUDE.md)** — quick-reference bootstrap commands

## Cursor Skills

Skills live in [`.cursor/skills/`](../../.cursor/skills/). Invoke with `/skill-name` or let the agent auto-select.

### Workflow skills

| Skill | When to use |
|-------|-------------|
| `/onboard-agent` | First task in this repo |
| `/add-feature` | New screen, tab, or vertical slice |
| `/wire-repository` | New repository or DI provider |
| `/validate-change` | Before opening a PR |
| `/open-pr` | Create and shepherd a pull request |
| `/fix-ci` | CI check failed on your PR |
| `/regenerate-codemap` | After structural changes under `lib/` |

### Domain skills (file-scoped)

| Skill | Scope |
|-------|-------|
| `/ui-design-system` | `lib/features/**`, `lib/shared/widgets/**` |
| `/ai-isolate` | AI inference and coach chat |
| `/health-data` | HealthKit / Health Connect integrations |
| `/privacy-audit` | Zero-knowledge and biometric leak checks |
| `/linear-kynos` | Linear issue management for this project |

### Audit skills (explicit invocation only)

Heavy recurring audits — see [workflow_prompts.md](../workflow_prompts.md) for the full index:

| Skill | Purpose |
|-------|---------|
| `/audit-architecture` | Layer import violations, domain purity |
| `/audit-performance` | 120 Hz jank, `ref.select`, const widgets |
| `/audit-privacy` | Biometric data leak detection |
| `/audit-ai-isolate` | Isolate bridge lifecycle |
| `/audit-ui-polish` | Glassmorphism, motion, haptics |
| `/audit-test-coverage` | Domain use-case and widget test gaps |
| `/audit-health-data` | Health aggregation accuracy |
| `/audit-biomechanics` | Regression model stability |
| `/audit-documentation` | ADR and doc drift |
| `/audit-dart-modernization` | Dart 3 patterns and lint upgrades |

## Bootstrap

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
flutter analyze
flutter test
```

## Validation Before PR

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
bash scripts/check_design_system.sh
bash scripts/check_architecture.sh
flutter build web
```

Attach visual proof (screenshots or screen recording) for UI changes.

## Branch Naming

Agent branches: `cursor/<descriptive-name>-d1bd`

## Definition of Done (PR)

A PR is complete only when **all** of the following are true:

- [ ] All CI checks pass
- [ ] Every review comment thread is resolved
- [ ] Every addressed comment has a 👍 reaction
- [ ] No unresolved "Request changes" reviews remain
- [ ] Visual proof of UI changes is attached

See [AGENTS.md §4](../../AGENTS.md#4-pull-request--review-process) for the full PR lifecycle.

## Reference Docs

| Doc | Purpose |
|-----|---------|
| [common-patterns.md](common-patterns.md) | Riverpod, routes, error handling snippets |
| [troubleshooting.md](troubleshooting.md) | Common agent mistakes and fixes |
| [file-templates.md](file-templates.md) | Scaffold templates for new files |
| [folder_structure.md](../architecture/folder_structure.md) | Layer rationale |
| [ai_isolate_design.md](../architecture/ai_isolate_design.md) | Isolate bridge protocol |
| [workflow_prompts.md](../workflow_prompts.md) | Advanced audit prompt index |

## Architecture (one-liner)

```
features/ → domain/ ← infrastructure/
features/ → shared/providers/ → domain + infrastructure
```

**Never** import `infrastructure/` from `features/`. **Never** import one feature's `providers/` from another feature.
