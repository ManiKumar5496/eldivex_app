import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../auth/models/user_role_acess_model.dart';
import '../../../../main.dart';

class RoleController extends GetxController {
  final ApiService apiService = ApiService();
  final RxList<UserRoleAccessModel> allAccessRoles = <UserRoleAccessModel>[].obs;
  final RxList<String> accessList = <String>[].obs;
  final RxBool isRolesLoading = false.obs;
  int roleId = box.read("role_id") ?? 0;
  int orgId  = box.read("org_id")  ?? 1;
  String token = box.read("user_token") ?? "";

  @override
  void onInit() {
    token = box.read("user_token") ?? "";
    roleId = box.read("role_id") ?? 0;

    // Only fetch if user is authenticated
    if (isAuthenticated()) {
      fetchRoleAndAccess();
    }
    super.onInit();
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    // Re-read from storage to get latest value
    final currentToken = box.read("user_token") ?? "";
    final currentRoleId = box.read("role_id") ?? 0;

    debugPrint("🔐 Auth Check - Token: ${currentToken.isNotEmpty}, RoleId: $currentRoleId");

    return currentToken.isNotEmpty && currentRoleId > 0;
  }

  Future<bool> fetchRoleAndAccess() async {
    roleId = box.read("role_id")   ?? 0;
    orgId  = box.read("org_id")    ?? 1;
    token  = box.read("user_token") ?? "";

    debugPrint("⭐ Fetching role and access for role_id: $roleId");

    if (roleId == 0) {
      debugPrint("❌ No role_id found in storage");
      accessList.clear(); // Clear access list if no role
      return false;
    }

    isRolesLoading.value = true;

    try {
      final result = await apiService.getList<UserRoleAccessModel>(
        "${ApiConstants.getAccessRoles}?id=$roleId",
            (json) => UserRoleAccessModel.fromJson(json),
      );

      allAccessRoles.value = result ?? [];

      if (allAccessRoles.isNotEmpty) {
        final firstRole = allAccessRoles.first;

        accessList.value = firstRole.modules
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        debugPrint("✅ DYNAMIC ACCESS LOADED: $accessList");
        return true;
      }

      accessList.clear();
      debugPrint("⚠ No access_list found for this user");
      return false;
    } catch (e) {
      debugPrint("❌ Error fetching roles & access: $e");
      accessList.clear(); // Clear on error
      return false;
    } finally {
      isRolesLoading.value = false;
    }
  }

  /// Check whether user can access a specific menu or route
  bool hasAccess(String menuName) {
    // First check if authenticated
    if (!isAuthenticated()) {
      debugPrint("❌ User not authenticated - denying access to: $menuName");
      return false;
    }

    // If access list is empty but user is authenticated, they might need to wait for fetch
    if (accessList.isEmpty) {
      debugPrint("⚠ Access list empty for: $menuName");
      return false;
    }

    final hasPermission = accessList.contains(menuName);
    debugPrint("🔑 Access check for '$menuName': $hasPermission");
    return hasPermission;
  }

  /// Clear all authentication data
  void clearAuth() {
    box.remove("user_token");
    box.remove("role_id");
    box.remove("org_id");
    box.remove("user");
    box.remove("selected_page_index");
    accessList.clear();
    allAccessRoles.clear();
    token  = "";
    roleId = 0;
    orgId  = 1;
    debugPrint("🚪 User logged out - all data cleared");
  }
}