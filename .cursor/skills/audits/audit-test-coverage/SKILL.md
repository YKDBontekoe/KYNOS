---
name: audit-test-coverage
description: Audit KYNOS test coverage gaps in domain use-cases and shared widgets. Explicit invocation only — use /audit-test-coverage.
disable-model-invocation: true
---

# Audit Test Coverage

**Reference:** [docs/workflow_prompts.md §6](../../docs/workflow_prompts.md) · AGENTS.md §13

## Instructions

1. Run `flutter test --coverage`
2. Identify use-cases in `lib/domain/usecases/` with <100% line coverage
3. Add `mocktail` fakes for repository contracts
4. Add widget smoke tests for `lib/shared/widgets/`
5. Ensure every bug fix has a regression test

## Rules

- Widget tests: `ProviderScope` with overridden fakes — never real repos
- `test/` mirrors `lib/` structure

## Proof of Work

- `flutter test` — 0 failures
- Coverage summary showing improvement in target area
