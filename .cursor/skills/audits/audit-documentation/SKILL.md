---
name: audit-documentation
description: Audit KYNOS documentation for drift against code and generate ADRs when needed. Explicit invocation only — use /audit-documentation.
disable-model-invocation: true
---

# Audit Documentation

**Reference:** [docs/workflow_prompts.md §9](../../docs/workflow_prompts.md)

## Instructions

1. Read `docs/architecture/*.md` and compare to actual `lib/` code
2. Verify isolate protocol docs match `ai_isolate_bridge.dart`
3. Check AGENTS.md §17, CODEMAP, and folder_structure.md for consistency
4. Generate ADR (`docs/architecture/adr-XXX.md`) for significant decisions
5. Audit DartDoc on public `domain/` APIs

## Proof of Work

- Report on doc/code drift items found and fixed
- New or updated ADR if applicable
- Run `dart run tool/generate_codemap.dart` if structure changed
