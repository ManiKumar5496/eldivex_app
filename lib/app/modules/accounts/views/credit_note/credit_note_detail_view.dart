import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/credit_note_controller.dart';

class CreditNoteDetailView extends GetView<CreditNoteController> {
  const CreditNoteDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Note Detail'),
        leading: BackButton(onPressed: () => Get.back()),
      ),
      body: const Center(
        child: Text('Credit Note Detail'),
      ),
    );
  }
}
