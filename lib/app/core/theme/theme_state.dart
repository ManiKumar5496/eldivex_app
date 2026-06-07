import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Lightweight, dependency-free holder that [AppColor] reads from on every
/// color access. [ThemeController] is the single writer — it updates these
/// fields, then forces an app rebuild so the [AppColor] getters re-evaluate.
///
/// Kept separate from the controller to avoid a circular import between
/// `color_constants.dart` and the GetX controller, and to avoid a `Get.find`
/// lookup on every one of the ~1,300 color reads.
class ThemeState {
  ThemeState._();

  /// Whether the app is currently rendering in dark mode.
  static bool isDark = false;

  /// The active brand palette (defaults to Blue — index 0).
  static AppPalette palette = kPalettes[0];

  /// Brand colors are lifted (lighter + a touch less saturated) in dark mode
  /// so they read as vivid accents on the dark canvas instead of dull,
  /// low-contrast blocks — while staying readable under white button text.
  static Color get primary => isDark ? _liftForDark(palette.primary) : palette.primary;
  static Color get secondary =>
      isDark ? _liftForDark(palette.secondary) : palette.secondary;
  static Color get accent => isDark ? _liftForDark(palette.accent) : palette.accent;

  /// Picks the right value for the current brightness.
  static Color mode(Color light, Color dark) => isDark ? dark : light;

  static Color _liftForDark(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + 0.10).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation - 0.06).clamp(0.0, 1.0))
        .toColor();
  }
}
