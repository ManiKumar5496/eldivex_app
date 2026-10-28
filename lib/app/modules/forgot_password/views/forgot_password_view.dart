import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../../login/views/login_view.dart';
import '../controllers/forgot_password_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: AuthSplitLayout(
        showMark: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Icon / header ────────────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: AppIconTile(icon: LucideIcons.rotateCcwKey, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Forgot password?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your registered email address below. '
              'We will send you a link to reset your password.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColor.textTertiary,
              ),
            ),
            const SizedBox(height: 28),

            // ── Email label + field ──────────────────────────────────────
            const AuthFieldLabel('Email address'),
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              onSubmitted: (_) => controller.sendResetLink(),
              decoration: InputDecoration(
                hintText: 'admin@example.com',
                prefixIcon: Icon(
                  LucideIcons.mail,
                  size: 18,
                  color: AppColor.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit button ────────────────────────────────────────────
            Obx(() => SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.sendResetLink,
                    style: authPrimaryButtonStyle(),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.buttonTextWhite,
                            ),
                          )
                        : const Text('Send reset link'),
                  ),
                )),
            const SizedBox(height: 12),

            // ── Back to login ────────────────────────────────────────────
            Center(
              child: TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(LucideIcons.arrowLeft, size: 18),
                label: const Text('Back to sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
