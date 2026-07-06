---
name: audit-health-data
description: Audit KYNOS health data aggregation, normalization, and empty-state UX. Explicit invocation only — use /audit-health-data.
disable-model-invocation: true
---

# Audit Health Data

**Reference:** [docs/workflow_prompts.md §7](../../docs/workflow_prompts.md)

## Instructions

1. Review `HealthKitRepository` sleep segment aggregation across midnight
2. Verify HRV (SDNN) normalization for AI coach context
3. Test permission-denied and zero-data empty states
4. Confirm sealed `Failure` hierarchy for errors (AGENTS.md §9)
5. Add unit tests for split sleep, DST edge cases

## Proof of Work

- Unit tests for complex data scenarios
- Screenshot: dashboard empty state or permission UI
