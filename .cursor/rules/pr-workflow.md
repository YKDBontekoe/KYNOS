# PR workflow (always apply)

A task is **not complete** until the PR is merged or explicitly closed.

## Before opening

Run `/validate-change` — all checks must pass including `flutter build web`.

## PR requirements

- Target: `main`
- Title: Conventional Commits — `type` or `type(scope): subject`, lowercase subject
- Branch (agents): `cursor/<descriptive-name>-d1bd`
- Fill [.github/pull_request_template.md](../../.github/pull_request_template.md)
- Attach visual proof for UI changes

## After opening — mandatory

1. Monitor review comments (humans, CodeRabbit, CI)
2. Fix, push, re-validate
3. Reply on each comment thread
4. 👍 every addressed comment
5. Do not abandon the PR

Reference: [AGENTS.md §4](../../AGENTS.md#4-pull-request--review-process)
