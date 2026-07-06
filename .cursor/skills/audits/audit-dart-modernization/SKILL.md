---
name: audit-dart-modernization
description: Audit KYNOS for modern Dart 3 patterns, lint upgrades, and build_runner optimization. Explicit invocation only — use /audit-dart-modernization.
disable-model-invocation: true
---

# Audit Dart Modernization

**Reference:** [docs/workflow_prompts.md §10](../../docs/workflow_prompts.md)

## Instructions

1. Review `analysis_options.yaml` — enable `strict-casts`, `unawaited_futures` if safe
2. Replace legacy patterns with pattern matching on sealed `Failure` classes
3. Use records where they simplify repository return types
4. Optimize `build.yaml` to reduce `build_runner` scan scope
5. Remove deprecated plugin/API usage

## Proof of Work

- `flutter analyze` clean with any new strict rules
- Before/after snippet showing idiomatic Dart 3 refactor
