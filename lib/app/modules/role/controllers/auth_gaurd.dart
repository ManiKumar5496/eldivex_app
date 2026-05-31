// lib/app/middleware/auth_guard.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

import '../../../routes/app_pages.dart';

class AuthGuard extends GetMiddleware {
  final box = GetStorage();

  @override
  RouteSettings? redirect(String? route) {
    final token = box.read("user_token");
    final role = box.read("role_id");

    if (token == null) {
      return  RouteSettings(name: Routes.LOGIN);
    }

    return null; // Allow access
  }
}
