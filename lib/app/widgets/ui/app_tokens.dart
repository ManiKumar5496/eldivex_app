import 'package:flutter/material.dart';

import '../../core/theme/theme_state.dart';
import '../../core/values/color_constants.dart';

/// Corner radii used across the design system.
class AppRadius {
  AppRadius._();
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
}

/// Elevation is expressed with borders first; shadows stay barely visible.
class AppShadows {
  AppShadows._();

  /// Resting card shadow (light mode only — dark relies on surface steps).
  static List<BoxShadow> get card => ThemeState.isDark
      ? const []
      : [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];

  /// Floating surfaces: menus, popovers, the mobile drawer.
  static List<BoxShadow> get overlay => [
        BoxShadow(
          color: const Color(0xFF101828)
              .withValues(alpha: ThemeState.isDark ? 0.5 : 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Semantic colour role for badges, icon tiles, stat cards and dialogs.
enum AppTone { primary, success, warning, danger, info, violet, neutral }

extension AppToneColors on AppTone {
  Color get color {
    switch (this) {
      case AppTone.primary:
        return AppColor.cAppPrimaryColor;
      case AppTone.success:
        return AppColor.success;
      case AppTone.warning:
        return AppColor.warning;
      case AppTone.danger:
        return AppColor.danger;
      case AppTone.info:
        return AppColor.info;
      case AppTone.violet:
        return AppColor.violet;
      case AppTone.neutral:
        return AppColor.fontColorGrey;
    }
  }

  Color get soft {
    switch (this) {
      case AppTone.primary:
        return AppColor.primarySoft;
      case AppTone.success:
        return AppColor.successSoft;
      case AppTone.warning:
        return AppColor.warningSoft;
      case AppTone.danger:
        return AppColor.dangerSoft;
      case AppTone.info:
        return AppColor.infoSoft;
      case AppTone.violet:
        return AppColor.violetSoft;
      case AppTone.neutral:
        return AppColor.neutralSoft;
    }
  }
}

/// 'PENDING_APPROVAL' / 'pending approval' → 'Pending Approval'.
String humanizeLabel(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return '—';
  return s
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .toLowerCase()
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// Maps any status string used in the app (accounts, bookings, attendance,
/// support, HP lifecycle) to a tone, so the same word is always the same
/// colour on every screen.
AppTone toneForStatus(String status) {
  final s = status.trim().toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
  if (s.isEmpty) return AppTone.neutral;

  const exact = <String, AppTone>{
    'fully_applied': AppTone.info,
    'processing': AppTone.info,
    'submitted': AppTone.info,
    'booking_submitted': AppTone.info,
    'hp_assigned': AppTone.primary,
    'assigned': AppTone.primary,
    'reversed': AppTone.violet,
    'reversal': AppTone.violet,
    'transferred': AppTone.violet,
    'closed': AppTone.neutral,
    'inactive': AppTone.neutral,
    'draft': AppTone.neutral,
    'unpaid': AppTone.danger,
    'unverified': AppTone.warning,
    'not_verified': AppTone.warning,
    'incomplete': AppTone.warning,
  };
  final hit = exact[s];
  if (hit != null) return hit;

  bool has(List<String> words) => words.any(s.contains);

  if (has(['cancel', 'reject', 'fail', 'suspend', 'overdue', 'expired',
      'absent', 'declin', 'blocked', 'terminated', 'error'])) {
    return AppTone.danger;
  }
  if (has(['pending', 'hold', 'partial', 'due', 'leave', 'half', 'review',
      'waiting', 'awaiting', 'requested'])) {
    return AppTone.warning;
  }
  if (has(['approved', 'active', 'complete', 'paid', 'settled', 'applied',
      'present', 'resolved', 'started', 'success', 'verified', 'confirmed',
      'accepted', 'released', 'enabled', 'shortlisted'])) {
    return AppTone.success;
  }
  if (has(['process', 'submit', 'open', 'new', 'progress', 'scheduled',
      'issued', 'sent'])) {
    return AppTone.info;
  }
  if (has(['revers', 'transfer'])) return AppTone.violet;
  return AppTone.neutral;
}

/// Button styles the theme can't express as a default.
class AppButtonStyles {
  AppButtonStyles._();

  /// Filled destructive action (Delete, Reject, Write off).
  static ButtonStyle get danger => ElevatedButton.styleFrom(
        backgroundColor: AppColor.danger,
        foregroundColor: AppColor.pureWhite,
      );

  /// Outlined destructive action, for a secondary "Reject" next to "Approve".
  static ButtonStyle get dangerOutlined => OutlinedButton.styleFrom(
        foregroundColor: AppColor.danger,
        side: BorderSide(color: AppColor.danger.withValues(alpha: 0.45)),
      );

  /// Tinted primary — for a secondary call to action that should still read
  /// as brand (e.g. "Export", "Add row").
  static ButtonStyle get soft => TextButton.styleFrom(
        backgroundColor: AppColor.primarySoft,
        foregroundColor: AppColor.cAppPrimaryColor,
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      );

  /// 32px-high variant for table rows and dense toolbars. Merge with another
  /// style via `AppButtonStyles.compact.merge(...)` or use on its own.
  static ButtonStyle get compact => ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(32, 32)),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
        // A button's textStyle replaces the theme's, so restate the family.
        textStyle: const WidgetStatePropertyAll(TextStyle(
            fontFamily: 'inter_regular',
            fontSize: 13,
            fontWeight: FontWeight.w600)),
        visualDensity: VisualDensity.compact,
      );
}
