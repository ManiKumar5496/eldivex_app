import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/settings_controller.dart';

class BranchManagementView extends GetView<SettingsController> {
  const BranchManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    if (controller.branchesList.isEmpty) {
      controller.fetchBranches();
    }

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(controller: controller),
              const SizedBox(height: 24),
              Expanded(child: _BranchesList(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppColor.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColor.divColor),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Branch Management', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Add, edit, and activate or deactivate city branches.',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showBranchDialog(context, controller),
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: Text('Add Branch', style: AppTextStyles.regular14white),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ── Branches List ─────────────────────────────────────────────────────────────

class _BranchesList extends StatelessWidget {
  const _BranchesList({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isBranchesLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.branchesList.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 56,
                color: AppColor.lightGrey,
              ),
              const SizedBox(height: 16),
              Text('No branches yet', style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text(
                'Click "Add Branch" to register your first branch.',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Branch Name',
                    style: AppTextStyles.regular14Gre.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'City / State',
                    style: AppTextStyles.regular14Gre.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Address',
                    style: AppTextStyles.regular14Gre.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Active',
                    style: AppTextStyles.regular14Gre.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 80),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: controller.branchesList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final branch = controller.branchesList[index];
                return _BranchRow(
                  branch: branch,
                  controller: controller,
                  onEdit: () => _showBranchDialog(context, controller, branch),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ── Branch Row ────────────────────────────────────────────────────────────────

class _BranchRow extends StatelessWidget {
  const _BranchRow({
    required this.branch,
    required this.controller,
    required this.onEdit,
  });
  final Map<String, dynamic> branch;
  final SettingsController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final id = branch['br_id'] as int? ?? 0;
    final name = branch['br_name']?.toString() ?? '—';
    final city = branch['br_city']?.toString() ?? '';
    final state = branch['br_state']?.toString() ?? '';
    final address = branch['br_address']?.toString() ?? '—';
    final status = (branch['br_status'] as int?) ?? 0;
    final isActive = status == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: AppTextStyles.regular16.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              [city, state].where((s) => s.isNotEmpty).join(', '),
              style: AppTextStyles.regular14Gre,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              address,
              style: AppTextStyles.regular14Gre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: Switch(
              value: isActive,
              activeThumbColor: AppColor.cAppPrimaryColor,
              activeTrackColor: AppColor.cAppPrimaryColor.withValues(
                alpha: 0.3,
              ),
              onChanged: (_) => controller.toggleBranchStatus(id, status),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextButton(
              onPressed: onEdit,
              child: Text('Edit', style: AppTextStyles.regular16blue),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add / Edit Dialog ─────────────────────────────────────────────────────────

void _showBranchDialog(
  BuildContext context,
  SettingsController controller, [
  Map<String, dynamic>? existing,
]) {
  final isEdit = existing != null;
  final nameCtrl = TextEditingController(
    text: isEdit ? existing['br_name']?.toString() : '',
  );
  final cityCtrl = TextEditingController(
    text: isEdit ? existing['br_city']?.toString() : '',
  );
  final stateCtrl = TextEditingController(
    text: isEdit ? existing['br_state']?.toString() : '',
  );
  final addressCtrl = TextEditingController(
    text: isEdit ? existing['br_address']?.toString() : '',
  );

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isEdit ? 'Edit Branch' : 'Add Branch',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Branch Name *', style: AppTextStyles.fieldsHeading16),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: _inputDecoration('e.g. Mumbai Central'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('City *', style: AppTextStyles.fieldsHeading16),
                        const SizedBox(height: 6),
                        TextField(
                          controller: cityCtrl,
                          decoration: _inputDecoration('City'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('State *', style: AppTextStyles.fieldsHeading16),
                        const SizedBox(height: 6),
                        TextField(
                          controller: stateCtrl,
                          decoration: _inputDecoration('State'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Full Address', style: AppTextStyles.fieldsHeading16),
              const SizedBox(height: 6),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: _inputDecoration('Street address, landmark…'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTextStyles.regular16Gre),
          ),
          Obx(() {
            final loading = controller.isBranchSubmitting.value;
            return ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final city = cityCtrl.text.trim();
                      final state = stateCtrl.text.trim();
                      if (name.isEmpty || city.isEmpty || state.isEmpty) {
                        return;
                      }
                      bool ok;
                      if (isEdit) {
                        ok = await controller.updateBranch(
                          id: existing['br_id'] as int,
                          name: name,
                          city: city,
                          state: state,
                          address: addressCtrl.text.trim(),
                        );
                      } else {
                        ok = await controller.createBranch(
                          name: name,
                          city: city,
                          state: state,
                          address: addressCtrl.text.trim(),
                        );
                      }
                      if (ok && ctx.mounted) Navigator.of(ctx).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEdit ? 'Save Changes' : 'Create',
                      style: AppTextStyles.regular16white,
                    ),
            );
          }),
        ],
      );
    },
  );
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.regular14Gre,
    filled: true,
    fillColor: AppColor.fieldColorGrey,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColor.textFieldBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColor.textFieldBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColor.cPrimaryButtonColor, width: 1.5),
    ),
  );
}
