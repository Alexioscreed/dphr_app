import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Returns a new Color with the specified alpha value, or
  /// with R, G, B, A values if provided
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromARGB(
      alpha != null ? (alpha * 255).round() : this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
