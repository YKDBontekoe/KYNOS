import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/infrastructure/ai/on_device_model_repository.dart';

/// Provides the [AiModelRepository] singleton.
final aiModelRepositoryProvider = Provider<AiModelRepository>((ref) {
  return OnDeviceModelRepository();
});
