import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/shell_page.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/features/coach_chat/presentation/pages/coach_chat_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_history_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_route_page.dart';
import 'package:kynos/features/onboarding/presentation/onboarding_page.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:kynos/features/settings/presentation/pages/health_import_page.dart';
import 'package:kynos/features/settings/presentation/pages/manual_run_page.dart';
import 'package:kynos/features/settings/presentation/pages/openrouter_model_picker_page.dart';
import 'package:kynos/features/settings/presentation/pages/settings_page.dart';

/// All named route paths — single source of truth.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const dashboard = '/';
  static const runRoute = '/run-route';
  static const runHistory = '/run-history';
  static const coachChat = '/coach';
  static const settings = '/settings';
  static const openRouterModels = '/settings/openrouter-models';
  static const healthImport = '/settings/import';
  static const manualRun = '/settings/manual-run';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.onboarding,
    redirect: (context, state) {
      final hasCompletedOnboarding = ref.watch(onboardingCompletedProvider);
      final isOnboarding = state.matchedLocation == Routes.onboarding;

      if (!hasCompletedOnboarding && !isOnboarding) return Routes.onboarding;
      if (hasCompletedOnboarding && isOnboarding) return Routes.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const ShellPage(),
      ),
      GoRoute(
        path: Routes.runHistory,
        builder: (context, state) => const RunHistoryPage(),
      ),
      GoRoute(
        path: Routes.runRoute,
        builder: (context, state) {
          final run = state.extra;
          if (run is! WorkoutSession) return const ShellPage();
          return RunRoutePage(run: run);
        },
      ),
      GoRoute(
        path: Routes.coachChat,
        builder: (context, state) => const CoachChatPage(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'openrouter-models',
            builder: (context, state) => const OpenRouterModelPickerPage(),
          ),
          GoRoute(
            path: 'import',
            builder: (context, state) => const HealthImportPage(),
          ),
          GoRoute(
            path: 'manual-run',
            builder: (context, state) => const ManualRunPage(),
          ),
        ],
      ),
    ],
  );
});
