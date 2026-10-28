import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/session_utils.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../auth/models/user_role_acess_model.dart';
import '../../../../main.dart';

class RoleController extends GetxController {
  final ApiService apiService = ApiService();
  final RxList<UserRoleAccessModel> allAccessRoles = <UserRoleAccessModel>[].obs;
  final RxList<String> accessList = <String>[].obs;
  final RxBool isRolesLoading = false.obs;
  /// True once a fetch for the current session has finished (success or not),
  /// so route guards can tell "not loaded yet" from "no access".
  final RxBool accessLoaded = false.obs;
  int roleId = adminRoleId();
  int orgId  = adminOrgId();
  String token = (box.read("user_token") ?? "").toString();
  Future<bool>? _inflight;

  @override
  void onInit() {
    token = (box.read("user_token") ?? "").toString();
    roleId = adminRoleId();

    // Only fetch if user is authenticated
    if (isAuthenticated()) {
      fetchRoleAndAccess();
    }
    super.onInit();
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    // Re-read from storage to get latest value
    return isAdminAuthenticated();
  }

  /// Concurrent callers (login, route guards) share one in-flight request.
  Future<bool> fetchRoleAndAccess() {
    return _inflight ??= _fetchRoleAndAccess().whenComplete(() => _inflight = null);
  }

  Future<bool> _fetchRoleAndAccess() async {
    roleId = adminRoleId();
    orgId  = adminOrgId();
    token  = (box.read("user_token") ?? "").toString();

    debugPrint("⭐ Fetching role and access for role_id: $roleId");

    if (roleId == 0) {
      debugPrint("❌ No role_id found in storage");
      accessList.clear(); // Clear access list if no role
      accessLoaded.value = true;
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
      accessLoaded.value = true;
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
    accessLoaded.value = false;
    token  = "";
    roleId = 0;
    orgId  = 0;
    debugPrint("🚪 User logged out - all data cleared");
  }
}