import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/saas_accounts_controller.dart';
import 'widgets/plan_chip.dart';
import 'widgets/usage_progress_bar.dart';

class AccountHealthView extends GetView<SaasAccountsController> {
  const AccountHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadingHealth.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.healthSummary.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 48, color: AppColor.divColor),
              const SizedBox(height: 12),
              Text('No health data yet.', style: AppTextStyles.regular14Gre),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.fetchHealthSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: AppColor.buttonTextWhite,
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      final alerts = controller.healthSummary
          .where((h) => (h['alerts'] as List).isNotEmpty)
          .toList();
      final healthy = controller.healthSummary
          .where((h) => (h['alerts'] as List).isEmpty)
          .toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Account Health Dashboard',
                    style: AppTextStyles.semiBold16),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.fetchHealthSummary,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary KPI row
            Row(
              children: [
                _KpiTile(
                  label: 'Total Accounts',
                  value: '${controller.healthSummary.length}',
                  color: AppColor.cPrimaryButtonColor,
                  icon: Icons.business,
                ),
                const SizedBox(width: 12),
                _KpiTile(
                  label: 'Needs Attention',
                  value: '${alerts.length}',
                  color: alerts.isEmpty ? Colors.green : Colors.orange,
                  icon: Icons.warning_amber_outlined,
                ),
                const SizedBox(width: 12),
                _KpiTile(
                  label: 'Healthy',
                  value: '${healthy.length}',
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (alerts.isNotEmpty) ...[
              Text('Needs Attention',
                  style: AppTextStyles.semiBold16
                      .copyWith(color: Colors.orange.shade700)),
              const SizedBox(height: 10),
              ...alerts.map((h) => _HealthCard(data: h)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
            ],

            if (healthy.isNotEmpty) ...[
              Text('Healthy Accounts',
                  style: AppTextStyles.semiBold16
                      .copyWith(color: Colors.green.shade700)),
              const SizedBox(height: 10),
              ...healthy.map((h) => _HealthCard(data: h)),
            ],
          ],
        ),
      );
    });
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(label,
                    style: TextStyle(
                        fontSize: 12, color: AppColor.fontColorGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final alerts       = List<String>.from(data['alerts'] as List? ?? []);
    final healthScore  = (data['health_score'] as num?)?.toInt() ?? 100;
    final bookingPct   = (data['booking_pct'] as num?)?.toInt() ?? 0;
    final bookingUsed  = (data['bookings_used'] as num?)?.toInt() ?? 0;
    final bookingLimit = (data['booking_limit'] as num?)?.toInt() ?? 0;
    final daysToExp    = data['days_to_expiry'] as int?;
    final planName     = data['plan_name']?.toString() ?? '';

    final scoreColor = healthScore >= 75
        ? Colors.green
        : healthScore >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: alerts.isEmpty
                ? AppColor.divColor
                : Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['org_name']?.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    SaasPlanChip(planName),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Health $healthScore%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scoreColor),
                ),
              ),
            ],
          ),
          if (alerts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: alerts.map((a) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Text(a,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.orange)),
                  )).toList(),
            ),
          ],
          if (bookingLimit > 0 && bookingPct > 0) ...[
            const SizedBox(height: 12),
            UsageProgressBar(
              label: 'Bookings',
              used: bookingUsed,
              limit: bookingLimit,
              pct: bookingPct,
            ),
          ],
          if (daysToExp != null) ...[
            const SizedBox(height: 8),
            Text(
              daysToExp < 0
                  ? 'Subscription expired ${-daysToExp} days ago'
                  : 'Expires in $daysToExp days',
              style: TextStyle(
                  fontSize: 12,
                  color: daysToExp < 0
                      ? AppColor.calenderRed
                      : daysToExp <= 7
                          ? Colors.red
                          : daysToExp <= 30
                              ? Colors.orange
                              : AppColor.fontColorGrey),
            ),
          ],
        ],
      ),
    );
  }
}
