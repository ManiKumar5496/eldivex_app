import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../main.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/helper_ui.dart';
import '../../role/controllers/role_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final isPasswordHidden = true.obs;
  final isLoginLoading = false.obs;
  ApiService apiService = ApiService();

  //final GoogleSignIn _googleSignIn = GoogleSignIn(clientId:"");

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  Future<int> signInWithGoogle() async {
    isLoginLoading.value = true;
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();

        authProvider.setCustomParameters({
          'prompt': 'select_account'
        });

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithPopup(authProvider);
        User? user = userCredential.user;
        if (userCredential.user != null) {
          final roleController = Get.find<RoleController>();
          await roleController.fetchRoleAndAccess();

          login(user!.email ?? "", "");
          return 1; // Success
        } else {
          return 0; // User null
        }
      } else {
        return 0; // Not web
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return -1; // Error
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoginLoading.value = true;
      debugPrint("email in login $email");
      debugPrint("password in login $password");

      final response = await apiService.postRaw(ApiConstants.loginEndPoint, {
        "email": email,
        "password": password,
      });

      isLoginLoading.value = false;

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final userToken = data['token'];
        final userName = data['user_name'];
        final userRole = data['role_id'];
        final userId = data['userId'];
        final userImage = data['user_image'];

        box.write("user_token", userToken);
        box.write("user_name", userName);
        box.write("role_id", userRole);
        box.write("userId", userId);
        box.write("user_image", userImage);
        box.write("org_id", data['org_id'] ?? 1);

        if (userToken == null) {
          Get.offAllNamed(Routes.LOGIN);
          return;
        }

        final roleController = Get.find<RoleController>();
        debugPrint("⭐ Fetching role and access for role_id: $userRole");
        await roleController.fetchRoleAndAccess();
        Get.offAllNamed(Routes.MAIN);
        HelperUi.showToast(message: "Login Successful");
      } else if (response != null && response.statusCode == 429) {
        HelperUi.showToast(
          message: "Too many login attempts. Please wait 15 minutes and try again.",
        );
      } else if (response != null && response.statusCode == 401) {
        HelperUi.showToast(message: "Invalid email or password.");
      } else if (response != null && response.statusCode == 404) {
        HelperUi.showToast(message: "No account found with this email.");
      } else {
        HelperUi.showToast(message: "Login failed. Please try again.");
      }
    } catch (error) {
      isLoginLoading.value = false;
      // Dio throws exceptions for 4xx/5xx — extract the real status code
      if (error is DioException) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 429) {
          HelperUi.showToast(
            message: "Too many login attempts. Please wait 15 minutes and try again.",
          );
        } else if (statusCode == 401) {
          HelperUi.showToast(message: "Invalid email or password.");
        } else if (statusCode == 404) {
          HelperUi.showToast(message: "No account found with this email.");
        } else if (statusCode == 400) {
          final msg = error.response?.data?['message'] ?? "Invalid request.";
          HelperUi.showToast(message: msg);
        } else {
          HelperUi.showToast(message: "Login failed. Please try again.");
        }
      } else {
        HelperUi.showToast(message: "Login failed. Please try again.");
      }
    }
  }

  // In your settings or dashboard controller
  void logout() {
    final roleController = Get.find<RoleController>();
    roleController.clearAuth();

    Get.offAllNamed(Routes.LOGIN);

    HelperUi.showToast(message: "Logged out successfully");

  }

}
