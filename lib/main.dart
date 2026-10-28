import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:toastification/toastification.dart';
import 'app/core/theme/app_themes.dart';
import 'app/core/theme/theme_controller.dart';
import 'app/core/utils/jwt_utils.dart';
import 'app/core/utils/session_utils.dart';
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
    // Match whole segments only: `/hp-payouts` and `/client-users` are admin
    // pages and must not be mistaken for the portals on refresh.
    bool isPortal(String prefix) =>
        loc.path == prefix || loc.path.startsWith('$prefix/');
    if (isPortal('/hp')) {
      final orgId = loc.queryParameters['org_id'];
      final orgSlug = loc.queryParameters['org'];
      if (orgId != null && orgId.isNotEmpty) {
        // Raw string: numeric id (legacy orgs) or org code like SUN-482913.
        box.write('hp_org_id_param', orgId);
      }
      if (orgSlug != null && orgSlug.isNotEmpty) {
        box.write('hp_org_slug', orgSlug);
      }
      // Mark this device as a caregiver-portal device so reopening the bare
      // domain (no /#/hp fragment) still routes back to this portal.
      box.write('last_portal', 'hp');
      return isValidSessionToken(box.read("hp_token"))
          ? Routes.HP_HOME
          : Routes.HP_LOGIN;
    }

    // Client portal: shared link `…/#/client?org_id=<id>` (or `?org=<slug>`).
    if (isPortal('/client')) {
      final orgId = loc.queryParameters['org_id'];
      final orgSlug = loc.queryParameters['org'];
      if (orgId != null && orgId.isNotEmpty) {
        box.write('client_org_id_param', orgId);
      }
      if (orgSlug != null && orgSlug.isNotEmpty) {
        box.write('client_org_slug', orgSlug);
      }
      box.write('last_portal', 'client');
      return isValidSessionToken(box.read("client_token"))
          ? Routes.CLIENT_HOME
          : Routes.CLIENT_LOGIN;
    }

    // No portal path in the URL. Portal users routinely reopen the bare domain
    // (typed URL, home-screen shortcut, history entry without the query), so
    // restore whichever portal session is still alive before considering the
    // admin flow.
    final session = (box.read('active_session') ?? '').toString();
    if (session == 'hp' && isValidSessionToken(box.read('hp_token'))) {
      return Routes.HP_HOME;
    }
    if (session == 'client' && isValidSessionToken(box.read('client_token'))) {
      return Routes.CLIENT_HOME;
    }

    if (isAdminAuthenticated()) {
      // Admin requests pick their token from active_session.
      box.write('active_session', 'admin');
      return adminTermsAccepted() ? Routes.MAIN : Routes.TERMS;
    }

    // No live session at all. If this device has only ever been used for a
    // portal (opened a shared link before), send it to that portal's login —
    // the login screen restores the remembered organisation — instead of
    // stranding an end user on the admin login.
    final lastPortal = (box.read('last_portal') ?? '').toString();
    if (lastPortal == 'hp') return Routes.HP_LOGIN;
    if (lastPortal == 'client') return Routes.CLIENT_LOGIN;
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
