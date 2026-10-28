import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/ui/ui.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpBookingsTab extends StatelessWidget {
  const HpBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HpController>();
    const filters = ['active', 'upcoming', 'past'];

    return Column(
      children: [
        Padding(
          padding: HpUi.pagePadding(context, top: 20, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HpUi.tabHeader('Bookings', subtitle: 'Your care assignments'),
              Obx(() => HpUi.segmented(
                    options: filters,
                    selected: c.bookingFilter.value,
                    onSelect: (f) => c.fetchBookings(f),
                  )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (c.loadingBookings.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.bookings.isEmpty) {
              return AppEmptyState(
                icon: LucideIcons.briefcase,
                title: 'No ${c.bookingFilter.value} bookings',
                message: 'Bookings assigned to you will show up here.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => c.fetchBookings(c.bookingFilter.value),
              child: ListView.separated(
                padding: HpUi.pagePadding(context, top: 4),
                itemCount: c.bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _bookingTile(c.bookings[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _bookingTile(Map<String, dynamic> b) {
    return HpUi.card(
      onTap: () => Get.toNamed(Routes.HP_BOOKING_DETAIL, arguments: b),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: '${b['patient_name'] ?? 'Patient'}', size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text('${b['patient_name'] ?? 'Patient'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColor.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    AppStatusBadge.status('${b['booking_status'] ?? ''}',
                        dense: true),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${b['service_name'] ?? 'Service'}',
                    style: TextStyle(
                        fontSize: 13.5, color: AppColor.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.calendar,
                        size: 14, color: AppColor.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${b['service_start_date'] ?? '—'} → ${b['service_end_date'] ?? '—'}',
                          style: TextStyle(
                              color: AppColor.textTertiary, fontSize: 12.5)),
                    ),
                    Icon(LucideIcons.chevronRight,
                        size: 18, color: AppColor.textTertiary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
