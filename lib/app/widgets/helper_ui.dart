import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import 'shimmer_loader.dart';

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
    final Color bg;
    if (backgroundColor == Colors.green) {
      type = ToastificationType.success;
      primary = const Color(0xFF1B6B3A);
      bg = const Color(0xFFE6F4EC);
    } else if (backgroundColor == Colors.red) {
      type = ToastificationType.error;
      primary = const Color(0xFFC0392B);
      bg = const Color(0xFFFDECEA);
    } else if (backgroundColor == Colors.orange) {
      type = ToastificationType.warning;
      primary = const Color(0xFFD4AC0D);
      bg = const Color(0xFFFEF9E7);
    } else {
      type = ToastificationType.info;
      primary = const Color(0xFF1A5276);
      bg = const Color(0xFFEAF4FB);
    }

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        message,
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 14,
        ),
      ),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      showIcon: true,
      primaryColor: primary,
      backgroundColor: bg,
      foregroundColor: primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      showProgressBar: true,
      closeButton: ToastCloseButton(showType: CloseButtonShowType.onHover),
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
    );
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
        insetPadding: EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
