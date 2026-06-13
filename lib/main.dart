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
    // Caregiver portal: a shared link like `…/#/hp?org_id=<id>` (or `?org=<slug>`)
    // lands here. The app uses Flutter web hash routing, so the real route+query
    // live in the URL fragment — parse that (falling back to the path for
    // path-strategy/local cases). We stash org_id / org slug so the login screen
    // can resolve the organisation, then route into the portal.
    final frag = Uri.base.fragment; // e.g. "/hp?org_id=3"
    final loc = frag.isNotEmpty ? Uri.parse(frag) : Uri.base;
    if (loc.path.startsWith('/hp')) {
      final orgId = loc.queryParameters['org_id'];
      final orgSlug = loc.queryParameters['org'];
      if (orgId != null && orgId.isNotEmpty) {
        // Raw string: numeric id (legacy orgs) or org code like SUN-482913.
        box.write('hp_org_id_param', orgId);
      }
      if (orgSlug != null && orgSlug.isNotEmpty) {
        box.write('hp_org_slug', orgSlug);
      }
      final hpToken = box.read("hp_token") ?? "";
      return hpToken.toString().isNotEmpty ? Routes.HP_HOME : Routes.HP_LOGIN;
    }

    // Client portal: shared link `…/#/client?org_id=<id>` (or `?org=<slug>`).
    if (loc.path.startsWith('/client')) {
      final orgId = loc.queryParameters['org_id'];
      final orgSlug = loc.queryParameters['org'];
      if (orgId != null && orgId.isNotEmpty) {
        box.write('client_org_id_param', orgId);
      }
      if (orgSlug != null && orgSlug.isNotEmpty) {
        box.write('client_org_slug', orgSlug);
      }
      final clientToken = box.read("client_token") ?? "";
      return clientToken.toString().isNotEmpty ? Routes.CLIENT_HOME : Routes.CLIENT_LOGIN;
    }

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
