---
name: audit-architecture
description: Audit KYNOS Clean Architecture layer imports and domain purity. Explicit invocation only — use /audit-architecture for recurring architecture integrity checks.
disable-model-invocation: true
---

# Audit Architecture

**Reference:** [docs/workflow_prompts.md §1](../../docs/workflow_prompts.md) · AGENTS.md §5

## Instructions

1. Run `bash scripts/check_architecture.sh`
2. Grep `lib/features/` for `package:kynos/infrastructure/` imports
3. Grep `lib/domain/` for `package:flutter`, `flutter_riverpod`, `riverpod`
4. Grep `lib/features/` for cross-feature `providers/` imports
5. Identify files >250 lines in CODEMAP hot files section
6. Fix violations: extract to use-cases, move DI to `shared/providers/`

## Proof of Work

- `flutter analyze` — 0 issues
- `bash scripts/check_architecture.sh` — passes
- List of violations found and fixed (or confirm clean)
