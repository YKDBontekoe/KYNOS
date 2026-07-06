# Architecture (always apply)

Layer dependency direction — **never invert**:

```text
features/ → domain/ ← infrastructure/
features/ → shared/providers/ → domain + infrastructure
```

## Banned imports

| From | Must NOT import |
|------|-----------------|
| `lib/features/` | `package:kynos/infrastructure/` |
| `lib/features/` | another feature's `providers/` |
| `lib/domain/` | `package:flutter`, `flutter_riverpod`, `riverpod` |

## Enforcement

```bash
bash scripts/check_architecture.sh
```

## When violating for DI

Move bindings to `lib/shared/providers/` and re-export types if features need them.
See `/wire-repository` skill.

Reference: [AGENTS.md §5](../../AGENTS.md#5-dependency-rule-strictly-enforced)
