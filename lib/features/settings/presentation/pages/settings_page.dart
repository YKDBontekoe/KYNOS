import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/settings/providers/settings_controller.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final kynos = context.kynosTheme;

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
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
                  value: controller.isDarkMode,
                  onChanged: controller.updateThemeMode,
                ),
                Divider(color: kynos.separator, height: 1),
                _DropdownTile(
                  title: 'Language',
                  icon: Icons.language,
                  value: controller.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.updateLanguage(newValue);
                    }
                  },
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
    );
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
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
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
