import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/role/controllers/role_controller.dart';
import '../routes/app_pages.dart';

class RoleMiddleware extends GetMiddleware {
  final String requiredAccess;

  RoleMiddleware(this.requiredAccess);

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      // Try to find the RoleController
      final roles = Get.find<RoleController>();

      debugPrint("🛡️ RoleMiddleware - Checking access for: $requiredAccess");

      // First check authentication
      if (!roles.isAuthenticated()) {
        debugPrint("❌ Not authenticated - redirecting to LOGIN");
        return const RouteSettings(name: Routes.LOGIN);
      }

      // Check if access list is loaded
      if (roles.accessList.isEmpty && roles.isRolesLoading.value) {
        debugPrint("⏳ Access list still loading...");
        // You might want to show a loading screen here
        // For now, we'll allow and let the page handle it
        return null;
      }

      // Check if user has required access
      if (!roles.hasAccess(requiredAccess)) {
        debugPrint("🚫 Access denied for: $requiredAccess");

        // Option 1: Redirect to login
        return const RouteSettings(name: Routes.LOGIN);

        // Option 2: Redirect to dashboard with snackbar
        // Get.snackbar(
        //   'Access Denied',
        //   'You do not have permission to access this page',
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
        // return const RouteSettings(name: Routes.DASHBOARD);
      }

      debugPrint("✅ Access granted for: $requiredAccess");
      return null;

    } catch (e) {
      // RoleController not found - user is definitely not authenticated
      debugPrint("❌ RoleMiddleware Error: $e - redirecting to LOGIN");
      return const RouteSettings(name: Routes.LOGIN);
    }
  }
}