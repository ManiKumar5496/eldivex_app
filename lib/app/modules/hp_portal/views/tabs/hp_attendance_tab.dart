import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';

class HpAttendanceTab extends StatefulWidget {
  const HpAttendanceTab({super.key});

  @override
  State<HpAttendanceTab> createState() => _HpAttendanceTabState();
}

class _HpAttendanceTabState extends State<HpAttendanceTab> {
  final c = Get.find<HpController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.attendance.isEmpty) c.fetchAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Attendance history',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.cPrimaryHeadingColor)),
          ),
        ),
        Obx(() => _summaryRow(c)),
        Expanded(
          child: Obx(() {
            if (c.loadingAttendance.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.attendance.isEmpty) {
              return HpUi.empty('No attendance records yet.', icon: Icons.event_note);
            }
            return RefreshIndicator(
              onRefresh: () => c.fetchAttendance(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: c.attendance.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _row(c.attendance[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _summaryRow(HpController c) {
    int count(String s) => c.attendance.where((a) => a['status'] == s).length;
    final items = [
      ('Present', count('present'), AppColor.lightGreen),
      ('Half', count('half_day'), Colors.orange),
      ('Leave', count('leave'), AppColor.consultCColor),
      ('Absent', count('absent'), AppColor.calenderRed),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items
            .map((e) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: e.$3.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text('${e.$2}',
                            style: TextStyle(color: e.$3, fontWeight: FontWeight.w800, fontSize: 18)),
                        Text(e.$1, style: TextStyle(color: e.$3, fontSize: 11)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _row(Map<String, dynamic> a) {
    final status = a['status']?.toString();
    final color = HpUi.attendanceColor(status);
    return HpUi.card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(width: 8, height: 40,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${a['att_date'] ?? a['from_date'] ?? '—'}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColor.fontColorBlack)),
                Text(
                  '${(a['shift_type'] ?? '').toString().replaceAll('_', '-')}'
                  '${a['check_in'] != null ? '  •  ${a['check_in']}' : ''}'
                  '${a['check_out'] != null ? ' → ${a['check_out']}' : ''}',
                  style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          HpUi.statusChip((status ?? '—').toUpperCase(), color),
        ],
      ),
    );
  }
}
