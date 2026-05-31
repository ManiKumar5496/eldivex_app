import 'package:get/get.dart';
import '../modules/role/controllers/role_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // RoleController is already registered as permanent in main.dart.
    // Only register if not already present (safety for hot reload).
    if (!Get.isRegistered<RoleController>()) {
      Get.put(RoleController(), permanent: true);
    }
  }
}
