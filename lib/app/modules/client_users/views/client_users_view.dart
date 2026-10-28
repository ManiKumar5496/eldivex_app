import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/client_users_controller.dart';
import 'manage_client_users.dart';

/// Stand-alone route (/client-users, e.g. from the dashboard "Clients" card).
/// Shows the same Manage Client Users page as the shell, with a back button
/// in its page header.
class ClientUsersView extends GetView<ClientUsersController> {
  const ClientUsersView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: ManageClientUsers(
        onBack: () => HelperUi.safeBack(Routes.MAIN),
      ),
    );
  }
}
