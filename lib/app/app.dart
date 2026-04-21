import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';

class KynosApp extends ConsumerWidget {
  const KynosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(
      settingsNotifierProvider.select((s) => s.themeMode),
    );

    return MaterialApp.router(
      title: 'KYNOS',
      theme: AppTheme.light,
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
