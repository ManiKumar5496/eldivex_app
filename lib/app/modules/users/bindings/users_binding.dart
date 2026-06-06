import 'package:get/get.dart';

import '../controllers/users_controller.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsersController>()) {
      Get.put<UsersController>(UsersController(), permanent: true);
    }
  }
}
