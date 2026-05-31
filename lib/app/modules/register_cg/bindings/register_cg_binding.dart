import 'package:get/get.dart';

import '../controllers/register_cg_controller.dart';

class RegisterCgBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterCgController>(
      () => RegisterCgController(),
    );
  }
}
