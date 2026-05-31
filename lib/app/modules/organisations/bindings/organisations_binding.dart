import 'package:get/get.dart';
import '../controllers/organisations_controller.dart';

class OrganisationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrganisationsController>(() => OrganisationsController());
  }
}
