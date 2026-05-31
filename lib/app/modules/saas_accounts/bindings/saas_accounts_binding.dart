import 'package:get/get.dart';
import '../controllers/saas_accounts_controller.dart';

class SaasAccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaasAccountsController>(() => SaasAccountsController());
  }
}
