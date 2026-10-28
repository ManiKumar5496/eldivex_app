import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';
import 'package:toastification/toastification.dart';

import '../core/theme/theme_state.dart';
import '../core/values/color_constants.dart';
import 'shimmer_loader.dart';
import 'ui/app_tokens.dart';

class HelperUi {
  Widget loader({ShimmerType type = ShimmerType.table, int itemCount = 6}) {
    return ShimmerLoader(type: type, itemCount: itemCount);
  }

  static void showToast({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    final context = Get.context;
    if (context == null) return;

    final ToastificationType type;
    final Color primary;
    final IconData icon;
    switch (_toastKind(backgroundColor)) {
      case ToastificationType.success:
        type = ToastificationType.success;
        primary = AppColor.success;
        icon = LucideIcons.circleCheck;
        break;
      case ToastificationType.error:
        type = ToastificationType.error;
        primary = AppColor.danger;
        icon = LucideIcons.circleAlert;
        break;
      case ToastificationType.warning:
        type = ToastificationType.warning;
        primary = AppColor.warning;
        icon = LucideIcons.triangleAlert;
        break;
      default:
        type = ToastificationType.info;
        primary = AppColor.info;
        icon = LucideIcons.info;
    }
    // Theme surface with a faint wash of the tone, so the toast reads in both
    // light and dark mode; the icon, border and progress bar carry the tone.
    final bg = Color.alphaBlend(
      primary.withValues(alpha: ThemeState.isDark ? 0.12 : 0.06),
      AppColor.whiteColor,
    );

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        message,
        style: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 14,
          height: 1.35,
        ),
      ),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      showIcon: true,
      icon: Icon(icon, color: primary, size: 20),
      primaryColor: primary,
      backgroundColor: bg,
      foregroundColor: AppColor.textPrimary,
      borderSide: BorderSide(color: primary.withValues(alpha: 0.28)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: AppShadows.overlay,
      progressBarTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.14),
        linearMinHeight: 2,
      ),
      showProgressBar: true,
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.onHover,
        buttonBuilder: (context, onClose) => IconButton(
          tooltip: 'Dismiss',
          onPressed: onClose,
          visualDensity: VisualDensity.compact,
          icon: Icon(LucideIcons.x, size: 16, color: AppColor.textTertiary),
        ),
      ),
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
    );
  }

  /// Maps the colour a caller passes to a toast kind. Callers use plain
  /// Material colours (`Colors.red`, `Colors.green.shade600`, ...) as well as
  /// theme colours (`colorScheme.error` for failures, `colorScheme.primary`
  /// for success), so match the theme first and then fall back to the hue.
  static ToastificationType _toastKind(Color? c) {
    if (c == null) return ToastificationType.info;
    final scheme = Get.theme.colorScheme;
    if (c == scheme.error) return ToastificationType.error;
    if (c == scheme.primary) return ToastificationType.success;
    final hsv = HSVColor.fromColor(c);
    if (hsv.saturation < 0.25 || hsv.value < 0.2) return ToastificationType.info;
    final h = hsv.hue;
    if (h < 15 || h >= 330) return ToastificationType.error;
    if (h < 60) return ToastificationType.warning;
    if (h >= 75 && h < 180) return ToastificationType.success;
    return ToastificationType.info;
  }

  /// Navigates back safely on Flutter web. After a browser refresh the GetX
  /// history stack is empty and Get.back() is a no-op. This falls back to
  /// [fallbackRoute] in that case.
  static void safeBack(String fallbackRoute) {
    if (Get.previousRoute.isEmpty) {
      Get.offAllNamed(fallbackRoute);
    } else {
      Get.back();
    }
  }

  static showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
