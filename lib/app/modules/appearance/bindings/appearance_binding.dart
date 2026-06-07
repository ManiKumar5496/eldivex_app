import 'package:get/get.dart';

import '../../../core/theme/theme_controller.dart';

/// [ThemeController] is registered `permanent` in main.dart, so this binding
/// only guarantees it is available (a no-op if already present).
class AppearanceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
  }
}
