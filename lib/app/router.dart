import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/not_found_page.dart';
import 'package:kynos/app/shell_page.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/features/coach_chat/presentation/pages/coach_chat_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_history_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_route_missing_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_route_page.dart';
import 'package:kynos/features/nexus_lab/presentation/nexus_lab_page.dart';
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
  static const training = '/training';
  static const character = '/character';
  static const runRoute = '/run-route';
  static const runHistory = '/run-history';
  static const coachChat = '/coach';
  static const settings = '/settings';
  static const nexusLab = '/nexus-lab';
  static const openRouterModels = '/settings/openrouter-models';
  static const healthImport = '/settings/import';
  static const manualRun = '/settings/manual-run';
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(onboardingCompletedProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
  final refresh = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation:
        hasCompletedOnboarding ? Routes.dashboard : Routes.onboarding,
    refreshListenable: refresh,
    redirect: (context, state) {
      final completed = ref.read(onboardingCompletedProvider);
      final isOnboarding = state.matchedLocation == Routes.onboarding;

      if (!completed && !isOnboarding) return Routes.onboarding;
      if (completed && isOnboarding) return Routes.dashboard;

      return null;
    },
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                builder: (context, state) => const DashboardTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.training,
                builder: (context, state) => const TrainingTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.character,
                builder: (context, state) => const CharacterTab(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.runHistory,
        builder: (context, state) => const RunHistoryPage(),
      ),
      GoRoute(
        path: Routes.runRoute,
        builder: (context, state) {
          final run = state.extra;
          if (run is! WorkoutSession) return const RunRouteMissingPage();
          return RunRoutePage(run: run);
        },
      ),
      GoRoute(
        path: Routes.coachChat,
        builder: (context, state) => const CoachChatPage(),
      ),
      GoRoute(
        path: Routes.nexusLab,
        builder: (context, state) => const NexusLabPage(),
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
