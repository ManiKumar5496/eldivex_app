import 'package:get/get.dart';
import '../controllers/hp_auth_controller.dart';

class HpAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HpAuthController>(() => HpAuthController());
  }
}
