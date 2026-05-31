import 'package:get/get.dart';

import '../controllers/role_controller.dart';

class RoleBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RoleController>()) {
      Get.lazyPut<RoleController>(
        () => RoleController(),
      );
    }
  }
}
