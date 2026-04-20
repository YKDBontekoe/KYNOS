import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/features/coach_chat/presentation/coach_chat_page.dart';
import 'package:kynos/features/dashboard/presentation/dashboard_page.dart';

/// All named route paths — single source of truth.
abstract final class Routes {
  static const dashboard = '/';
  static const coachChat = '/chat';
  static const nexusLab = '/lab';
  static const trainingPlan = '/plan';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    routes: [
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: Routes.coachChat,
        builder: (context, state) => const CoachChatPage(),
      ),
      // Additional routes added as features are built:
      // GoRoute(path: Routes.nexusLab, ...)
      // GoRoute(path: Routes.trainingPlan, ...)
      // GoRoute(path: Routes.settings, ...)
    ],
  );
});
