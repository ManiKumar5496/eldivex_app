import 'package:get/get.dart';

import '../controllers/cg_payment_controller.dart';
import '../controllers/register_cg_controller.dart';

class CgPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterCgController>(() => RegisterCgController(), fenix: true);
    Get.lazyPut<CgPaymentController>(() => CgPaymentController(), fenix: true);
  }
}
