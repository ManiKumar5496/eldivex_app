import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: keep the factory alive so the controller is re-created after
    // logout (Get.offAllNamed deletes the instance the dashboard had put,
    // and the binding's lazyPut is skipped while an instance still exists).
    Get.lazyPut<LoginController>(
      () => LoginController(),
      fenix: true,
    );
  }
}
