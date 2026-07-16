import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/shared/providers/ai_reconnect_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/plan_health_sync_provider.dart';
import 'package:logger/logger.dart';

/// Disposes the on-device AI isolate when the app backgrounds to avoid stale LiteRT state.
class AiLifecycleGuard extends ConsumerStatefulWidget {
  const AiLifecycleGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AiLifecycleGuard> createState() => _AiLifecycleGuardState();
}

class _AiLifecycleGuardState extends ConsumerState<AiLifecycleGuard>
    with WidgetsBindingObserver {
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _disposeLocalAi();
    } else if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  Future<void> _disposeLocalAi() async {
    try {
      await ref.read(localAiCoachRepositoryProvider).dispose();
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Failed to dispose local AI on lifecycle pause',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onAppResumed() {
    if (!kIsWeb) {
      ref.invalidate(healthSummaryProvider);
      ref.invalidate(healthHistoryProvider);
      ref.invalidate(recentRunsProvider);
      ref.invalidate(importedWorkoutCountProvider);
      ref.invalidate(healthPermissionsProvider);
      // Auto-adherence + post-run debrief after health refresh.
      ref.read(planHealthSyncProvider.notifier).syncAfterHealthRefresh();
    }
    ref.read(aiReconnectStateProvider.notifier).markNeedsReconnect();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
