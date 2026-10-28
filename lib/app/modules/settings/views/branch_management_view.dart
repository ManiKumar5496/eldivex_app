import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/settings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class BranchManagementView extends StatefulWidget {
  const BranchManagementView({super.key});

  @override
  State<BranchManagementView> createState() => _BranchManagementViewState();
}

class _BranchManagementViewState extends State<BranchManagementView> {
  SettingsController get controller => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    // Fetch once per visit (not from build, which re-runs on every rebuild).
    if (!controller.branchesLoaded) controller.fetchBranches();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(narrow ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
    return AppPageHeader(
      title: 'Branch Management',
      subtitle: 'Add, edit, and activate or deactivate city branches.',
      onBack: () => Get.back(),
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showBranchDialog(context, controller),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add Branch'),
        ),
      ],
    );
  }
}

// ── Branches List ─────────────────────────────────────────────────────────────

/// Column widths shared by the header and the rows.
const double _kStatusCol = 96;
const double _kActionCol = 64;
const double _kTableMinWidth = 760;

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
        return AppCard(
          child: AppEmptyState(
            icon: LucideIcons.landmark,
            tone: AppTone.primary,
            title: 'No branches yet',
            message: 'Click "Add Branch" to register your first branch.',
            actionLabel: 'Add Branch',
            actionIcon: LucideIcons.plus,
            onAction: () => _showBranchDialog(context, controller),
          ),
        );
      }

      final count = controller.filteredBranches.length;
      return AppCard(
        expandChild: true,
        padding: EdgeInsets.zero,
        title: 'All branches',
        subtitle: '$count of ${controller.branchesList.length} '
            '${controller.branchesList.length == 1 ? 'branch' : 'branches'}',
        actions: [
          AppSearchField(
            hint: 'Search branches by name, city, state...',
            onChanged: controller.searchBranches,
            width: MediaQuery.sizeOf(context).width < 600 ? null : 320,
          ),
        ],
        child: LayoutBuilder(builder: (context, constraints) {
          final tableWidth = constraints.maxWidth < _kTableMinWidth
              ? _kTableMinWidth
              : constraints.maxWidth;

          final table = SizedBox(
            width: tableWidth,
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _TableHeader(),
                Expanded(
                  child: count == 0
                      ? const AppEmptyState(
                          icon: LucideIcons.searchX,
                          title: 'No matching branches',
                          message: 'Try a different name, city or state.',
                          compact: true,
                        )
                      : ListView.separated(
                          itemCount: controller.filteredBranches.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: AppColor.borderSubtle),
                          itemBuilder: (context, index) {
                            final branch = controller.filteredBranches[index];
                            return _BranchRow(
                              branch: branch,
                              controller: controller,
                              onEdit: () => _showBranchDialog(
                                  context, controller, branch),
                            );
                          },
                        ),
                ),
              ],
            ),
          );

          if (tableWidth == constraints.maxWidth) return table;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          );
        }),
      );
    });
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColor.textTertiary,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Branch Name', style: style)),
          Expanded(flex: 2, child: Text('City / State', style: style)),
          Expanded(flex: 3, child: Text('Address', style: style)),
          SizedBox(width: _kStatusCol, child: Text('Active', style: style)),
          SizedBox(
            width: _kActionCol,
            child: Text('Actions', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
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
    final id = SettingsController.toInt(branch['br_id'], fallback: 0);
    final name = branch['br_name']?.toString() ?? '—';
    final city = branch['br_city']?.toString() ?? '';
    final state = branch['br_state']?.toString() ?? '';
    final address = branch['br_address']?.toString() ?? '—';
    final status = SettingsController.toInt(branch['br_status'], fallback: 0);
    final isActive = status == 1;
    final cityState = [city, state].where((s) => s.isNotEmpty).join(', ');

    return _HoverRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  AppIconTile(
                    icon: LucideIcons.landmark,
                    tone: isActive ? AppTone.primary : AppTone.neutral,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                cityState.isEmpty ? '—' : cityState,
                style: TextStyle(fontSize: 13.5, color: AppColor.textSecondary),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  address,
                  style:
                      TextStyle(fontSize: 13.5, color: AppColor.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(
              width: _kStatusCol,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: isActive ? 'Deactivate branch' : 'Activate branch',
                  child: Switch(
                    value: isActive,
                    onChanged: (_) => controller.toggleBranchStatus(id, status),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _kActionCol,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Edit branch',
                  onPressed: onEdit,
                  icon: const Icon(LucideIcons.pencil, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Table row background that tints on mouse hover.
class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.child});
  final Widget child;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ColoredBox(
        color: _hover ? AppColor.surfaceMuted : Colors.transparent,
        child: widget.child,
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
  String clean(dynamic v) {
    final s = v?.toString() ?? '';
    return s == 'NA' ? '' : s;
  }
  final phoneCtrl = TextEditingController(
    text: isEdit ? clean(existing['br_phone']) : '',
  );
  final emailCtrl = TextEditingController(
    text: isEdit ? clean(existing['br_email']) : '',
  );

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AppDialog(
        title: isEdit ? 'Edit Branch' : 'Add Branch',
        subtitle: isEdit
            ? 'Update the branch details.'
            : 'Register a new city branch office.',
        icon: LucideIcons.landmark,
        maxWidth: 560,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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
                      final phone = phoneCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      if (name.isEmpty || city.isEmpty || state.isEmpty) {
                        HelperUi.showToast(
                            message: 'Branch name, city and state are required.',
                            backgroundColor: AppColor.danger);
                        return;
                      }
                      if (phone.isNotEmpty &&
                          !RegExp(r'^[0-9+\- ]{7,15}$').hasMatch(phone)) {
                        HelperUi.showToast(
                            message: 'Enter a valid phone number.',
                            backgroundColor: AppColor.danger);
                        return;
                      }
                      if (email.isNotEmpty && !GetUtils.isEmail(email)) {
                        HelperUi.showToast(
                            message: 'Enter a valid email address.',
                            backgroundColor: AppColor.danger);
                        return;
                      }
                      bool ok;
                      if (isEdit) {
                        ok = await controller.updateBranch(
                          id: SettingsController.toInt(existing['br_id']),
                          name: name,
                          city: city,
                          state: state,
                          address: addressCtrl.text.trim(),
                          phone: phone,
                          email: email,
                        );
                      } else {
                        ok = await controller.createBranch(
                          name: name,
                          city: city,
                          state: state,
                          address: addressCtrl.text.trim(),
                          phone: phone,
                          email: email,
                        );
                      }
                      if (ok && ctx.mounted) Navigator.of(ctx).pop();
                    },
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.buttonTextWhite,
                      ),
                    )
                  : Text(isEdit ? 'Save Changes' : 'Create'),
            );
          }),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _labeled(
              'Branch Name *',
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    hintText: 'e.g. Mumbai Central'),
              ),
            ),
            const SizedBox(height: 16),
            _pair(
              _labeled(
                'City *',
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(hintText: 'City'),
                ),
              ),
              _labeled(
                'State *',
                TextField(
                  controller: stateCtrl,
                  decoration: const InputDecoration(hintText: 'State'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _pair(
              _labeled(
                'Phone',
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: 'e.g. 9876543210'),
                ),
              ),
              _labeled(
                'Email',
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      hintText: 'branch@example.com'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _labeled(
              'Full Address',
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Street address, landmark…'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Label above a field (13/w600, secondary text).
Widget _labeled(String label, Widget field) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.textSecondary,
        ),
      ),
      const SizedBox(height: 6),
      field,
    ],
  );
}

/// Two fields side by side; stacked when the dialog is narrow.
Widget _pair(Widget left, Widget right) {
  return LayoutBuilder(builder: (context, constraints) {
    if (constraints.maxWidth < 400) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [left, const SizedBox(height: 16), right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  });
}
