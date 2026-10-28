import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../widgets/ui/ui.dart';
import '../../controllers/hp_controller.dart';
import '../hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
    final pad = HpUi.pagePadding(context);
    return RefreshIndicator(
      onRefresh: () => c.fetchAttendance(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad.left, 20, pad.right, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HpUi.tabHeader('Attendance',
                      subtitle: 'Your attendance history'),
                  Obx(() => _summaryRow(c)),
                  const SizedBox(height: 24),
                  HpUi.sectionTitle('History'),
                ],
              ),
            ),
          ),
          Obx(() {
            if (c.loadingAttendance.value) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (c.attendance.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  compact: true,
                  icon: LucideIcons.calendarDays,
                  title: 'No attendance records yet',
                  message: 'Your check-ins will appear here.',
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(pad.left, 0, pad.right, 24),
              sliver: SliverList.separated(
                itemCount: c.attendance.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _row(c.attendance[i]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _summaryRow(HpController c) {
    int count(String s) => c.attendance.where((a) => a['status'] == s).length;
    final items = [
      ('Present', count('present'), AppTone.success,
          LucideIcons.circleCheck),
      ('Half day', count('half_day'), AppTone.warning, LucideIcons.clockFading),
      ('Leave', count('leave'), AppTone.violet, LucideIcons.umbrella),
      ('Absent', count('absent'), AppTone.danger, LucideIcons.circleX),
    ];
    return AppResponsiveGrid(
      minItemWidth: 140,
      maxColumns: 4,
      spacing: 12,
      children: items
          .map((e) => AppStatCard(
                label: e.$1,
                value: '${e.$2}',
                tone: e.$3,
                icon: e.$4,
              ))
          .toList(),
    );
  }

  Widget _row(Map<String, dynamic> a) {
    final status = a['status']?.toString();
    final tone = HpUi.attendanceTone(status);
    return HpUi.card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                  color: tone.color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${a['att_date'] ?? a['from_date'] ?? '—'}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${(a['shift_type'] ?? '').toString().replaceAll('_', '-')}'
                  '${a['check_in'] != null ? '  •  ${a['check_in']}' : ''}'
                  '${a['check_out'] != null ? ' → ${a['check_out']}' : ''}',
                  style:
                      TextStyle(color: AppColor.textTertiary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          HpUi.attendanceBadge(status),
        ],
      ),
    );
  }
}
