---
name: audit-ai-isolate
description: Audit KYNOS AI isolate bridge for memory leaks, streaming efficiency, and thermal handling. Explicit invocation only — use /audit-ai-isolate.
disable-model-invocation: true
---

# Audit AI Isolate

**Reference:** [docs/workflow_prompts.md §4](../../docs/workflow_prompts.md) · AGENTS.md §10

## Instructions

1. Review `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` for leak paths
2. Verify isolate killed and port closed on `CoachChatPage` dispose
3. Confirm token streaming uses `Stream` — no full-page rebuilds per token
4. Check thermal/RAM gating before model load (`AppConstants`)
5. Test OOM handling on <6GB RAM devices

## Key Files

- `ai_isolate_bridge.dart`
- `isolate_ai_coach_repository.dart`
- `docs/architecture/ai_isolate_design.md`

## Proof of Work

- Video: smooth streaming while scrolling UI
- Isolate RAM consumption log during inference
