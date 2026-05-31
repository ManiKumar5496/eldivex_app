import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/client_users_controller.dart';

class ClientUsersView extends GetView<ClientUsersController> {
  const ClientUsersView({super.key});
  @override
  Widget build(BuildContext context) {
    final clientUsersController = Get.put(ClientUsersController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClientUsersView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ClientUsersView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
