import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:toastification/toastification.dart';
import 'app/core/theme/app_themes.dart';
import 'app/core/theme/theme_controller.dart';
import 'app/initial_bindings/initial_bindings.dart';
import 'app/modules/role/controllers/role_controller.dart';
import 'app/middleware/auth_middleware.dart';
import 'app/modules/dashboard/views/side_menu_widget_view.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(ThemeController(), permanent: true);
  Get.put(RoleController(), permanent: true);
  runApp(const EldivexAdmin());
}

class EldivexAdmin extends StatelessWidget {
  const EldivexAdmin({super.key});

  String _getInitialRoute() {
    final token = box.read("user_token") ?? "";
    final roleId = box.read("role_id") ?? 0;
    if (token.toString().isNotEmpty && roleId > 0) {
      return Routes.MAIN;
    }
    return Routes.LOGIN;
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return ToastificationWrapper(
      child: Obx(
        () {
          // Track both so palette swaps and mode changes rebuild the app and
          // re-resolve the theme-aware AppColor getters.
          themeController.paletteIndex.value;
          final mode = themeController.themeMode.value;
          return GetMaterialApp(
            title: 'Eldivex',
            debugShowCheckedModeBanner: false,
            initialBinding: InitialBindings(),
            initialRoute: _getInitialRoute(),
            getPages: AppPages.routes,
            unknownRoute: GetPage(
              name: '/not-found',
              page: () => const SideMenuWidgetView(),
              middlewares: [UnknownRouteMiddleware()],
            ),
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: mode,
          );
        },
      ),
    );
  }
}

final box = GetStorage();
var appLog = Logger();
