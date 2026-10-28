import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/color_constants.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/ui/ui.dart';
import '../../../hp_portal/views/hp_widgets.dart';
import '../../controllers/client_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ClientDashboardTab extends StatelessWidget {
  const ClientDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ClientController>();
    return RefreshIndicator(
      onRefresh: c.refreshDashboard,
      child: ListView(
        padding: HpUi.pagePadding(context, top: 20),
        children: [
          HpUi.greeting('Welcome,', c.clientName),
          const SizedBox(height: 24),
          Obx(() {
            final o = c.outstanding.value;
            final due = ((o?['outstanding'] ?? 0) as num) > 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppStatCard(
                  label: 'Outstanding balance',
                  value: HpUi.money(o?['outstanding'] ?? 0),
                  icon: due
                      ? LucideIcons.circleAlert
                      : LucideIcons.circleCheck,
                  tone: due ? AppTone.danger : AppTone.success,
                ),
                const SizedBox(height: 12),
                AppResponsiveGrid(
                  minItemWidth: 130,
                  maxColumns: 2,
                  spacing: 12,
                  children: [
                    AppStatCard(
                      label: 'Billed',
                      value: HpUi.money(o?['total_invoiced'] ?? 0),
                      icon: LucideIcons.receiptText,
                    ),
                    AppStatCard(
                      label: 'Paid',
                      value: HpUi.money(o?['total_paid'] ?? 0),
                      icon: LucideIcons.banknote,
                      tone: AppTone.success,
                    ),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          Obx(() {
            final active = c.bookings.where((b) => [2, 4, 5].contains(b['status'])).toList();
            return AppCard(
              title: 'Active bookings',
              icon: LucideIcons.calendarDays,
              padding: EdgeInsets.zero,
              child: active.isEmpty
                  ? const AppEmptyState(
                      compact: true,
                      icon: LucideIcons.calendarX,
                      title: 'No active bookings',
                    )
                  : Material(
                      type: MaterialType.transparency,
                      child: Column(
                        children: [
                          for (var i = 0; i < active.length; i++) ...[
                            if (i > 0)
                              Divider(
                                  height: 1,
                                  indent: 64,
                                  color: AppColor.borderSubtle),
                            _bookingRow(active[i]),
                          ],
                        ],
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget _bookingRow(Map<String, dynamic> b) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.CLIENT_BOOKING_DETAIL, arguments: b),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const AppIconTile(icon: LucideIcons.stethoscope, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${b['patient_name'] ?? 'Patient'} • ${b['service_name'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary)),
                  const SizedBox(height: 4),
                  AppStatusBadge.status('${b['status_label'] ?? ''}',
                      dense: true),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 20, color: AppColor.textTertiary),
          ],
        ),
      ),
    );
  }
}
