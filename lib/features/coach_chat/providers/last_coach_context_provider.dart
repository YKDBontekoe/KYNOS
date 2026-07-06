import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_coach_context_provider.g.dart';

/// Last runner context injected into a coach inference turn (for UI badge).
@Riverpod(keepAlive: true)
class LastCoachContext extends _$LastCoachContext {
  @override
  CoachContext? build() => null;

  void set(CoachContext? context) => state = context;
}
