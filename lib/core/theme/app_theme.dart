import 'package:flutter/material.dart';

import '../constants/calculator_constants.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final seedScheme = ColorScheme.fromSeed(
      seedColor: CalculatorConstants.seedColor,
      brightness: brightness,
    );
    final scheme = brightness == Brightness.light
        ? seedScheme.copyWith(
            surface: const Color(0xFFFFF7F9),
            surfaceContainerHigh: const Color(0xFFF7E6EB),
          )
        : seedScheme.copyWith(
            surface: const Color(0xFF21171B),
            surfaceContainerHigh: const Color(0xFF3A2B32),
          );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: Typography.material2021().black.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
  }
}
