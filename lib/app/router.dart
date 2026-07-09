import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/not_found_page.dart';
import 'package:kynos/app/page_transitions.dart';
import 'package:kynos/app/shell_navigation_scope.dart';
import 'package:kynos/app/shell_page.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/features/coach_chat/presentation/pages/coach_chat_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_history_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_route_missing_page.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_route_page.dart';
import 'package:kynos/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:kynos/features/legal/presentation/pages/terms_of_service_page.dart';
import 'package:kynos/features/nexus_lab/presentation/nexus_lab_page.dart';
import 'package:kynos/features/onboarding/presentation/onboarding_page.dart';
import 'package:kynos/features/settings/presentation/pages/health_import_page.dart';
import 'package:kynos/features/settings/presentation/pages/manual_run_page.dart';
import 'package:kynos/features/settings/presentation/pages/on_device_model_picker_page.dart';
import 'package:kynos/features/settings/presentation/pages/openrouter_model_picker_page.dart';
import 'package:kynos/features/settings/presentation/pages/settings_page.dart';
import 'package:kynos/shared/providers/onboarding_provider.dart';

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
  static const onDeviceModels = '/settings/on-device-models';
  static const healthImport = '/settings/import';
  static const manualRun = '/settings/manual-run';
  static const privacyPolicy = '/settings/privacy';
  static const termsOfService = '/settings/terms';
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(onboardingCompletedProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(onboardingCompletedProvider);
  final refresh = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation:
        hasCompletedOnboarding ? Routes.dashboard : Routes.onboarding,
    refreshListenable: refresh,
    redirect: (context, state) {
      final completed = ref.read(onboardingCompletedProvider);
      final isOnboarding = state.matchedLocation == Routes.onboarding;
      final isImportHandoff = state.matchedLocation == Routes.healthImport;

      if (!completed && !isOnboarding && !isImportHandoff) {
        return Routes.onboarding;
      }
      if (completed && isOnboarding) return Routes.dashboard;

      return null;
    },
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (context, state) => KynosPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const OnboardingPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                pageBuilder: (context, state) => KynosPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const DashboardTab(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.training,
                pageBuilder: (context, state) => KynosPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const TrainingTab(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.character,
                pageBuilder: (context, state) => KynosPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const CharacterTab(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.runHistory,
        pageBuilder: (context, state) => KynosPageTransitions.standard(
          key: state.pageKey,
          child: const RunHistoryPage(),
        ),
      ),
      GoRoute(
        path: Routes.runRoute,
        pageBuilder: (context, state) {
          final run = state.extra;
          final child = run is WorkoutSession
              ? RunRoutePage(run: run)
              : const RunRouteMissingPage();
          return KynosPageTransitions.standard(
            key: state.pageKey,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: ':runId',
            pageBuilder: (context, state) {
              final extra = state.extra;
              final Widget child;
              if (extra is WorkoutSession) {
                child = RunRoutePage(run: extra);
              } else {
                final runId = state.pathParameters['runId'];
                child = runId == null || runId.isEmpty
                    ? const RunRouteMissingPage()
                    : RunRoutePage(runId: runId);
              }
              return KynosPageTransitions.standard(
                key: state.pageKey,
                child: child,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.coachChat,
        pageBuilder: (context, state) {
          final threadId = state.uri.queryParameters['threadId'];
          return KynosPageTransitions.modalUp(
            key: state.pageKey,
            child: CoachChatPage(threadId: threadId),
          );
        },
      ),
      GoRoute(
        path: Routes.nexusLab,
        pageBuilder: (context, state) => KynosPageTransitions.modalUp(
          key: state.pageKey,
          child: const NexusLabPage(),
        ),
      ),
      GoRoute(
        path: Routes.settings,
        pageBuilder: (context, state) => KynosPageTransitions.standard(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
        routes: [
          GoRoute(
            path: 'on-device-models',
            pageBuilder: (context, state) => KynosPageTransitions.horizontalDrill(
              key: state.pageKey,
              child: const OnDeviceModelPickerPage(),
            ),
          ),
          GoRoute(
            path: 'openrouter-models',
            pageBuilder: (context, state) => KynosPageTransitions.horizontalDrill(
              key: state.pageKey,
              child: const OpenRouterModelPickerPage(),
            ),
          ),
          GoRoute(
            path: 'import',
            pageBuilder: (context, state) => KynosPageTransitions.horizontalDrill(
              key: state.pageKey,
              child: const HealthImportPage(),
            ),
          ),
          GoRoute(
            path: 'manual-run',
            pageBuilder: (context, state) => KynosPageTransitions.horizontalDrill(
              key: state.pageKey,
              child: const ManualRunPage(),
            ),
          ),
          GoRoute(
            path: 'privacy',
            pageBuilder: (context, state) => KynosPageTransitions.horizontalDrill(
              key: state.pageKey,
              child: const PrivacyPolicyPage(),
            ),
          ),
          GoRoute(
            path: 'terms',
            pageBuilder: (context, state) => KynosPageTransitions.horizontalDrill(
              key: state.pageKey,
              child: const TermsOfServicePage(),
            ),
          ),
        ],
      ),
    ],
  );
});
