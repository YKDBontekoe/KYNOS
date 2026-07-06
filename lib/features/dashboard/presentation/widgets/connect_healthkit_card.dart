import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/utils/health_platform_labels.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Prompt card to connect health data when no summary is available.
class ConnectHealthkitCard extends ConsumerWidget {
  const ConnectHealthkitCard({super.key});

  String _platformLabel() => HealthPlatformLabels.platformName();

  String _settingsHint() => HealthPlatformLabels.settingsHint();

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
          const Gap(Spacing.xs),
          Text(
            'Grant access via $platform to unlock your readiness score and AI coaching insights. '
            'Sideloaded installs can import Apple Health export.zip or log runs manually.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(Spacing.md),
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
                            : '$platform permission not granted. ${_settingsHint()}';
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
          if (!isLoading) ...[
            const Gap(Spacing.sm),
            TextButton(
              onPressed: () => context.push(Routes.healthImport),
              child: const Text('Import run from file'),
            ),
            TextButton(
              onPressed: () => context.push(Routes.manualRun),
              child: const Text('Log a run manually'),
            ),
          ],
        ],
      ),
    );
  }
}
