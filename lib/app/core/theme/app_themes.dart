import 'package:flutter/material.dart';

import '../values/color_constants.dart';
import 'theme_state.dart';

/// Builds the light & dark [ThemeData] from the active palette. These are
/// getters (not consts) so they always reflect [ThemeState.palette].
class AppThemes {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primary = ThemeState.primary;
    final Color secondary = ThemeState.secondary;

    final Color scaffoldBg =
        isDark ? HexColor.fromHex('#0B0F17') : HexColor.fromHex('#F8FAFC');
    final Color surface =
        isDark ? HexColor.fromHex('#161C27') : HexColor.fromHex('#FFFFFF');
    final Color onSurface =
        isDark ? HexColor.fromHex('#F1F4F9') : HexColor.fromHex('#101828');
    final Color onSurfaceMuted =
        isDark ? HexColor.fromHex('#A7B1C2') : HexColor.fromHex('#4A5565');
    final Color border =
        isDark ? HexColor.fromHex('#272F3C') : HexColor.fromHex('#E5E7EB');
    final Color fieldFill =
        isDark ? HexColor.fromHex('#1F2632') : HexColor.fromHex('#F6F8FB');

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: const Color(0xFFFFFFFF),
      secondary: secondary,
      onSecondary: const Color(0xFFFFFFFF),
      error: HexColor.fromHex('#EF4444'),
      onError: const Color(0xFFFFFFFF),
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'inter_regular',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primary,
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: surface,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'inter_regular',
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: surface,
      ),
      iconTheme: IconThemeData(color: isDark ? HexColor.fromHex('#C3CCDA') : null),
      textTheme: isDark
          ? Typography.material2021().white.apply(
              bodyColor: onSurface,
              displayColor: onSurface,
              fontFamily: 'inter_regular',
            )
          : null,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        hintStyle: TextStyle(color: onSurfaceMuted),
        labelStyle: TextStyle(color: onSurfaceMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary.withValues(alpha: 0.4) : null,
        ),
      ),
    );
  }
}
