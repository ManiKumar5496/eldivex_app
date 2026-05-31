import 'package:get/get.dart';

import '../controllers/hp_payouts_controller.dart';

class HpPayoutsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HpPayoutsController>(() => HpPayoutsController());
  }
}
