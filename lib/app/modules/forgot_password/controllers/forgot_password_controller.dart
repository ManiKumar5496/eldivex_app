import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../widgets/helper_ui.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  /// Sends a password reset link to the given email.
  /// Always shows a success message regardless of whether the email exists
  /// (prevents email enumeration).
  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      HelperUi.showToast(message: 'Please enter your email address.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      HelperUi.showToast(message: 'Please enter a valid email address.');
      return;
    }

    isLoading.value = true;
    try {
      // Use a plain Dio call — this is a public endpoint (no auth token needed)
      final dio = Dio();
      await dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true, // handle all status codes
        ),
      );

      // Always show the same message — never reveal if email exists
      HelperUi.showToast(
        message: 'If that email is registered, a reset link has been sent.',
      );
      Get.back(); // return to login
    } catch (e) {
      HelperUi.showToast(
        message: 'Something went wrong. Please try again later.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
