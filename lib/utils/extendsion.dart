import 'package:flutter/material.dart';

extension ColorOpacityFix on Color {
  Color withAlphaOpacity(double opacity) {
    return withValues(alpha: (opacity * 255).toDouble());
  }
}
