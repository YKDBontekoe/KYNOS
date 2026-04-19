/// Base class for all domain-level failures in KYNOS.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

final class AiInferenceFailure extends Failure {
  const AiInferenceFailure([super.message = 'AI inference failed']);
}

final class HealthDataFailure extends Failure {
  const HealthDataFailure([super.message = 'Health data unavailable']);
}

final class BiomechanicsModelFailure extends Failure {
  const BiomechanicsModelFailure([super.message = 'Biomechanics model error']);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Local storage error']);
}

final class PrivacyConstraintFailure extends Failure {
  const PrivacyConstraintFailure(
      [super.message = 'Operation blocked by Zero-Knowledge policy']);
}
