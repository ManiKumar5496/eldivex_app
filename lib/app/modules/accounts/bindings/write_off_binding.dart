import 'package:get/get.dart';

import '../controllers/write_off_controller.dart';

class WriteOffBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<WriteOffController>(WriteOffController());
  }
}
