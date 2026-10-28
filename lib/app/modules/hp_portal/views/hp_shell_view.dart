import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../controllers/hp_controller.dart';
import 'hp_widgets.dart';
import 'tabs/hp_dashboard_tab.dart';
import 'tabs/hp_bookings_tab.dart';
import 'tabs/hp_attendance_tab.dart';
import 'tabs/hp_earnings_tab.dart';
import 'tabs/hp_more_tab.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Mobile-first bottom-nav scaffold hosting the caregiver portal tabs.
class HpShellView extends StatefulWidget {
  const HpShellView({super.key});

  @override
  State<HpShellView> createState() => _HpShellViewState();
}

class _HpShellViewState extends State<HpShellView> {
  int _index = 0;

  static const _tabs = [
    HpDashboardTab(),
    HpBookingsTab(),
    HpAttendanceTab(),
    HpEarningsTab(),
    HpMoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure the controller exists even on a hard web refresh of /hp.
    if (!Get.isRegistered<HpController>()) Get.put(HpController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(child: IndexedStack(index: _index, children: _tabs)),
      bottomNavigationBar: HpUi.bottomNav(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.house), selectedIcon: Icon(LucideIcons.house), label: 'Home'),
          NavigationDestination(icon: Icon(LucideIcons.briefcase), selectedIcon: Icon(LucideIcons.briefcase), label: 'Bookings'),
          NavigationDestination(icon: Icon(LucideIcons.clipboardCheck), selectedIcon: Icon(LucideIcons.clipboardCheck), label: 'Attendance'),
          NavigationDestination(icon: Icon(LucideIcons.banknote), selectedIcon: Icon(LucideIcons.banknote), label: 'Earnings'),
          NavigationDestination(icon: Icon(LucideIcons.menu), label: 'More'),
        ],
      ),
    );
  }
}
