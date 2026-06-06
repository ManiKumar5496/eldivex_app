import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/credit_note_controller.dart';

class ApplyCreditNoteView extends GetView<CreditNoteController> {
  const ApplyCreditNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Credit Note'),
        leading: BackButton(onPressed: () => Get.back()),
      ),
      body: const Center(
        child: Text('Apply Credit Note'),
      ),
    );
  }
}
