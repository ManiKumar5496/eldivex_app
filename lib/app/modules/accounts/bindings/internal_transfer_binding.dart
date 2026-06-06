import 'package:get/get.dart';

import '../controllers/internal_transfer_controller.dart';

class InternalTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InternalTransferController>(
      () => InternalTransferController(),
    );
  }
}
