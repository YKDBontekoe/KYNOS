---
name: audit-biomechanics
description: Audit KYNOS biomechanics regression model for numerical stability and cold-start handling. Explicit invocation only — use /audit-biomechanics.
disable-model-invocation: true
---

# Audit Biomechanics

**Reference:** [docs/workflow_prompts.md §8](../../docs/workflow_prompts.md)

## Instructions

1. Check multivariate regression for collinearity (cadence vs power)
2. Verify β-coefficient persistence via Protocol Buffers (atomic save/load)
3. Implement or verify confidence score for stride length prediction
4. Handle cold start (1–2 data points) gracefully
5. Ensure regression math is pure Dart (isolate-safe)

## Proof of Work

- Unit test: OLS prediction vs reference dataset
- Screenshot: Nexus Lab showing β-coefficients and confidence
