import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../hp_portal/views/hp_widgets.dart';
import '../../controllers/client_controller.dart';

class ClientDashboardTab extends StatelessWidget {
  const ClientDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ClientController>();
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
                    Text('Welcome,', style: TextStyle(color: AppColor.fontColorGrey)),
                    Text(c.clientName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppColor.cPrimaryHeadingColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final o = c.outstanding.value;
            return HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outstanding balance', style: TextStyle(color: AppColor.fontColorGrey)),
                  const SizedBox(height: 6),
                  Text(HpUi.money(o?['outstanding'] ?? 0),
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w800,
                          color: ((o?['outstanding'] ?? 0) as num) > 0
                              ? AppColor.calenderRed
                              : AppColor.lightGreen)),
                  const SizedBox(height: 8),
                  Row(children: [
                    HpUi.statusChip('Billed ${HpUi.money(o?['total_invoiced'] ?? 0)}', AppColor.cAppPrimaryColor),
                    const SizedBox(width: 8),
                    HpUi.statusChip('Paid ${HpUi.money(o?['total_paid'] ?? 0)}', AppColor.lightGreen),
                  ]),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final active = c.bookings.where((b) => [2, 4, 5].contains(b['status'])).toList();
            return HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HpUi.sectionTitle('Active bookings'),
                  if (active.isEmpty)
                    Text('No active bookings.', style: TextStyle(color: AppColor.fontColorGrey))
                  else
                    ...active.map((b) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.medical_services_outlined, color: AppColor.cAppPrimaryColor),
                          title: Text('${b['patient_name'] ?? 'Patient'} • ${b['service_name'] ?? ''}'),
                          subtitle: Text('${b['status_label'] ?? ''}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Get.toNamed(Routes.CLIENT_BOOKING_DETAIL, arguments: b),
                        )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
