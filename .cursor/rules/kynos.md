# KYNOS agent rules

Read [docs/agents/README.md](../../docs/agents/README.md) for the full agent hub.

## Always

1. Read [CODEMAP.md](../../CODEMAP.md) before editing code.
2. Follow [AGENTS.md](../../AGENTS.md) for architecture and PR workflow.
3. Use Cursor skills in `.cursor/skills/` — `/onboard-agent`, `/add-feature`, `/validate-change`, `/open-pr`.
4. Never import `infrastructure/` from `features/` — use `shared/providers/`.
5. Never import one feature's `providers/` from another feature.
6. Keep hand-written files under ~250 lines; split into `presentation/widgets/`.
7. Run `dart run tool/generate_codemap.dart` after structural changes.
8. PR titles: Conventional Commits with lowercase subject — CI enforces this.

## Key files

- `lib/app/router.dart` — routes (`Routes` constants)
- `lib/shared/providers/` — DI composition root
- `docs/agents/file-templates.md` — scaffolds for new files
