import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';

class HpDashboardTab extends StatelessWidget {
  const HpDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HpController>();
    return RefreshIndicator(
      onRefresh: c.refreshDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColor.cAppPrimaryColor.withValues(alpha: 0.15),
                child: Icon(Icons.person, color: AppColor.cAppPrimaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,', style: TextStyle(color: AppColor.fontColorGrey)),
                    Text(c.hpName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColor.cPrimaryHeadingColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _earningsCard(c),
          const SizedBox(height: 16),
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

      return HpUi.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's earnings", style: TextStyle(color: AppColor.fontColorGrey)),
            const SizedBox(height: 6),
            Text(HpUi.money(amount),
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColor.cAppPrimaryColor)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (status != null)
                  HpUi.statusChip(status.toString().toUpperCase(), HpUi.attendanceColor(status)),
                const Spacer(),
                if (t?['check_in'] != null)
                  Text('In: ${t!['check_in']}', style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
                if (t?['check_out'] != null)
                  Text('  Out: ${t!['check_out']}', style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
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
                icon: Icon(checkedIn ? Icons.logout : Icons.login),
                label: Text(hasCheckedOut
                    ? 'Checked out for today'
                    : checkedIn
                        ? 'Check Out'
                        : 'Check In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: checkedIn ? AppColor.calenderRed : AppColor.cPrimaryButtonColor,
                  foregroundColor: AppColor.buttonTextWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _currentBookingCard(HpController c) {
    return Obx(() {
      if (c.loadingBookings.value && c.bookings.isEmpty) {
        return HpUi.card(child: const Center(child: Padding(
          padding: EdgeInsets.all(16), child: CircularProgressIndicator())));
      }
      final b = c.currentBooking;
      if (b == null) {
        return HpUi.card(child: HpUi.empty('No active booking right now.', icon: Icons.event_busy));
      }
      return HpUi.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HpUi.sectionTitle('Current booking'),
            HpUi.kv('Patient', '${b['patient_name'] ?? '—'}'),
            HpUi.kv('Service', '${b['service_name'] ?? '—'}'),
            HpUi.kv('Period', '${b['service_start_date'] ?? '—'} → ${b['service_end_date'] ?? '—'}'),
            HpUi.kv('Location', '${b['locality'] ?? ''} ${b['city'] ?? ''}'.trim()),
          ],
        ),
      );
    });
  }
}
