import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:kynos/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/huggingface_token_provider.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:kynos/shared/utils/health_permission_feedback.dart';
import 'package:kynos/shared/utils/health_platform_labels.dart';
import 'package:kynos/shared/utils/url_opener.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _hfTokenController = TextEditingController();
  bool _obscureKey = true;
  bool _obscureHfToken = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _hfTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final kynos = context.kynosTheme;
    final permissionState = ref.watch(healthPermissionsProvider);
    final importedCountAsync = ref.watch(importedWorkoutCountProvider);

    ref.listen(openRouterApiKeyManagerProvider, (_, next) {
      next.whenData((key) {
        if (key != null && _apiKeyController.text != key) {
          _apiKeyController.text = key;
        }
      });
    });

    ref.listen(huggingFaceTokenManagerProvider, (_, next) {
      next.whenData((token) {
        if (token != null && _hfTokenController.text != token) {
          _hfTokenController.text = token;
        }
      });
    });

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          children: [
            SettingsAppearanceSection(
              settings: settings,
              onThemeChanged: settingsNotifier.updateThemeMode,
            ),
            const Gap(tokens.Spacing.lg),
            const KynosSectionHeader(title: 'Health & Data'),
            const Gap(tokens.Spacing.sm),
            KynosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.favorite_outline, color: kynos.stand),
                    title: Text(
                      'Health connection',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(_healthStatusLabel(permissionState)),
                  ),
                  if (!kIsWeb) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: permissionState.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(healthPermissionsProvider.notifier)
                                    .request();
                                if (!context.mounted) return;
                                ref.read(healthPermissionsProvider).whenOrNull(
                                  data: (granted) {
                                    final platform =
                                        HealthPlatformLabels.platformName();
                                    final message = granted
                                        ? HealthPermissionFeedback.connectedMessage(
                                            platform,
                                          )
                                        : HealthPermissionFeedback
                                            .permissionDeniedMessage(platform);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  },
                                  error: (_, _) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          HealthPermissionFeedback
                                              .connectionFailedMessage(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                        child: Text(
                          permissionState.isLoading
                              ? 'Connecting…'
                              : HealthPlatformLabels.connectLabel(),
                        ),
                      ),
                    ),
                    Divider(color: kynos.separator, height: 1),
                  ],
                  _ActionTile(
                    title: 'Import Apple Health export',
                    icon: Icons.upload_file_outlined,
                    onTap: () => context.push(Routes.healthImport),
                  ),
                  Divider(color: kynos.separator, height: 1),
                  _ActionTile(
                    title: 'Log run manually',
                    icon: Icons.edit_outlined,
                    onTap: () => context.push(Routes.manualRun),
                  ),
                  Divider(color: kynos.separator, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.storage_outlined, color: kynos.stand),
                    title: Text(
                      'Imported runs',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: importedCountAsync.when(
                      data: (count) => Text('$count stored on this device'),
                      loading: () => const Text('Loading…'),
                      error: (_, _) => const Text('Unavailable'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _confirmClearImportedData(context),
                      child: const Text('Clear imported data'),
                    ),
                  ),
                  const Gap(tokens.Spacing.xs),
                  Text(
                    HealthPlatformLabels.sideloadHint(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kynos.secondaryLabel,
                        ),
                  ),
                ],
              ),
            ),
            const Gap(tokens.Spacing.lg),
            const KynosSectionHeader(title: 'AI & Cloud'),
            const Gap(tokens.Spacing.sm),
            KynosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: tokens.Spacing.sm),
                    child: Text(
                      'HuggingFace access token',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextField(
                    controller: _hfTokenController,
                    obscureText: _obscureHfToken,
                    decoration: InputDecoration(
                      hintText: 'hf_...',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureHfToken
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscureHfToken = !_obscureHfToken,
                        ),
                      ),
                    ),
                    onSubmitted: (v) => _saveHfToken(v),
                  ),
                  const Gap(tokens.Spacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _saveHfToken(_hfTokenController.text),
                      child: const Text('Save token'),
                    ),
                  ),
                  const Gap(tokens.Spacing.xs),
                  Text(
                    'Required for gated Gemma models. Public models like Qwen3 0.6B '
                    'do not need a token. Create one at huggingface.co/settings/tokens.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kynos.secondaryLabel,
                        ),
                  ),
                  Divider(color: kynos.separator, height: 1),
                  ListTile(
                    leading: Icon(Icons.memory_rounded, color: kynos.purple),
                    title: Text(
                      'On-device model',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(settings.selectedLocalModelName),
                    trailing: Icon(Icons.chevron_right, color: kynos.tertiaryLabel),
                    onTap: () async {
                      await context.push<String>(Routes.onDeviceModels);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Gap(tokens.Spacing.xs),
                  Text(
                    'Choose a lightweight local model for coach chat. '
                    'Smaller models use less RAM on your phone.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kynos.secondaryLabel,
                        ),
                  ),
                  Divider(color: kynos.separator, height: 1),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: tokens.Spacing.sm,
                      bottom: tokens.Spacing.sm,
                    ),
                    child: Text(
                      'OpenRouter API key',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      hintText: 'sk-or-...',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                    onSubmitted: (v) => _saveApiKey(v),
                  ),
                  const Gap(tokens.Spacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _saveApiKey(_apiKeyController.text),
                      child: const Text('Save key'),
                    ),
                  ),
                  Divider(color: kynos.separator, height: 1),
                  _SwitchTile(
                    title: 'Advanced cloud tasks',
                    icon: Icons.cloud_outlined,
                    value: settings.cloudTasksEnabled,
                    onChanged: settingsNotifier.updateCloudTasksEnabled,
                  ),
                  Divider(color: kynos.separator, height: 1),
                  _DropdownTile(
                    title: 'Cloud data level',
                    icon: Icons.shield_outlined,
                    value: settings.cloudDataLevel.name,
                    items: CloudDataLevel.values
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.name,
                            child: Text(l.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final level = CloudDataLevel.values.firstWhere(
                        (l) => l.name == v,
                      );
                      settingsNotifier.updateCloudDataLevel(level);
                    },
                  ),
                  Divider(color: kynos.separator, height: 1),
                  ListTile(
                    leading: Icon(Icons.hub_outlined, color: kynos.stand),
                    title: Text(
                      'Cloud model',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      settings.hasSelectedCloudModel
                          ? settings.selectedCloudModelName!
                          : 'Choose a model',
                    ),
                    trailing: Icon(Icons.chevron_right, color: kynos.tertiaryLabel),
                    onTap: () async {
                      final selected =
                          await context.push<String>(Routes.openRouterModels);
                      if (selected != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected $selected')),
                        );
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Gap(tokens.Spacing.xs),
                  Text(
                    'Cloud inference sends summarized health metrics to '
                    'your chosen OpenRouter model. Keys are stored securely '
                    'on-device.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kynos.secondaryLabel,
                        ),
                  ),
                ],
              ),
            ),
            const Gap(tokens.Spacing.lg),
            const KynosSectionHeader(title: 'Onboarding'),
            const Gap(tokens.Spacing.sm),
            KynosCard(
              child: _ActionTile(
                title: 'Replay onboarding',
                icon: Icons.replay_outlined,
                onTap: () => _replayOnboarding(context),
              ),
            ),
            const Gap(tokens.Spacing.lg),
            const KynosSectionHeader(title: 'Legal'),
            const Gap(tokens.Spacing.sm),
            KynosCard(
              child: Column(
                children: [
                  _ActionTile(
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => _openLegalUrl(
                      context,
                      AppConstants.privacyPolicyUrl,
                      'Privacy Policy',
                    ),
                  ),
                  Divider(color: kynos.separator, height: 1),
                  _ActionTile(
                    title: 'Terms of Service',
                    icon: Icons.description_outlined,
                    onTap: () => _openLegalUrl(
                      context,
                      AppConstants.termsOfServiceUrl,
                      'Terms of Service',
                    ),
                  ),
                ],
              ),
            ),
            const Gap(tokens.Spacing.xl),
          ],
        ),
    );
  }

  Future<void> _openLegalUrl(
    BuildContext context,
    String url,
    String label,
  ) async {
    final opened = await openExternalUrl(url);
    if (!context.mounted) return;
    if (!opened) showUrlLaunchError(context, label);
  }

  Future<void> _replayOnboarding(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replay onboarding?'),
        content: const Text(
          'This resets onboarding and returns you to the welcome flow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replay'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(onboardingCompletedProvider.notifier).resetOnboarding();
    if (!context.mounted) return;
    context.go(Routes.onboarding);
  }

  String _healthStatusLabel(AsyncValue<bool> permissionState) {
    if (kIsWeb) {
      return 'Web preview — import runs locally instead.';
    }
    return permissionState.when(
      data: (granted) => granted
          ? HealthPlatformLabels.connectedLabel()
          : 'Not connected — import runs or grant access',
      loading: () => 'Checking connection…',
      error: (_, _) => 'Unavailable — use import or manual entry',
    );
  }

  Future<void> _confirmClearImportedData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear imported data?'),
        content: const Text(
          'This removes all imported runs and routes from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(importedHealthDataProvider.notifier).clearAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imported data cleared')),
    );
  }

  Future<void> _saveHfToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      await ref.read(huggingFaceTokenManagerProvider.notifier).clear();
    } else {
      await ref.read(huggingFaceTokenManagerProvider.notifier).save(trimmed);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HuggingFace token saved')),
      );
    }
  }

  Future<void> _saveApiKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      await ref.read(openRouterApiKeyManagerProvider.notifier).clear();
    } else {
      await ref.read(openRouterApiKeyManagerProvider.notifier).save(trimmed);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OpenRouter key saved')),
      );
    }
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.kynosTheme.stand),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.kynosTheme.stand),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return ListTile(
      leading: Icon(icon, color: kynos.stand),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: Icon(Icons.chevron_right, color: kynos.tertiaryLabel),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
