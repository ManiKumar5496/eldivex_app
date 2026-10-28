import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import 'hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpBookingDetailView extends StatelessWidget {
  const HpBookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final b = Map<String, dynamic>.from(Get.arguments ?? {});
    final status = '${b['booking_status'] ?? ''}';
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: HpUi.pagePadding(context, top: 20),
        children: [
          HpUi.section(
            title: 'Patient',
            icon: LucideIcons.user,
            children: [
              HpUi.kv('Name', '${b['patient_name'] ?? '—'}'),
              HpUi.kv('Age', '${b['patient_age'] ?? '—'}'),
              HpUi.kv('Gender', '${b['patient_gender'] ?? '—'}'),
            ],
          ),
          const SizedBox(height: 16),
          HpUi.section(
            title: 'Service',
            icon: LucideIcons.stethoscope,
            children: [
              HpUi.kv('Service', '${b['service_name'] ?? '—'}'),
              status.isEmpty || status == 'NA'
                  ? HpUi.kv('Status', '—')
                  : AppInfoRow(
                      label: 'Status',
                      horizontal: true,
                      labelWidth: 112,
                      valueWidget: Align(
                        alignment: Alignment.centerLeft,
                        child: AppStatusBadge.status(status),
                      ),
                    ),
              HpUi.kv('Rate', '${b['base_rate'] ?? '—'} / ${b['base_unit'] ?? ''}'),
              HpUi.kv('Shift', '${b['in_time'] ?? '—'} → ${b['out_time'] ?? '—'}'),
            ],
          ),
          const SizedBox(height: 16),
          HpUi.section(
            title: 'Service period',
            icon: LucideIcons.calendarRange,
            children: [
              HpUi.kv('Start', '${b['service_start_date'] ?? '—'}'),
              HpUi.kv('End', '${b['service_end_date'] ?? '—'}'),
              HpUi.kv('Reporting', '${b['reporting_date_planned'] ?? '—'}'),
            ],
          ),
          const SizedBox(height: 16),
          HpUi.section(
            title: 'Location',
            icon: LucideIcons.mapPin,
            children: [
              HpUi.kv('Address',
                  '${b['address_line1'] ?? ''} ${b['address_line2'] ?? ''}'.trim()),
              HpUi.kv('Locality', '${b['locality'] ?? '—'}'),
              HpUi.kv('Landmark', '${b['landmark'] ?? '—'}'),
              HpUi.kv('City', '${b['city'] ?? ''} ${b['pincode'] ?? ''}'.trim()),
            ],
          ),
          if ((b['spl_care_requirements'] ?? '').toString().isNotEmpty &&
              b['spl_care_requirements'] != 'NA') ...[
            const SizedBox(height: 16),
            AppCard(
              title: 'Special care',
              icon: LucideIcons.heartPulse,
              iconTone: AppTone.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${b['spl_care_requirements']}',
                      style: TextStyle(
                          fontSize: 14, height: 1.5, color: AppColor.textPrimary)),
                  if ((b['spl_instructions'] ?? '').toString().isNotEmpty &&
                      b['spl_instructions'] != 'NA') ...[
                    const SizedBox(height: 8),
                    Text('${b['spl_instructions']}',
                        style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: AppColor.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
