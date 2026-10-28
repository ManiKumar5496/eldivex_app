import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/role/controllers/role_controller.dart';
import '../routes/app_pages.dart';
import '../widgets/helper_ui.dart';

/// Gates an admin route on an RBAC module key (`Billing`, `Settings`, ...).
///
/// Never fails open: when the access list is still loading (e.g. a browser
/// refresh straight onto a guarded page) the page is held behind a spinner
/// until the list arrives, then either shown or replaced by the dashboard.
class RoleMiddleware extends GetMiddleware {
  final String requiredAccess;

  RoleMiddleware(this.requiredAccess);

  @override
  int? get priority => 1;

  static void _deny(String module) {
    debugPrint("🚫 Access denied for: $module");
    Future.microtask(() => HelperUi.showToast(
          message: "You do not have access to this page.",
          backgroundColor: Colors.red,
        ));
  }

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<RoleController>()) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    final roles = Get.find<RoleController>();

    if (!roles.isAuthenticated()) {
      debugPrint("❌ Not authenticated - redirecting to LOGIN");
      return const RouteSettings(name: Routes.LOGIN);
    }

    // Not loaded yet: let the page through to onPageBuilt, which waits.
    if (!roles.accessLoaded.value || roles.isRolesLoading.value) {
      return null;
    }

    if (!roles.hasAccess(requiredAccess)) {
      _deny(requiredAccess);
      return const RouteSettings(name: Routes.MAIN);
    }
    return null;
  }

  @override
  Widget onPageBuilt(Widget page) {
    if (!Get.isRegistered<RoleController>()) return page;
    final roles = Get.find<RoleController>();
    if (roles.accessLoaded.value && !roles.isRolesLoading.value) return page;

    if (!roles.isRolesLoading.value) roles.fetchRoleAndAccess();
    var redirected = false;
    return Obx(() {
      if (!roles.accessLoaded.value || roles.isRolesLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (roles.hasAccess(requiredAccess)) return page;
      if (!redirected) {
        redirected = true;
        _deny(requiredAccess);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => Get.offAllNamed(Routes.MAIN));
      }
      return const Scaffold(body: SizedBox.shrink());
    });
  }
}
