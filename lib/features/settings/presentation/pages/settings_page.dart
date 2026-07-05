import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  bool _keyLoaded = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    if (_keyLoaded) return;
    final key = await ref.read(secureApiKeyStorageProvider).readOpenRouterKey();
    if (key != null) {
      _apiKeyController.text = key;
    }
    _keyLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final kynos = context.kynosTheme;

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder<void>(
        future: _loadApiKey(),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          children: [
            const KynosSectionHeader(title: 'Appearance'),
            const Gap(tokens.Spacing.sm),
            KynosCard(
              child: Column(
                children: [
                  _SwitchTile(
                    title: 'Dark Mode',
                    icon: Icons.dark_mode_outlined,
                    value: settings.isDarkMode,
                    onChanged: settingsNotifier.updateThemeMode,
                  ),
                  Divider(color: kynos.separator, height: 1),
                  _DropdownTile(
                    title: 'Language',
                    icon: Icons.language,
                    value: settings.languageCode,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                    ],
                    onChanged: (v) {
                      if (v != null) settingsNotifier.updateLanguage(v);
                    },
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
                    onTap: () => context.push(Routes.openRouterModels),
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
            const KynosSectionHeader(title: 'Legal'),
            const Gap(tokens.Spacing.sm),
            KynosCard(
              child: Column(
                children: [
                  _ActionTile(
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigating to Privacy Policy...'),
                        ),
                      );
                    },
                  ),
                  Divider(color: kynos.separator, height: 1),
                  _ActionTile(
                    title: 'Terms of Service',
                    icon: Icons.description_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigating to Terms of Service...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Gap(LayoutTokens.shellBottomPadding),
          ],
        ),
      ),
    );
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
