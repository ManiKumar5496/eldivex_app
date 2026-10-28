import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/ui/ui.dart';
import '../../../hp_portal/views/hp_widgets.dart';
import '../../controllers/client_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ClientBookingsTab extends StatelessWidget {
  const ClientBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ClientController>();
    const filters = ['all', 'active', 'completed'];

    return Column(
      children: [
        Padding(
          padding: HpUi.pagePadding(context, top: 20, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HpUi.tabHeader('Bookings', subtitle: 'Care services for your family'),
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
                icon: LucideIcons.calendarX,
                title: 'No ${c.bookingFilter.value} bookings',
                message: 'Your care bookings will show up here.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => c.fetchBookings(c.bookingFilter.value),
              child: ListView.separated(
                padding: HpUi.pagePadding(context, top: 4),
                itemCount: c.bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _tile(c.bookings[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _tile(Map<String, dynamic> b) {
    return HpUi.card(
      onTap: () => Get.toNamed(Routes.CLIENT_BOOKING_DETAIL, arguments: b),
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
                    AppStatusBadge.status('${b['status_label'] ?? ''}',
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
