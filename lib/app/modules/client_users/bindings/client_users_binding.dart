import 'package:get/get.dart';

import '../controllers/client_users_controller.dart';

class ClientUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientUsersController>(
      () => ClientUsersController(),
    );
  }
}
