import 'package:get/get.dart';

import '../controllers/credit_note_controller.dart';

class CreditNoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreditNoteController>(
      () => CreditNoteController(),
    );
  }
}
