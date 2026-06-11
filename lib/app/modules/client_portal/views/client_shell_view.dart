import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../controllers/client_controller.dart';
import 'tabs/client_dashboard_tab.dart';
import 'tabs/client_bookings_tab.dart';
import 'tabs/client_accounts_tab.dart';
import 'tabs/client_more_tab.dart';

/// Mobile-first bottom-nav scaffold hosting the client portal tabs.
class ClientShellView extends StatefulWidget {
  const ClientShellView({super.key});

  @override
  State<ClientShellView> createState() => _ClientShellViewState();
}

class _ClientShellViewState extends State<ClientShellView> {
  int _index = 0;

  static const _tabs = [
    ClientDashboardTab(),
    ClientBookingsTab(),
    ClientAccountsTab(),
    ClientMoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ClientController>()) Get.put(ClientController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(child: IndexedStack(index: _index, children: _tabs)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Accounts'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }
}
