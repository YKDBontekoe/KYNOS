---
name: audit-ui-polish
description: Audit KYNOS UI for glassmorphism quality, haptics, motion design, and design token compliance. Explicit invocation only — use /audit-ui-polish.
disable-model-invocation: true
---

# Audit UI Polish

**Reference:** [docs/workflow_prompts.md §5](../../docs/workflow_prompts.md) · AGENTS.md §14

## Instructions

1. Review `GlassCard` in light and dark mode
2. Verify haptics: `HapticFeedback.mediumImpact()` on primary actions
3. Check `go_router` transitions feel fluid
4. Run `bash scripts/check_design_system.sh`
5. Confirm spacing uses `tokens.Spacing.*`, colors from `AppTheme`

## Proof of Work

- Screenshots: light vs dark mode
- Video: transitions and haptic triggers
- Design system script passes
