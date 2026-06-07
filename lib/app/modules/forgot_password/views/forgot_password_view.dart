import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Icon / header ────────────────────────────────────────────
                const SizedBox(height: 48),
                Icon(
                  Icons.lock_reset_rounded,
                  size: 64,
                  color: AppColor.cPrimaryButtonColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold24.copyWith(
                    color: AppColor.cPrimaryHeadingColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your registered email address below.\n'
                  'We will send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular16Gre.copyWith(
                    color: AppColor.cPrimarySubHeadingColorGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Email label ──────────────────────────────────────────────
                Text(
                  'Email Address',
                  style: AppTextStyles.fieldsHeading16.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Email field ──────────────────────────────────────────────
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  onSubmitted: (_) => controller.sendResetLink(),
                  decoration: InputDecoration(
                    hintText: 'admin@example.com',
                    hintStyle: AppTextStyles.regular14Gre,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColor.prefixIconColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColor.textFieldBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColor.cPrimaryButtonColor,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColor.fieldColorGrey,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Submit button ────────────────────────────────────────────
                Obx(() => SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.sendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cPrimaryButtonColor,
                          foregroundColor: AppColor.whiteColor,
                          disabledBackgroundColor:
                              AppColor.cPrimaryButtonColor.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.buttonTextWhite,
                                ),
                              )
                            : Text(
                                'Send Reset Link',
                                style: AppTextStyles.regular16white.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )),
                const SizedBox(height: 16),

                // ── Back to login ────────────────────────────────────────────
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '← Back to Login',
                    style: AppTextStyles.regular16blue,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
