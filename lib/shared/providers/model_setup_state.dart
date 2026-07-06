enum ModelSetupPhase {
  checking,
  downloading,
  ready,
}

class ModelSetupState {
  const ModelSetupState({
    required this.phase,
    this.progressMessage,
  });

  final ModelSetupPhase phase;
  final String? progressMessage;

  bool get isReady => phase == ModelSetupPhase.ready;
}
