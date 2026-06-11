import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_pages.dart';

bool clientIsAuthenticated() {
  final box = GetStorage();
  final token = box.read("client_token") ?? "";
  return token.toString().isNotEmpty;
}

/// Guards the client portal (/client, /client/...). Kept separate from the
/// admin and caregiver guards so the three sessions never cross.
class ClientAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (!clientIsAuthenticated()) {
      debugPrint("ClientAuthMiddleware: no client session, redirecting to CLIENT_LOGIN");
      return const RouteSettings(name: Routes.CLIENT_LOGIN);
    }
    return null;
  }
}

class ClientLoginGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (clientIsAuthenticated()) {
      return const RouteSettings(name: Routes.CLIENT_HOME);
    }
    return null;
  }
}
