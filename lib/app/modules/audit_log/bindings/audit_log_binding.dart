import 'package:get/get.dart';
import '../controllers/audit_log_controller.dart';

class AuditLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuditLogController>(() => AuditLogController());
  }
}
