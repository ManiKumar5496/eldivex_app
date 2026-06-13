import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/organisations_controller.dart';

class OrganisationsView extends GetView<OrganisationsController> {
  const OrganisationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Organisations', style: AppTextStyles.heading),
                      const SizedBox(height: 4),
                      Text(
                        'Manage tenant organisations and their subscription plans.',
                        style: AppTextStyles.regular14Gre,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showOrgDialog(context, null),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Org'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cPrimaryButtonColor,
                      foregroundColor: AppColor.buttonTextWhite,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Table ────────────────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.orgs.isEmpty) {
                    return const Center(child: Text('No organisations found.'));
                  }
                  return _buildTable(context);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return ListView.separated(
        itemCount: controller.orgs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildOrgCard(context, controller.orgs[i]),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColor.cAppBackgroundColor),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Org ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Slug')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Plan')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: controller.orgs.map((org) {
            return DataRow(cells: [
              DataCell(Text(org.publicId)),
              DataCell(Text(org.name)),
              DataCell(Text(org.slug)),
              DataCell(Text(org.email.isEmpty ? '—' : org.email)),
              DataCell(_PlanChip(org.planName)),
              DataCell(_StatusBadge(org.status)),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showOrgDialog(context, org),
                    tooltip: 'Edit',
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrgCard(BuildContext context, org) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(org.name,
                    style: AppTextStyles.regular16
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              _StatusBadge(org.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('${org.publicId} · ${org.slug}', style: AppTextStyles.regular14Gre),
          if (org.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(org.email, style: AppTextStyles.regular14Gre),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PlanChip(org.planName),
              TextButton.icon(
                onPressed: () => _showOrgDialog(context, org),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrgDialog(BuildContext context, org) {
    final isEdit = org != null;
    if (isEdit) controller.populateForEdit(org);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Organisation' : 'New Organisation'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(controller.nameCtrl, 'Name', isRequired: true),
                const SizedBox(height: 12),
                _field(controller.slugCtrl, 'Slug (unique identifier)',
                    isRequired: true, enabled: !isEdit),
                const SizedBox(height: 12),
                _field(controller.emailCtrl, 'Email'),
                const SizedBox(height: 12),
                _field(controller.phoneCtrl, 'Phone'),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedPlan.value,
                      decoration:
                          const InputDecoration(labelText: 'Plan', border: OutlineInputBorder()),
                      items: ['Starter', 'Growth', 'Enterprise']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedPlan.value = v ?? 'Starter',
                    )),
                if (isEdit) ...[
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedStatus.value,
                        decoration:
                            const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                        items: ['active', 'suspended', 'trial']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedStatus.value = v ?? 'active',
                      )),
                ],
                if (!isEdit) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Admin User (optional)',
                      style: AppTextStyles.regular14Gre),
                  const SizedBox(height: 12),
                  _field(controller.adminEmailCtrl, 'Admin Email'),
                  const SizedBox(height: 12),
                  _field(controller.adminPasswordCtrl, 'Admin Password',
                      obscure: true),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: controller.saving.value
                    ? null
                    : () async {
                        if (isEdit) {
                          await controller.updateOrganisation(org.id);
                        } else {
                          await controller.createOrganisation();
                        }
                        if (!controller.saving.value) Get.back();
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    foregroundColor: AppColor.buttonTextWhite),
                child: controller.saving.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.buttonTextWhite))
                    : Text(isEdit ? 'Save' : 'Create'),
              )),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool isRequired = false, bool obscure = false, bool enabled = true}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────────

class _PlanChip extends StatelessWidget {
  const _PlanChip(this.plan);
  final String plan;

  @override
  Widget build(BuildContext context) {
    final color = plan == 'Enterprise'
        ? Colors.purple
        : plan == 'Growth'
            ? Colors.blue
            : AppColor.fontColorGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(plan,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == 'active'
        ? Colors.green
        : status == 'trial'
            ? Colors.orange
            : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
