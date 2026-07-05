import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/features/settings/providers/settings_controller.dart';
import 'package:provider/provider.dart';

class KynosApp extends StatelessWidget {
  const KynosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsController(),
      child: riverpod.Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(routerProvider);
          final settingsController = context.watch<SettingsController>();

          return MaterialApp.router(
            title: 'KYNOS',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingsController.themeMode,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
