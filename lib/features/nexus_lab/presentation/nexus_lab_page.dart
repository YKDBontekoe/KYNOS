import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/providers/nexus_lab_provider.dart';
import 'package:kynos/shared/utils/navigation_utils.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

class NexusLabPage extends ConsumerWidget {
  const NexusLabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nexusLabProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('KYNOS Lab'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close KYNOS Lab',
          onPressed: () => popOrGo(context, Routes.dashboard),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: state.when(
            loading: () => const _LoadingState(),
            error: (error, _) => _ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(nexusLabProvider),
            ),
            data: (data) => _Content(
              state: data,
              onCalibrate: () =>
                  ref.read(nexusLabProvider.notifier).calibrate(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.onCalibrate});

  final NexusLabState state;
  final VoidCallback onCalibrate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'On-device continual calibration for your gait coefficients.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.md),
          KynosCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Steady State Calibration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(tokens.Spacing.xs),
                Text(
                  'Trains β0, β1, β2 from local cadence, power, and stride metrics. '
                  'No raw biometric data leaves this device.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Gap(tokens.Spacing.md),
                FilledButton.icon(
                  onPressed: onCalibrate,
                  icon: const Icon(Icons.science_rounded),
                  label: const Text('Run Calibration'),
                ),
                if (state.calibratedAt != null) ...[
                  const Gap(tokens.Spacing.sm),
                  Text(
                    'Last calibrated: ${state.calibratedAt}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ],
            ),
          ),
          const Gap(tokens.Spacing.md),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'β0 Intercept',
                  value: _fmt(state.coefficients.b0),
                  accentColor: AppTheme.stand,
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: MetricTile(
                  label: 'β1 Cadence',
                  value: _fmt(state.coefficients.b1),
                  accentColor: AppTheme.exercise,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          MetricTile(
            label: 'β2 Power',
            value: _fmt(state.coefficients.b2),
            accentColor: AppTheme.energy,
          ),
          if (state.calibrationSummary != null) ...[
            const Gap(tokens.Spacing.md),
            KynosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calibration Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(tokens.Spacing.sm),
                  Text(
                    state.calibrationSummary!,
                    style: GoogleFonts.dmMono(
                      fontSize: 12,
                      height: 1.4,
                      color: AppTheme.secondaryLabel,
                    ),
                  ),
                  const Gap(tokens.Spacing.xs),
                  Text(
                    'Steady-state samples: ${state.sampleCount}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _fmt(double? value) {
    if (value == null) {
      return '—';
    }
    return value.toStringAsFixed(6);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MetricTile(label: 'β0 Intercept', value: null),
        Gap(tokens.Spacing.sm),
        MetricTile(label: 'β1 Cadence', value: null),
        Gap(tokens.Spacing.sm),
        MetricTile(label: 'β2 Power', value: null),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: KynosCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.move),
            const Gap(tokens.Spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(tokens.Spacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
