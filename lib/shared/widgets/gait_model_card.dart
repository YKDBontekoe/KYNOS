import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

/// Gait model coefficients display with optional calibration action.
class GaitModelCard extends StatelessWidget {
  const GaitModelCard({
    super.key,
    required this.coefficients,
    this.calibratedAt,
    this.onCalibrate,
    this.isLoading = false,
    this.errorMessage,
    this.webOnlyMessage,
    this.coefficientPrecision = 4,
  });

  final ({double? b0, double? b1, double? b2}) coefficients;
  final DateTime? calibratedAt;
  final VoidCallback? onCalibrate;
  final bool isLoading;
  final String? errorMessage;
  final String? webOnlyMessage;
  final int coefficientPrecision;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.purple,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  'Gait Model',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(
                Icons.lock_rounded,
                size: 12,
                color: AppTheme.tertiaryLabel,
              ),
              const Gap(tokens.Spacing.xs),
              Text(
                'On-device',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.tertiaryLabel,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            'Biomechanics regression trained on your run history. '
            'Predicts stride length from cadence and power.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.md),
          if (webOnlyMessage != null)
            Text(
              webOnlyMessage!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.secondaryLabel,
              ),
            )
          else if (isLoading)
            const LinearProgressIndicator()
          else if (errorMessage != null)
            Text(
              'Calibration unavailable: $errorMessage',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.move),
            )
          else
            _CoefficientsRow(
              coefficients: coefficients,
              calibratedAt: calibratedAt,
              precision: coefficientPrecision,
            ),
          const Gap(tokens.Spacing.md),
          FilledButton.icon(
            onPressed: onCalibrate,
            icon: const Icon(Icons.science_rounded, size: 18),
            label: Text(
              webOnlyMessage != null ? 'Available On iOS' : 'Run Calibration',
            ),
          ),
        ],
      ),
    );
  }
}

class _CoefficientsRow extends StatelessWidget {
  const _CoefficientsRow({
    required this.coefficients,
    required this.calibratedAt,
    required this.precision,
  });

  final ({double? b0, double? b1, double? b2}) coefficients;
  final DateTime? calibratedAt;
  final int precision;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'β0 Intercept',
                value: _fmt(coefficients.b0),
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'β1 Cadence',
                value: _fmt(coefficients.b1),
                accentColor: AppTheme.exercise,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'β2 Power',
                value: _fmt(coefficients.b2),
                accentColor: AppTheme.energy,
              ),
            ),
          ],
        ),
        if (calibratedAt != null) ...[
          const Gap(tokens.Spacing.xs),
          Text(
            'Last calibrated ${_calibratedLabel(calibratedAt!)}',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.tertiaryLabel,
            ),
          ),
        ],
      ],
    );
  }

  String? _fmt(double? v) => v?.toStringAsFixed(precision);

  String _calibratedLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Async wrapper for [GaitModelCard] backed by Riverpod state.
class GaitModelCardAsync extends StatelessWidget {
  const GaitModelCardAsync({
    super.key,
    required this.labState,
    required this.onCalibrate,
    this.webOnlyMessage,
  });

  final AsyncValue<
      ({
        ({double? b0, double? b1, double? b2}) coefficients,
        DateTime? calibratedAt,
      })>? labState;
  final VoidCallback? onCalibrate;
  final String? webOnlyMessage;

  @override
  Widget build(BuildContext context) {
    if (labState == null) {
      return GaitModelCard(
        coefficients: (b0: null, b1: null, b2: null),
        onCalibrate: onCalibrate,
        webOnlyMessage: webOnlyMessage ??
            'Gait model calibration is available on iOS devices only.',
      );
    }

    return labState!.when(
      loading: () => GaitModelCard(
        coefficients: (b0: null, b1: null, b2: null),
        onCalibrate: onCalibrate,
        isLoading: true,
      ),
      error: (e, _) => GaitModelCard(
        coefficients: (b0: null, b1: null, b2: null),
        onCalibrate: onCalibrate,
        errorMessage: '$e',
      ),
      data: (state) => GaitModelCard(
        coefficients: state.coefficients,
        calibratedAt: state.calibratedAt,
        onCalibrate: onCalibrate,
      ),
    );
  }
}
