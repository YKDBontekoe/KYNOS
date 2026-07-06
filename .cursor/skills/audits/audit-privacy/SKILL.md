---
name: audit-privacy
description: Audit KYNOS for Zero-Knowledge privacy violations and biometric data leaks. Explicit invocation only — use /audit-privacy.
disable-model-invocation: true
---

# Audit Privacy

**Reference:** [docs/workflow_prompts.md §3](../../docs/workflow_prompts.md) · AGENTS.md §11

## Instructions

1. Scan for `print()`, `debugPrint()`, `logger` with health/biometric objects
2. Grep sensitive field names in log statements: `hrvMs`, `rhrBpm`, `HealthSummary`, etc.
3. Trace data path from `HealthKitRepository` to UI — no network interceptors capturing biometrics
4. Verify `AppConstants.zeroKnowledgeMode == true`
5. Confirm export flows are user-initiated only

## Commands

```bash
rg 'logger\.(d|i|w|e|f)\(.*(HealthSummary|hrvMs|rhrBpm)' lib/
rg 'print\(|debugPrint\(' lib/
```

## Proof of Work

- Clean ripgrep report
- `zeroKnowledgeMode` confirmed true
