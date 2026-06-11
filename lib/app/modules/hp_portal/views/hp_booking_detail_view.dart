import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import 'hp_widgets.dart';

class HpBookingDetailView extends StatelessWidget {
  const HpBookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final b = Map<String, dynamic>.from(Get.arguments ?? {});
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HpUi.card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HpUi.sectionTitle('Patient'),
                HpUi.kv('Name', '${b['patient_name'] ?? '—'}'),
                HpUi.kv('Age', '${b['patient_age'] ?? '—'}'),
                HpUi.kv('Gender', '${b['patient_gender'] ?? '—'}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          HpUi.card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HpUi.sectionTitle('Service'),
                HpUi.kv('Service', '${b['service_name'] ?? '—'}'),
                HpUi.kv('Status', '${b['booking_status'] ?? '—'}'),
                HpUi.kv('Rate', '${b['base_rate'] ?? '—'} / ${b['base_unit'] ?? ''}'),
                HpUi.kv('Shift', '${b['in_time'] ?? '—'} → ${b['out_time'] ?? '—'}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          HpUi.card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HpUi.sectionTitle('Service period'),
                HpUi.kv('Start', '${b['service_start_date'] ?? '—'}'),
                HpUi.kv('End', '${b['service_end_date'] ?? '—'}'),
                HpUi.kv('Reporting', '${b['reporting_date_planned'] ?? '—'}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          HpUi.card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HpUi.sectionTitle('Location'),
                HpUi.kv('Address',
                    '${b['address_line1'] ?? ''} ${b['address_line2'] ?? ''}'.trim()),
                HpUi.kv('Locality', '${b['locality'] ?? '—'}'),
                HpUi.kv('Landmark', '${b['landmark'] ?? '—'}'),
                HpUi.kv('City', '${b['city'] ?? ''} ${b['pincode'] ?? ''}'.trim()),
              ],
            ),
          ),
          if ((b['spl_care_requirements'] ?? '').toString().isNotEmpty &&
              b['spl_care_requirements'] != 'NA') ...[
            const SizedBox(height: 12),
            HpUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HpUi.sectionTitle('Special care'),
                  Text('${b['spl_care_requirements']}',
                      style: TextStyle(color: AppColor.fontColorBlack)),
                  if ((b['spl_instructions'] ?? '').toString().isNotEmpty &&
                      b['spl_instructions'] != 'NA') ...[
                    const SizedBox(height: 8),
                    Text('${b['spl_instructions']}',
                        style: TextStyle(color: AppColor.fontColorGrey)),
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
