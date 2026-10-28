import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

import '../values/color_constants.dart';
import 'theme_state.dart';

/// Builds the light & dark [ThemeData] from the active palette. These are
/// getters (not consts) so they always reflect [ThemeState.palette].
///
/// Every Material widget picks its look up from here, so screens should rely
/// on the theme (plain `ElevatedButton`, `TextField`, `DataTable`, …) and only
/// override what is genuinely screen-specific.
class AppThemes {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static const String _font = 'inter_regular';

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primary = ThemeState.primary;
    final Color secondary = ThemeState.secondary;
    final Color accent = ThemeState.accent;

    final Color scaffoldBg =
        isDark ? HexColor.fromHex('#0B0F17') : HexColor.fromHex('#F2F4F7');
    final Color surface =
        isDark ? HexColor.fromHex('#161C27') : HexColor.fromHex('#FFFFFF');
    final Color surfaceMuted =
        isDark ? HexColor.fromHex('#1A212D') : HexColor.fromHex('#F7F8FA');
    final Color onSurface =
        isDark ? HexColor.fromHex('#F1F4F9') : HexColor.fromHex('#101828');
    final Color onSurfaceMuted =
        isDark ? HexColor.fromHex('#A7B1C2') : HexColor.fromHex('#4A5565');
    final Color onSurfaceSubtle =
        isDark ? HexColor.fromHex('#8A95A8') : HexColor.fromHex('#6B7280');
    final Color border =
        isDark ? HexColor.fromHex('#272F3C') : HexColor.fromHex('#E5E7EB');
    final Color borderStrong =
        isDark ? HexColor.fromHex('#3A4454') : HexColor.fromHex('#D0D5DD');
    final Color fieldFill =
        isDark ? HexColor.fromHex('#1F2632') : HexColor.fromHex('#FFFFFF');
    final Color error =
        isDark ? HexColor.fromHex('#F87171') : HexColor.fromHex('#EF4444');
    final Color tooltipBg =
        isDark ? HexColor.fromHex('#F1F4F9') : HexColor.fromHex('#111827');
    final Color tooltipFg =
        isDark ? HexColor.fromHex('#0B0F17') : HexColor.fromHex('#FFFFFF');

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: primary.withValues(alpha: isDark ? 0.18 : 0.08),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: const Color(0xFFFFFFFF),
      tertiary: accent,
      onTertiary: const Color(0xFFFFFFFF),
      error: error,
      onError: const Color(0xFFFFFFFF),
      errorContainer: error.withValues(alpha: isDark ? 0.16 : 0.10),
      onErrorContainer: error,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceMuted,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceMuted,
      surfaceContainerHighest: fieldFill,
      outline: borderStrong,
      outlineVariant: border,
      shadow: const Color(0xFF000000),
      // Kill the Material 3 tint overlay so elevated surfaces stay neutral.
      surfaceTint: Colors.transparent,
    );

    final textTheme = _textTheme(onSurface, onSurfaceMuted, onSurfaceSubtle);

    final radius10 = BorderRadius.circular(10);
    final buttonText = const TextStyle(
      fontFamily: _font,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );

    OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: radius10,
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _font,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: surface,
      cardColor: surface,
      primaryColor: primary,
      dividerColor: border,
      hoverColor: onSurface.withValues(alpha: 0.04),
      splashColor: primary.withValues(alpha: 0.06),
      highlightColor: Colors.transparent,
      focusColor: primary.withValues(alpha: 0.10),
      visualDensity: VisualDensity.standard,
      // Icons Flutter inserts on its own (AppBar back/close/drawer buttons)
      // use Lucide like the rest of the app.
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(LucideIcons.arrowLeft, size: 20),
        closeButtonIconBuilder: (_) => const Icon(LucideIcons.x, size: 20),
        drawerButtonIconBuilder: (_) => const Icon(LucideIcons.menu, size: 20),
        endDrawerButtonIconBuilder: (_) => const Icon(LucideIcons.menu, size: 20),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 16,
        toolbarHeight: 60,
        shape: Border(bottom: BorderSide(color: border)),
        iconTheme: IconThemeData(color: onSurface, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: _font,
          color: onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontFamily: _font,
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _font,
          color: onSurfaceMuted,
          fontSize: 14,
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.14),
        shape: RoundedRectangleBorder(
          borderRadius: radius10,
          side: BorderSide(color: border),
        ),
        textStyle: TextStyle(fontFamily: _font, fontSize: 14, color: onSurface),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: _font, fontSize: 14, color: onSurface),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: radius10,
            side: BorderSide(color: border),
          )),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(fontFamily: _font, fontSize: 14, color: onSurface),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: radius10,
            side: BorderSide(color: border),
          )),
        ),
      ),
      iconTheme: IconThemeData(color: onSurfaceMuted, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(
            fontFamily: _font, color: onSurfaceSubtle, fontSize: 14),
        labelStyle: TextStyle(
            fontFamily: _font, color: onSurfaceMuted, fontSize: 14),
        floatingLabelStyle: TextStyle(
            fontFamily: _font, color: primary, fontWeight: FontWeight.w600),
        helperStyle: TextStyle(
            fontFamily: _font, color: onSurfaceSubtle, fontSize: 12),
        errorStyle: TextStyle(fontFamily: _font, color: error, fontSize: 12),
        prefixIconColor: onSurfaceSubtle,
        suffixIconColor: onSurfaceSubtle,
        border: inputBorder(borderStrong),
        enabledBorder: inputBorder(borderStrong),
        disabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 1.5),
        errorBorder: inputBorder(error),
        focusedErrorBorder: inputBorder(error, 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: onSurface.withValues(alpha: 0.08),
          disabledForegroundColor: onSurface.withValues(alpha: 0.38),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: radius10),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: radius10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          backgroundColor: surface,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          side: BorderSide(color: borderStrong),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: radius10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: onSurfaceMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: isDark ? 0.18 : 0.08),
        disabledColor: surfaceMuted,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(
            fontFamily: _font, fontSize: 13, color: onSurface),
        secondaryLabelStyle: TextStyle(
            fontFamily: _font, fontSize: 13, color: primary,
            fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        checkmarkColor: primary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceMuted,
        indicatorColor: primary,
        dividerColor: border,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
            fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
            fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400),
        overlayColor: WidgetStatePropertyAll(primary.withValues(alpha: 0.04)),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(surfaceMuted),
        headingRowHeight: 44,
        headingTextStyle: TextStyle(
          fontFamily: _font,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: onSurfaceSubtle,
          letterSpacing: 0.2,
        ),
        dataTextStyle: TextStyle(
          fontFamily: _font,
          fontSize: 13.5,
          color: onSurface,
        ),
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 24,
        dataRowColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return primary.withValues(alpha: isDark ? 0.14 : 0.06);
          }
          if (s.contains(WidgetState.hovered)) return surfaceMuted;
          return null;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceMuted,
        textColor: onSurface,
        titleTextStyle: TextStyle(
            fontFamily: _font, fontSize: 14, color: onSurface,
            fontWeight: FontWeight.w600),
        subtitleTextStyle: TextStyle(
            fontFamily: _font, fontSize: 13, color: onSurfaceSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: onSurfaceMuted,
        collapsedIconColor: onSurfaceMuted,
        textColor: onSurface,
        collapsedTextColor: onSurface,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: tooltipBg,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(
            fontFamily: _font, fontSize: 12, color: tooltipFg,
            fontWeight: FontWeight.w600),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tooltipBg,
        contentTextStyle:
            TextStyle(fontFamily: _font, fontSize: 14, color: tooltipFg),
        shape: RoundedRectangleBorder(borderRadius: radius10),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(8),
        thumbColor: WidgetStatePropertyAll(borderStrong),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.12),
        circularTrackColor: Colors.transparent,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: borderStrong, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
        checkColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : borderStrong,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFFFFFFFF)
              : (isDark ? onSurfaceMuted : const Color(0xFFFFFFFF)),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : borderStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: primary,
        headerForegroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dividerColor: border,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: error,
        textColor: const Color(0xFFFFFFFF),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: primary.withValues(alpha: isDark ? 0.18 : 0.08),
          selectedForegroundColor: primary,
          foregroundColor: onSurfaceMuted,
          side: BorderSide(color: borderStrong),
          textStyle: const TextStyle(
              fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: radius10),
        ),
      ),
    );
  }

  /// Type scale. Inter ships 400/600/700/900 here — w500 renders as 400, so
  /// emphasis uses w600 and KPI numbers w700.
  static TextTheme _textTheme(Color strong, Color muted, Color subtle) {
    TextStyle s(double size, FontWeight w, Color c, {double ls = 0}) =>
        TextStyle(
          fontFamily: _font,
          fontSize: size,
          fontWeight: w,
          color: c,
          letterSpacing: ls,
        );
    return TextTheme(
      displayLarge: s(44, FontWeight.w700, strong, ls: -1.0),
      displayMedium: s(36, FontWeight.w700, strong, ls: -0.8),
      displaySmall: s(30, FontWeight.w700, strong, ls: -0.6),
      headlineLarge: s(28, FontWeight.w700, strong, ls: -0.5),
      headlineMedium: s(24, FontWeight.w600, strong, ls: -0.4),
      headlineSmall: s(20, FontWeight.w600, strong, ls: -0.3),
      titleLarge: s(18, FontWeight.w600, strong, ls: -0.2),
      titleMedium: s(15, FontWeight.w600, strong, ls: -0.1),
      titleSmall: s(14, FontWeight.w600, strong),
      // No global line-height on body text: existing fixed-height cells and
      // pills are sized for the font's natural metrics.
      bodyLarge: s(15, FontWeight.w400, strong),
      bodyMedium: s(14, FontWeight.w400, strong),
      bodySmall: s(12.5, FontWeight.w400, subtle),
      labelLarge: s(14, FontWeight.w600, strong),
      labelMedium: s(12.5, FontWeight.w600, muted),
      labelSmall: s(11.5, FontWeight.w600, subtle, ls: 0.3),
    );
  }
}
