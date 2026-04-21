import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/shell_page.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/features/dashboard/presentation/run_history_page.dart';
import 'package:kynos/features/dashboard/presentation/run_route_page.dart';
import 'package:kynos/features/onboarding/presentation/onboarding_page.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';

/// All named route paths — single source of truth.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const dashboard = '/';
  static const runRoute = '/run-route';
  static const runHistory = '/run-history';
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
    ],
  );
});
