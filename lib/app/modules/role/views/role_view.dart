import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/role_controller.dart';

class RoleView extends GetView<RoleController> {
  const RoleView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoleView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'RoleView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
