---
name: audit-performance
description: Audit KYNOS for 120Hz jank, unnecessary rebuilds, and GPU overdraw. Explicit invocation only — use /audit-performance.
disable-model-invocation: true
---

# Audit Performance

**Reference:** [docs/workflow_prompts.md §2](../../../../docs/workflow_prompts.md) · AGENTS.md §14

## Instructions

1. Analyze `DashboardPage`, `NexusLab`, lists for rebuild triggers
2. Ensure `ref.select` for granular provider subscriptions (e.g. `hrvMs` not whole `HealthSummary`)
3. Check `GlassCard` / `BackdropFilter` overdraw when multiple glass cards visible
4. Add `const` constructors and `RepaintBoundary` where appropriate
5. Verify `ListView.builder` for long lists

## Targets

- Frame budget: 8.3ms at 120Hz
- No full-page rebuilds on streaming AI tokens

## Proof of Work

- Screen recording with Performance Overlay (bars below 8.3ms)
- Optimization log: widgets converted to `const` or `ref.select`
