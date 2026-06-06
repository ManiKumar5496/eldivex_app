import 'package:get/get.dart';

import '../controllers/refund_controller.dart';

class RefundBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefundController>(
      () => RefundController(),
    );
  }
}
