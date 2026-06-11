import 'package:get/get.dart';
import '../controllers/hostels_controller.dart';

class HostelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostelsController>(() => HostelsController(), fenix: true);
  }
}
