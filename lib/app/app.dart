import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/ai_lifecycle_guard.dart';

class KynosApp extends ConsumerWidget {
  const KynosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return AiLifecycleGuard(
      child: MaterialApp.router(
        title: 'KYNOS',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
