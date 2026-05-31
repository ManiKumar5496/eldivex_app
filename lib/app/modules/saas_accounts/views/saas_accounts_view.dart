import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/saas_accounts_controller.dart';
import 'account_health_view.dart';
import 'account_list_tab.dart';
import 'create_account_wizard.dart';
import 'saas_billing_view.dart';
import 'subscription_management_view.dart';

class SaasAccountsView extends GetView<SaasAccountsController> {
  const SaasAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SaaS Accounts', style: AppTextStyles.heading),
                        const SizedBox(height: 4),
                        Text(
                          'Manage tenant organisations, subscriptions and billing.',
                          style: AppTextStyles.regular14Gre,
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: CreateAccountWizard.show,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── KPI summary row ───────────────────────────────────────
                Obx(() => Row(
                      children: [
                        _KpiCard(
                          label: 'Total',
                          value: '${controller.totalOrgs.value}',
                          color: AppColor.cPrimaryButtonColor,
                        ),
                        const SizedBox(width: 12),
                        _KpiCard(
                          label: 'Active',
                          value: '${controller.activeOrgs.value}',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _KpiCard(
                          label: 'Trial',
                          value: '${controller.trialOrgs.value}',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _KpiCard(
                          label: 'Expiring Soon',
                          value: '${controller.expiringOrgs.value}',
                          color: controller.expiringOrgs.value > 0
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ],
                    )),
                const SizedBox(height: 20),

                // ── Tab bar ───────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.divColor),
                  ),
                  child: TabBar(
                    labelColor: AppColor.cPrimaryButtonColor,
                    unselectedLabelColor: AppColor.fontColorGrey,
                    indicatorColor: AppColor.cPrimaryButtonColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      const Tab(text: 'Accounts'),
                      const Tab(text: 'Subscriptions'),
                      const Tab(text: 'Billing'),
                      Obx(() => Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Health'),
                                if (controller.healthSummary
                                    .any((h) => (h['alerts'] as List).isNotEmpty))
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${controller.healthSummary.where((h) => (h['alerts'] as List).isNotEmpty).length}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ],
                    onTap: (index) {
                      if (index == 2) {
                        controller.fetchBillingInvoices();
                      } else if (index == 3) {
                        controller.fetchHealthSummary();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tab content ───────────────────────────────────────────
                const Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      AccountListTab(),
                      SubscriptionManagementView(),
                      SaasBillingView(),
                      AccountHealthView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small KPI card ────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.regular14Gre.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
