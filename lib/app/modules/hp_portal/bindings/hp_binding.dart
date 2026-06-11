import 'package:get/get.dart';
import '../controllers/hp_controller.dart';

class HpBinding extends Bindings {
  @override
  void dependencies() {
    // fenix:true so the controller is recreated if the portal is revisited
    // after the caregiver session is recycled.
    Get.lazyPut<HpController>(() => HpController(), fenix: true);
  }
}
