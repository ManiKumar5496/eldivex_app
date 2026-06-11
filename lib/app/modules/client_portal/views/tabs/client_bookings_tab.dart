import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../hp_portal/views/hp_widgets.dart';
import '../../controllers/client_controller.dart';

class ClientBookingsTab extends StatelessWidget {
  const ClientBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ClientController>();
    const filters = ['all', 'active', 'completed'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Obx(() => Row(
                children: filters.map((f) {
                  final selected = c.bookingFilter.value == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f[0].toUpperCase() + f.substring(1)),
                      selected: selected,
                      onSelected: (_) => c.fetchBookings(f),
                    ),
                  );
                }).toList(),
              )),
        ),
        Expanded(
          child: Obx(() {
            if (c.loadingBookings.value) return const Center(child: CircularProgressIndicator());
            if (c.bookings.isEmpty) {
              return HpUi.empty('No ${c.bookingFilter.value} bookings.', icon: Icons.event_busy);
            }
            return RefreshIndicator(
              onRefresh: () => c.fetchBookings(c.bookingFilter.value),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
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
    return InkWell(
      onTap: () => Get.toNamed(Routes.CLIENT_BOOKING_DETAIL, arguments: b),
      borderRadius: BorderRadius.circular(14),
      child: HpUi.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${b['patient_name'] ?? 'Patient'}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15,
                          color: AppColor.cPrimaryHeadingColor)),
                ),
                HpUi.statusChip('${b['status_label'] ?? ''}', AppColor.cAppPrimaryColor),
              ],
            ),
            const SizedBox(height: 6),
            Text('${b['service_name'] ?? 'Service'}', style: TextStyle(color: AppColor.fontColorGrey)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.event, size: 14, color: AppColor.fontColorGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text('${b['service_start_date'] ?? '—'} → ${b['service_end_date'] ?? '—'}',
                    style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
