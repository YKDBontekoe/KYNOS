import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

class SettingsAppearanceSection extends StatelessWidget {
  const SettingsAppearanceSection({
    super.key,
    required this.settings,
    required this.onThemeChanged,
  });

  final SettingsState settings;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KynosSectionHeader(title: 'Appearance'),
        const Gap(tokens.Spacing.sm),
        KynosCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Dark Mode', style: Theme.of(context).textTheme.titleMedium),
            secondary: Icon(Icons.dark_mode_outlined, color: kynos.stand),
            value: settings.isDarkMode,
            onChanged: onThemeChanged,
          ),
        ),
      ],
    );
  }
}
