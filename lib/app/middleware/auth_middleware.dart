import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/utils/session_utils.dart';
import '../routes/app_pages.dart';

bool _isAuthenticated() => isAdminAuthenticated();

/// Middleware that ensures unauthenticated users are redirected to login.
/// Used on every protected admin route. A logged-in user who has not accepted
/// the current Terms & Conditions is held on the Terms screen.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (!_isAuthenticated()) {
      debugPrint("AuthMiddleware: Not authenticated, redirecting to LOGIN");
      return const RouteSettings(name: Routes.LOGIN);
    }
    final path = (route ?? '').split('?').first;
    if (path != Routes.TERMS && !adminTermsAccepted()) {
      debugPrint("AuthMiddleware: Terms not accepted, redirecting to TERMS");
      return const RouteSettings(name: Routes.TERMS);
    }
    // Admin page: make ApiService send user_token even if a portal session
    // was active earlier in this browser.
    GetStorage().write('active_session', 'admin');
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
      return RouteSettings(
        name: adminTermsAccepted() ? Routes.MAIN : Routes.TERMS,
      );
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
      return RouteSettings(
        name: adminTermsAccepted() ? Routes.MAIN : Routes.TERMS,
      );
    }
    debugPrint("UnknownRouteMiddleware: Not authenticated, redirecting to LOGIN");
    return const RouteSettings(name: Routes.LOGIN);
  }
}
