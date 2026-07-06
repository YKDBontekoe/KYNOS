---
name: open-pr
description: Open and shepherd a KYNOS pull request. Use when creating a PR, pushing a branch, or monitoring review feedback until merge.
---

# Open PR

## When to Use

- "Open a PR", "create pull request", "push and open PR"
- After `/validate-change` passes

## Before Opening

Run `/validate-change` — all checks must pass.

## Branch and Push

```bash
git checkout -b cursor/<descriptive-name>-d1bd
git add -A && git commit -m "feat: descriptive message"
git push -u origin cursor/<descriptive-name>-d1bd
```

## PR Title (CI enforced)

Format: `type` or `type(scope): subject` — **lowercase subject**

Examples:
- `feat: add coach readiness widgets`
- `fix(ios): healthkit permission snackbar shows settings hint`
- `docs: make repo more agent-friendly`

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

## PR Body

Use the [.github/pull_request_template.md](../../../.github/pull_request_template.md) checklist.

## After Opening — Mandatory Monitoring

1. Poll for review comments (humans, CodeRabbit, CI failures)
2. Fix issues, push, re-run validation
3. Reply on each comment thread explaining what changed
4. React 👍 on every addressed comment
5. Do **not** abandon the PR until merged or explicitly closed

See [AGENTS.md §4](../../../AGENTS.md#4-pull-request--review-process).
