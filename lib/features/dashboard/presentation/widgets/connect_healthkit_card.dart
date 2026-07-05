import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Prompt card to connect health data when no summary is available.
class ConnectHealthkitCard extends ConsumerWidget {
  const ConnectHealthkitCard({super.key});

  String _platformLabel() {
    if (kIsWeb) return 'health data';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'HealthKit',
      TargetPlatform.android => 'Health Connect',
      _ => 'health data',
    };
  }

  String _settingsHint() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS =>
        'Enable access in Settings > Health > Data Access & Devices > Kynos.',
      TargetPlatform.android =>
        'Enable access in Settings > Apps > Kynos > Permissions > Health Connect.',
      _ => 'Enable health permissions in system settings.',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(healthPermissionsProvider);
    final isLoading = permissionState.isLoading;
    final platform = _platformLabel();

    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect Health',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            'Grant access via $platform to unlock your readiness score and AI coaching insights.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.md),
          FilledButton(
            onPressed: isLoading
                ? null
                : () async {
                    await ref
                        .read(healthPermissionsProvider.notifier)
                        .request();

                    if (!context.mounted) return;

                    ref.read(healthPermissionsProvider).whenOrNull(
                      data: (granted) {
                        final message = granted
                            ? '$platform connected.'
                            : '$platform permission not granted. $_settingsHint()';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      error: (error, _) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Health connection failed: $error',
                            ),
                          ),
                        );
                      },
                    );
                  },
            child: Text(isLoading ? 'Connecting…' : 'Connect $platform'),
          ),
        ],
      ),
    );
  }
}
