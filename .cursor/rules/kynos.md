# KYNOS agent rules

1. Read [CODEMAP.md](../../CODEMAP.md) before editing code.
2. Follow [AGENTS.md](../../AGENTS.md) for architecture and PR workflow.
3. Never import `infrastructure/` from `features/` — use `shared/providers/`.
4. Never import one feature's `providers/` from another feature.
5. Keep hand-written files under ~250 lines; split into `presentation/widgets/`.
6. Run `dart run tool/generate_codemap.dart` after structural changes.
