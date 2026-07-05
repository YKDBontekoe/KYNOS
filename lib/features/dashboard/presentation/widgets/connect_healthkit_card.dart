import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Prompt card to connect HealthKit when no summary is available.
class ConnectHealthkitCard extends ConsumerWidget {
  const ConnectHealthkitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(healthPermissionsProvider);
    final isLoading = permissionState.isLoading;

    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect HealthKit',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            'Grant access to recovery and workout data to unlock your readiness score and AI coaching insights.',
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
                            ? 'HealthKit connected.'
                            : 'HealthKit permission not granted. Enable access in Settings > Health > Data Access & Devices > Kynos.';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      error: (error, _) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'HealthKit connection failed: $error',
                            ),
                          ),
                        );
                      },
                    );
                  },
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Connect HealthKit'),
          ),
        ],
      ),
    );
  }
}
