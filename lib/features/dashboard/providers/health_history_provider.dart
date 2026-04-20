import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_history_provider.g.dart';

@riverpod
Future<List<HealthSummary>> healthHistory(HealthHistoryRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getSummaries(days: 7);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.summaries;
}
