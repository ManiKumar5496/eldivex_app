import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/ui/ui.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpDashboardTab extends StatelessWidget {
  const HpDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HpController>();
    return RefreshIndicator(
      onRefresh: c.refreshDashboard,
      child: ListView(
        padding: HpUi.pagePadding(context, top: 20),
        children: [
          HpUi.greeting('Welcome back,', c.hpName),
          const SizedBox(height: 24),
          _earningsCard(c),
          const SizedBox(height: 24),
          _currentBookingCard(c),
        ],
      ),
    );
  }

  Widget _earningsCard(HpController c) {
    return Obx(() {
      final t = c.todayEarnings.value;
      final amount = t?['amount'] ?? 0;
      final status = t?['status'];
      final checkedIn = c.checkedInToday;
      final hasCheckedOut = t?['check_out'] != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HpUi.sectionTitle(
            'Today',
            trailing: status != null
                ? HpUi.attendanceBadge(status.toString())
                : null,
          ),
          AppResponsiveGrid(
            minItemWidth: 140,
            maxColumns: 2,
            spacing: 12,
            children: [
              AppStatCard(
                label: "Today's earnings",
                value: HpUi.money(amount),
                icon: LucideIcons.wallet,
              ),
              AppStatCard(
                label: 'Check-in',
                value: '${t?['check_in'] ?? '—'}',
                icon: LucideIcons.clock,
                tone: AppTone.info,
                caption: t?['check_out'] != null
                    ? 'Out: ${t!['check_out']}'
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: c.busy.value || hasCheckedOut
                  ? null
                  : () {
                      if (checkedIn) {
                        c.checkOut();
                      } else {
                        final b = c.currentBooking;
                        if (b == null) {
                          Get.snackbar('No active booking', 'You have no active booking to check in for.');
                          return;
                        }
                        c.checkIn(b['booking_id']);
                      }
                    },
              icon: Icon(
                  hasCheckedOut
                      ? LucideIcons.circleCheckBig
                      : checkedIn
                          ? LucideIcons.logOut
                          : LucideIcons.logIn,
                  size: 18),
              label: Text(hasCheckedOut
                  ? 'Checked out for today'
                  : checkedIn
                      ? 'Check Out'
                      : 'Check In'),
              style: checkedIn ? AppButtonStyles.danger : null,
            ),
          ),
        ],
      );
    });
  }

  Widget _currentBookingCard(HpController c) {
    return Obx(() {
      if (c.loadingBookings.value && c.bookings.isEmpty) {
        return _bookingShell(HpUi.loader());
      }
      final b = c.currentBooking;
      if (b == null) {
        return _bookingShell(const AppEmptyState(
          compact: true,
          icon: LucideIcons.calendarX,
          title: 'No active booking right now',
          message: 'Your next assignment will show up here.',
        ));
      }
      return HpUi.section(
        title: 'Current booking',
        icon: LucideIcons.stethoscope,
        children: [
          HpUi.kv('Patient', '${b['patient_name'] ?? '—'}'),
          HpUi.kv('Service', '${b['service_name'] ?? '—'}'),
          HpUi.kv('Period', '${b['service_start_date'] ?? '—'} → ${b['service_end_date'] ?? '—'}'),
          HpUi.kv('Location', '${b['locality'] ?? ''} ${b['city'] ?? ''}'.trim()),
        ],
      );
    });
  }

  Widget _bookingShell(Widget child) {
    return AppCard(
      title: 'Current booking',
      icon: LucideIcons.stethoscope,
      padding: EdgeInsets.zero,
      child: child,
    );
  }
}
