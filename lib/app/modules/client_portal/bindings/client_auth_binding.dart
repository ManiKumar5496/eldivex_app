import 'package:get/get.dart';
import '../controllers/client_auth_controller.dart';

class ClientAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientAuthController>(() => ClientAuthController());
  }
}
