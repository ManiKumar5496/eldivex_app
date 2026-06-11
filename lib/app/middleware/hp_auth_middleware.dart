import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_pages.dart';

/// A caregiver is logged in once a non-empty `hp_token` is stored.
bool hpIsAuthenticated() {
  final box = GetStorage();
  final token = box.read("hp_token") ?? "";
  return token.toString().isNotEmpty;
}

/// Guards the caregiver portal pages (/hp, /hp/...). Unauthenticated caregivers
/// are sent to the caregiver login. Kept separate from [AuthMiddleware] so the
/// admin and caregiver sessions never cross.
class HpAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (!hpIsAuthenticated()) {
      debugPrint("HpAuthMiddleware: no caregiver session, redirecting to HP_LOGIN");
      return const RouteSettings(name: Routes.HP_LOGIN);
    }
    return null;
  }
}

/// On the caregiver login route, send already-logged-in caregivers to the home.
class HpLoginGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (hpIsAuthenticated()) {
      return const RouteSettings(name: Routes.HP_HOME);
    }
    return null;
  }
}
