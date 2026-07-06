---
name: privacy-audit
description: Audit KYNOS for Zero-Knowledge privacy violations. Use when checking biometric data leaks, logging of health data, or cloud sync compliance.
paths:
  - "lib/**"
---

# Privacy Audit

## When to Use

- Reviewing code that touches health, GPS, or biometric data
- Before merging features with network calls or logging
- Explicit `/privacy-audit` or `/audit-privacy` invocation

## Invariant (AGENTS.md §11)

- **No biometric data leaves the device** unless user explicitly exports
- `AppConstants.zeroKnowledgeMode` must remain `true`
- Cloud sync requires ZK proofs — never raw data

## Checks

1. **Logging leaks** — grep for sensitive types in log calls:

```bash
rg 'logger\.(d|i|w|e|f)\(.*(HealthSummary|hrvMs|rhrBpm|AthleteProfile)' lib/
rg 'print\(|debugPrint\(' lib/
```

2. **Network paths** — trace HTTP calls; ensure no raw health/GPS payloads
3. **Export flows** — user-initiated only (`LocalExportService`)
4. **Constants** — verify `zeroKnowledgeMode == true` in `app_constants.dart`

## Self-Reflection

"If a malicious actor had app logs, could they reconstruct heart rate history?" → Must be **No**.

## Proof of Work

- Clean ripgrep report for sensitive field names in logging
- `flutter analyze` passes
- Confirm `AppConstants.zeroKnowledgeMode == true`
