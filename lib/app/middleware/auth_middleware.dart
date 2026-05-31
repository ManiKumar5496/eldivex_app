import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_pages.dart';

bool _isAuthenticated() {
  final box = GetStorage();
  final token = box.read("user_token") ?? "";
  final roleId = box.read("role_id") ?? 0;
  return token.toString().isNotEmpty && roleId > 0;
}

/// Middleware that ensures unauthenticated users are redirected to login.
/// Used on protected routes like /main.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (!_isAuthenticated()) {
      debugPrint("AuthMiddleware: Not authenticated, redirecting to LOGIN");
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

/// Middleware for the login route.
/// Redirects already-authenticated users to /main so they don't see login again.
class LoginGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (_isAuthenticated()) {
      debugPrint("LoginGuardMiddleware: Already authenticated, redirecting to MAIN");
      return const RouteSettings(name: Routes.MAIN);
    }
    return null;
  }
}

/// Middleware for unknownRoute - always redirects to a proper route.
/// Authenticated → /main, Unauthenticated → /login.
class UnknownRouteMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (_isAuthenticated()) {
      debugPrint("UnknownRouteMiddleware: Authenticated, redirecting to MAIN");
      return const RouteSettings(name: Routes.MAIN);
    }
    debugPrint("UnknownRouteMiddleware: Not authenticated, redirecting to LOGIN");
    return const RouteSettings(name: Routes.LOGIN);
  }
}
