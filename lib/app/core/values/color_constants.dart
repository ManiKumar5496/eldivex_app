import 'package:flutter/material.dart';

import '../theme/theme_state.dart';

/// App-wide color tokens.
///
/// Every member is a theme-aware getter backed by [ThemeState]. This lets the
/// whole app switch between light/dark and swap brand palettes without editing
/// the ~1,300 call sites that read `AppColor.x`. After [ThemeState] changes,
/// a forced app rebuild causes these getters to re-evaluate.
class AppColor {
  // ── Brand (driven by the selected palette) ────────────────────────────────
  static Color get cAppPrimaryColor => ThemeState.primary;
  static Color get cPrimaryButtonColor => ThemeState.primary;
  static Color get cPrimaryButtonColor2 => ThemeState.secondary;
  static Color get bottomBarActiveColor => ThemeState.primary;
  static Color get accentColor => ThemeState.accent;

  // ── Surfaces ──────────────────────────────────────────────────────────────
  // Dark scale is a cohesive cool-neutral with real elevation hierarchy:
  // bg #0B0F17  <  surface #161C27  <  field #1F2632 — so cards lift off the
  // canvas without harsh contrast.
  /// Scaffold / page background.
  static Color get cAppBackgroundColor =>
      ThemeState.mode(HexColor.fromHex('#F2F4F7'), HexColor.fromHex('#0B0F17'));

  /// Card / panel / app-bar / sidebar surface. Historically "white"; now
  /// theme-aware so the thousands of `AppColor.whiteColor` surfaces flip.
  static Color get whiteColor =>
      ThemeState.mode(HexColor.fromHex('#FFFFFF'), HexColor.fromHex('#161C27'));

  /// Subtle input / filled-field / hover background (one step above surface).
  static Color get fieldColorGrey =>
      ThemeState.mode(HexColor.fromHex('#F6F8FB'), HexColor.fromHex('#1F2632'));

  // ── Text (softened off-white in dark; pure white glares) ───────────────────
  static Color get fontColorBlack =>
      ThemeState.mode(HexColor.fromHex('#1A1A1A'), HexColor.fromHex('#D7DEE9'));
  static Color get cPrimaryHeadingColor =>
      ThemeState.mode(HexColor.fromHex('#101828'), HexColor.fromHex('#F1F4F9'));
  static Color get cPrimarySubHeadingColorGrey =>
      ThemeState.mode(HexColor.fromHex('#4A5565'), HexColor.fromHex('#A7B1C2'));
  static Color get fontColorGrey =>
      ThemeState.mode(HexColor.fromHex('#6B7280'), HexColor.fromHex('#8A95A8'));
  static Color get lightGrey =>
      ThemeState.mode(HexColor.fromHex('#9CA3AF'), HexColor.fromHex('#5C6675'));
  static Color get unSelectedMenu =>
      ThemeState.mode(HexColor.fromHex('#364153'), HexColor.fromHex('#A7B1C2'));
  static Color get prefixIconColor =>
      ThemeState.mode(HexColor.fromHex('#1C1B1F'), HexColor.fromHex('#C3CCDA'));

  // ── Borders / dividers (low-contrast in dark) ──────────────────────────────
  static Color get divColor =>
      ThemeState.mode(HexColor.fromHex('#E5E7EB'), HexColor.fromHex('#272F3C'));
  static Color get textFieldBorderColor =>
      ThemeState.mode(HexColor.fromHex('#C7C7C7'), HexColor.fromHex('#313A48'));

  // ── Status / category accents (hue preserved in both modes) ─────────────────
  static Color get verifyContinue => HexColor.fromHex('#00C896');
  static Color get lightGreen => HexColor.fromHex('#00C896');
  static Color get careCColor => HexColor.fromHex('#00A077');
  static Color get babyCColor => HexColor.fromHex('#E6672D');
  static Color get consultCColor => HexColor.fromHex('#8B5CF6');
  static Color get xrayCColor => HexColor.fromHex('#8B5CF6');
  static Color get equipCColor => HexColor.fromHex('#E6672D');
  static Color get pisioCColor => HexColor.fromHex('#E6672D');
  static Color get dioCColor => HexColor.fromHex('#E6672D');
  static Color get calenderRed => HexColor.fromHex('#FF6467');

  // ── Semantic UI tokens (design system) ──────────────────────────────────────
  // Prefer these in new/updated UI. Each "soft" token is a low-alpha tint of
  // its base, for badge/icon-tile/selected backgrounds.

  /// Primary tint for selected nav items, icon tiles and soft buttons.
  static Color get primarySoft =>
      ThemeState.primary.withValues(alpha: ThemeState.isDark ? 0.18 : 0.08);

  /// Table header / hover / zebra surface — a half step off [whiteColor].
  static Color get surfaceMuted =>
      ThemeState.mode(HexColor.fromHex('#F7F8FA'), HexColor.fromHex('#1A212D'));

  // ── Sidebar (brand rail) ────────────────────────────────────────────────────
  // A deep shade of the palette primary with white-alpha content, so the rail
  // carries the brand and follows the selected palette.

  static Color get sidebarBg => ThemeState.sidebar;
  static Color get sidebarFg => pureWhite.withValues(alpha: 0.94);
  static Color get sidebarFgMuted => pureWhite.withValues(alpha: 0.66);
  static Color get sidebarFgSubtle => pureWhite.withValues(alpha: 0.42);
  static Color get sidebarHover => pureWhite.withValues(alpha: 0.06);
  static Color get sidebarActiveBg => pureWhite.withValues(alpha: 0.12);
  static Color get sidebarBorder => pureWhite.withValues(alpha: 0.08);

  /// Active-item marker — the palette accent (cyan for the default Blue).
  static Color get sidebarAccent => ThemeState.accent;

  /// Hairline inside cards (row dividers, header separators).
  static Color get borderSubtle =>
      ThemeState.mode(HexColor.fromHex('#EEF0F3'), HexColor.fromHex('#222A36'));

  /// Outline of interactive controls (inputs, secondary buttons).
  static Color get borderStrong =>
      ThemeState.mode(HexColor.fromHex('#D0D5DD'), HexColor.fromHex('#3A4454'));

  static Color get textPrimary => cPrimaryHeadingColor;
  static Color get textSecondary => cPrimarySubHeadingColorGrey;
  static Color get textTertiary => fontColorGrey;

  static Color get success =>
      ThemeState.mode(HexColor.fromHex('#16A34A'), HexColor.fromHex('#4ADE80'));
  static Color get warning =>
      ThemeState.mode(HexColor.fromHex('#D97706'), HexColor.fromHex('#FBBF24'));
  static Color get danger =>
      ThemeState.mode(HexColor.fromHex('#DC2626'), HexColor.fromHex('#F87171'));
  static Color get info =>
      ThemeState.mode(HexColor.fromHex('#2563EB'), HexColor.fromHex('#60A5FA'));
  static Color get violet =>
      ThemeState.mode(HexColor.fromHex('#7C3AED'), HexColor.fromHex('#A78BFA'));

  static Color get successSoft => success.withValues(alpha: _softAlpha);
  static Color get warningSoft => warning.withValues(alpha: _softAlpha);
  static Color get dangerSoft => danger.withValues(alpha: _softAlpha);
  static Color get infoSoft => info.withValues(alpha: _softAlpha);
  static Color get violetSoft => violet.withValues(alpha: _softAlpha);
  static Color get neutralSoft => fontColorGrey.withValues(alpha: _softAlpha);

  static double get _softAlpha => ThemeState.isDark ? 0.16 : 0.10;

  // ── Always-on tokens (never remapped to a surface) ──────────────────────────
  /// Text / icon color that sits on top of a colored (primary) button — stays
  /// white in both light and dark modes.
  static Color get buttonTextWhite => const Color(0xFFFFFFFF);

  static const Color blackColor = Color(0xff000000);

  /// True pure white, regardless of theme. Use when a surface must stay white.
  static const Color pureWhite = Color(0xffffffff);
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
