---
name: ui-design-system
description: Apply KYNOS UI design system conventions. Use when editing feature screens, shared widgets, spacing, typography, loading states, or charts.
paths:
  - "lib/features/**"
  - "lib/shared/widgets/**"
---

# UI Design System

## When to Use

- Editing screens in `lib/features/` or widgets in `lib/shared/widgets/`
- Adding metrics, cards, loading states, or charts

## Imports

```dart
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/widgets.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
```

Access tokens: `context.kynosTheme`

## Widgets

| Widget | Use for |
|--------|---------|
| `KynosCard` | Default content container |
| `MetricTile` | 2-column metric grids (`value: null` → shimmer) |
| `KynosSectionHeader` | Uppercase section labels |
| `KynosHeroBanner` | Coloured tab hero banners |
| `KynosChip` | Badges, metric chips |
| `KynosLoadingLine` | In-card async loading (shimmer) |
| `KynosSkeleton` | Full-page loading placeholders |
| `GlassCard` | Coach bubbles, floating nav only |
| `RunCard` | Workout session list items |

## Rules

- Spacing: `Gap(tokens.Spacing.sm)` — **never** `Gap(8)` or raw numbers
- Typography: `Theme.of(context).textTheme` or `context.kynosTheme` — no inline `GoogleFonts` in features
- Metrics: `kynosTheme.metricValueStyle` (DM Mono)
- Loading: shimmer skeletons, not spinners inside cards
- Charts: `fl_chart` only
- Colors: `context.kynosTheme` / `AppTheme` — never raw `Colors.red`

## CI Check

```bash
bash scripts/check_design_system.sh
```
