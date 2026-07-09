import 'package:flutter/material.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/domain/entities/on_device_model.dart';

/// Shared UI mapping for [OnDeviceModelCapability] labels and theme colors.
abstract final class OnDeviceModelCapabilityUi {
  static String label(OnDeviceModelCapability capability) {
    return switch (capability) {
      OnDeviceModelCapability.functionCalling => 'Tools',
      OnDeviceModelCapability.thinkingMode => 'Thinking',
      OnDeviceModelCapability.vision => 'Vision',
      OnDeviceModelCapability.audio => 'Audio',
      OnDeviceModelCapability.multilingual => 'Multilingual',
    };
  }

  static Color color(
    OnDeviceModelCapability capability,
    KynosThemeExtension kynos,
  ) {
    return switch (capability) {
      OnDeviceModelCapability.functionCalling => kynos.stand,
      OnDeviceModelCapability.thinkingMode => kynos.move,
      OnDeviceModelCapability.vision => kynos.exercise,
      OnDeviceModelCapability.audio => kynos.purple,
      OnDeviceModelCapability.multilingual => kynos.secondaryLabel,
    };
  }

  /// Capabilities exposed as picker filter chips.
  static const filterable = [
    OnDeviceModelCapability.functionCalling,
    OnDeviceModelCapability.thinkingMode,
    OnDeviceModelCapability.vision,
  ];

  /// Highlights shown in Settings subtitle (priority order).
  static const settingsHighlights = [
    OnDeviceModelCapability.thinkingMode,
    OnDeviceModelCapability.vision,
    OnDeviceModelCapability.functionCalling,
  ];
}
