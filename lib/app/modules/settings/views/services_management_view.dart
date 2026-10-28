import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/settings_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ServicesManagementView extends StatefulWidget {
  const ServicesManagementView({super.key});

  @override
  State<ServicesManagementView> createState() => _ServicesManagementViewState();
}

class _ServicesManagementViewState extends State<ServicesManagementView> {
  SettingsController get controller => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    // Fetch once per visit (not from build, which re-runs on every rebuild).
    if (!controller.branchesLoaded) controller.fetchBranches();
    if (!controller.servicesLoaded) controller.fetchServices();
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
              Expanded(child: _ServicesList(controller: controller)),
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
    final itemStyle = TextStyle(fontSize: 14, color: AppColor.textPrimary);
    return AppPageHeader(
      title: 'Services Management',
      subtitle: 'Add, edit, and activate or deactivate services offered.',
      onBack: () => Get.back(),
      actions: [
        // ── Branch filter ─────────────────────────────────────────────────
        Obx(() {
          final branches = controller.branchesList;
          return Container(
            height: 40,
            padding: const EdgeInsets.only(left: 10, right: 6),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColor.borderStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.landmark,
                    size: 16, color: AppColor.textTertiary),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    // Value must be one of the items or the dropdown asserts.
                    value: branches.any((b) =>
                            SettingsController.toIntOrNull(b['br_id']) ==
                            controller.servicesFilterBranchId.value)
                        ? controller.servicesFilterBranchId.value
                        : null,
                    isDense: true,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    icon: Icon(LucideIcons.chevronDown,
                        size: 18, color: AppColor.textTertiary),
                    hint: Text('All Branches', style: itemStyle),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Branches', style: itemStyle),
                      ),
                      ...branches.map((b) {
                        final id = SettingsController.toIntOrNull(b['br_id']);
                        final name = b['br_name']?.toString() ?? '—';
                        return DropdownMenuItem<int?>(
                          value: id,
                          child: Text(name, style: itemStyle),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      controller.servicesFilterBranchId.value = val;
                      controller.fetchServices();
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: () => _showServiceDialog(context, controller),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add Service'),
        ),
      ],
    );
  }
}

// ── Services List ─────────────────────────────────────────────────────────────

const double _kRateCol = 130;
const double _kStatusCol = 84;
const double _kActionCol = 60;
const double _kTableMinWidth = 1040;

TextStyle get _headStyle => TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColor.textTertiary,
    );

TextStyle get _cellStyle =>
    TextStyle(fontSize: 13.5, color: AppColor.textSecondary);

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isServicesLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.servicesList.isEmpty) {
        return AppCard(
          child: AppEmptyState(
            icon: LucideIcons.stethoscope,
            tone: AppTone.primary,
            title: 'No services yet',
            message: 'Click "Add Service" to create your first service.',
            actionLabel: 'Add Service',
            actionIcon: LucideIcons.plus,
            onAction: () => _showServiceDialog(context, controller),
          ),
        );
      }

      final count = controller.filteredServices.length;
      final total = controller.servicesList.length;
      return AppCard(
        expandChild: true,
        padding: EdgeInsets.zero,
        title: 'All services',
        subtitle: '$count of $total ${total == 1 ? 'service' : 'services'}',
        actions: [
          AppSearchField(
            hint: 'Search services by name, description, category...',
            onChanged: controller.searchServices,
            width: MediaQuery.sizeOf(context).width < 600 ? null : 360,
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
                // Column headers
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceMuted,
                    border: Border(
                        bottom: BorderSide(color: AppColor.borderSubtle)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text('Service Name', style: _headStyle)),
                      Expanded(
                          flex: 3,
                          child: Text('Description', style: _headStyle)),
                      Expanded(
                          flex: 2, child: Text('Branch', style: _headStyle)),
                      Expanded(
                          flex: 2, child: Text('Category', style: _headStyle)),
                      SizedBox(
                        width: _kRateCol,
                        child: Text('Rate',
                            style: _headStyle, textAlign: TextAlign.right),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                          width: _kStatusCol,
                          child: Text('Status', style: _headStyle)),
                      SizedBox(
                        width: _kActionCol,
                        child: Text('Actions',
                            style: _headStyle, textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: count == 0
                      ? const AppEmptyState(
                          icon: LucideIcons.searchX,
                          title: 'No matching services',
                          message:
                              'Try a different name, description or category.',
                          compact: true,
                        )
                      : ListView.separated(
                          itemCount: controller.filteredServices.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: AppColor.borderSubtle),
                          itemBuilder: (context, index) {
                            final svc = controller.filteredServices[index];
                            return _ServiceRow(
                              service: svc,
                              controller: controller,
                              onEdit: () =>
                                  _showServiceDialog(context, controller, svc),
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

// ── Service Row ───────────────────────────────────────────────────────────────

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.controller,
    required this.onEdit,
  });
  final Map<String, dynamic> service;
  final SettingsController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final id = SettingsController.toInt(service['id'], fallback: 0);
    final name = service['name']?.toString() ?? '—';
    final isPremium = SettingsController.toIntOrNull(service['service_type']) == 2;
    final gender = service['gender']?.toString() ?? '';
    final careType = service['care_type']?.toString() ?? '';
    final description = service['description']?.toString() ?? '—';
    final branchName = service['br_name']?.toString() ?? '—';
    final categoryName = service['category_name']?.toString() ?? '';
    final serviceRate = service['service_rate']?.toString() ?? '';
    final effectiveFrom = service['effective_from_date']?.toString() ?? '';
    final status = SettingsController.toInt(service['status'], fallback: 0);
    final isActive = status == 1;

    return _HoverRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Tag(
                          label: isPremium ? 'Premium' : 'Normal',
                          tone: isPremium ? AppTone.primary : AppTone.neutral,
                        ),
                        if (careType.isNotEmpty)
                          _Tag(label: careType, tone: AppTone.info),
                        if (gender.isNotEmpty && gender != 'Any')
                          _Tag(label: gender, tone: AppTone.neutral),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  description,
                  style: _cellStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                branchName,
                style: _cellStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                categoryName.isEmpty ? '—' : categoryName,
                style: _cellStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: _kRateCol,
              child: serviceRate.isEmpty
                  ? Text('—', style: _cellStyle, textAlign: TextAlign.right)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹$serviceRate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (effectiveFrom.isNotEmpty)
                          Text(
                            'from $effectiveFrom',
                            style: TextStyle(
                                fontSize: 12, color: AppColor.textTertiary),
                          ),
                      ],
                    ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: _kStatusCol,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: isActive ? 'Deactivate service' : 'Activate service',
                  child: Switch(
                    value: isActive,
                    onChanged: (_) =>
                        controller.toggleServiceStatus(id, status),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _kActionCol,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Edit service',
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

// ── Small pill tag (service type / gender) ─────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.tone});
  final String label;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(label: label, tone: tone, showDot: false, dense: true);
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

void _showServiceDialog(
  BuildContext context,
  SettingsController controller, [
  Map<String, dynamic>? existing,
]) {
  final isEdit = existing != null;
  final originalRate = isEdit ? (existing['service_rate']?.toString() ?? '') : '';

  final nameCtrl = TextEditingController(text: isEdit ? existing['name']?.toString() : '');
  final descCtrl = TextEditingController(text: isEdit ? existing['description']?.toString() : '');
  final rateCtrl = TextEditingController(text: originalRate);
  final marketRateCtrl = TextEditingController(
      text: isEdit ? (existing['market_rate']?.toString() ?? '') : '');
  final rateObs = RxString(originalRate); // reactive mirror for asterisk visibility

  final initialBranchId = isEdit
      ? SettingsController.toIntOrNull(existing['branch_id'])
      : controller.servicesFilterBranchId.value;
  final selectedBranchId = RxnInt()..value = initialBranchId;
  final selectedCategoryId = RxnInt()
    ..value = isEdit ? SettingsController.toIntOrNull(existing['service_category_id']) : null;
  // service_type: 1 = Normal, 2 = Premium
  final selectedServiceType = RxInt(isEdit ? (SettingsController.toInt(existing['service_type'], fallback: 1)) : 1);
  // care_type: care arrangement, independent of the Normal/Premium tier
  const careTypes = ['Live-in', 'Live-out', 'Liveout-day', 'Liveout-night'];
  final existingCareType = isEdit ? existing['care_type']?.toString() : null;
  final selectedCareType = RxString(
      (existingCareType != null && careTypes.contains(existingCareType))
          ? existingCareType
          : careTypes.first);
  // Service gender: Male / Female / Any
  final selectedGender = RxString(
      isEdit ? (existing['gender']?.toString().isNotEmpty == true ? existing['gender'].toString() : 'Any') : 'Any');
  final selectedEffectiveDate = Rxn<DateTime>();

  rateCtrl.addListener(() => rateObs.value = rateCtrl.text.trim());

  // Pre-fill effective date from existing record if present
  if (isEdit) {
    final raw = existing['effective_from_date']?.toString() ?? '';
    if (raw.isNotEmpty) {
      try { selectedEffectiveDate.value = DateTime.parse(raw); } catch (_) {}
    }
  }

  showDialog<void>(
    context: context,
    builder: (ctx) {
      final itemStyle = TextStyle(fontSize: 14, color: AppColor.textPrimary);
      return AppDialog(
        title: isEdit ? 'Edit Service' : 'Add Service',
        subtitle: isEdit
            ? 'Update details, pricing and availability.'
            : 'Define a service, its branch, category and pricing.',
        icon: LucideIcons.stethoscope,
        maxWidth: 640,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          Obx(() {
            final loading = controller.isServiceSubmitting.value;
            return ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      // Category + branch are required so the service can be
                      // matched by the branch+category-scoped booking picker.
                      if (selectedCategoryId.value == null) {
                        HelperUi.showToast(
                            message: 'Please select a category.');
                        return;
                      }
                      if (selectedBranchId.value == null) {
                        HelperUi.showToast(message: 'Please select a branch.');
                        return;
                      }

                      final rateText = rateCtrl.text.trim();
                      final rateChanged = rateText != originalRate && rateText.isNotEmpty;

                      // Client-side guard: effective date required if rate changed
                      if (rateChanged && selectedEffectiveDate.value == null) {
                        HelperUi.showToast(
                            message: 'Please select an effective date for the rate change.');
                        return;
                      }

                      final effectiveDateStr = selectedEffectiveDate.value != null
                          ? DateFormat('yyyy-MM-dd').format(selectedEffectiveDate.value!)
                          : null;

                      bool ok;
                      final marketRateText = marketRateCtrl.text.trim();
                      if (isEdit) {
                        ok = await controller.updateService(
                          id: SettingsController.toInt(existing['id']),
                          name: name,
                          description: descCtrl.text.trim(),
                          serviceType: selectedServiceType.value,
                          gender: selectedGender.value,
                          careType: selectedCareType.value,
                          categoryId: selectedCategoryId.value,
                          branchId: selectedBranchId.value,
                          serviceRate: rateText.isNotEmpty ? rateText : null,
                          marketRate: marketRateText.isNotEmpty ? marketRateText : null,
                          effectiveFromDate: effectiveDateStr,
                        );
                      } else {
                        ok = await controller.createService(
                          name: name,
                          description: descCtrl.text.trim(),
                          serviceType: selectedServiceType.value,
                          gender: selectedGender.value,
                          careType: selectedCareType.value,
                          categoryId: selectedCategoryId.value,
                          branchId: selectedBranchId.value,
                          serviceRate: rateText.isNotEmpty ? rateText : null,
                          marketRate: marketRateText.isNotEmpty ? marketRateText : null,
                          effectiveFromDate: effectiveDateStr,
                        );
                      }
                      if (ok && ctx.mounted) Navigator.of(ctx).pop();
                    },
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.buttonTextWhite),
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
              'Service Name *',
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Elder Care'),
              ),
            ),
            const SizedBox(height: 16),
            _labeled(
              'Description',
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Brief description of the service'),
              ),
            ),
            const SizedBox(height: 16),
            _row([
              _labeled(
                'Category *',
                Obx(() {
                  final dashboard = Get.find<DashboardController>();
                  final categories = dashboard.categoriesList;
                  return _dropdownBox(
                    DropdownButton<int?>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
                      value: selectedCategoryId.value,
                      hint: Text('Select category', style: itemStyle),
                      isExpanded: true,
                      items: [
                        ...categories.map((c) => DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(c.catName, style: itemStyle),
                            )),
                      ],
                      onChanged: (val) => selectedCategoryId.value = val,
                    ),
                  );
                }),
              ),
              _labeled(
                'Branch *',
                Obx(() {
                  final branches = controller.branchesList;
                  return _dropdownBox(
                    DropdownButton<int?>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
                      value: branches.any((b) =>
                              SettingsController.toIntOrNull(b['br_id']) ==
                              selectedBranchId.value)
                          ? selectedBranchId.value
                          : null,
                      hint: Text('Select branch', style: itemStyle),
                      isExpanded: true,
                      items: [
                        ...branches.map((b) {
                          final id = SettingsController.toIntOrNull(b['br_id']);
                          final name = b['br_name']?.toString() ?? '—';
                          return DropdownMenuItem<int?>(
                            value: id,
                            child: Text(name, style: itemStyle),
                          );
                        }),
                      ],
                      onChanged: (val) => selectedBranchId.value = val,
                    ),
                  );
                }),
              ),
            ]),
            const SizedBox(height: 16),
            // ── Service Type + Care Type + Service Gender ──────────────────
            _row([
              _labeled(
                'Service Type',
                Obx(() => _dropdownBox(
                      DropdownButton<int>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
                        value: selectedServiceType.value,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                              value: 1, child: Text('Normal', style: itemStyle)),
                          DropdownMenuItem(
                              value: 2,
                              child: Text('Premium', style: itemStyle)),
                        ],
                        onChanged: (v) => selectedServiceType.value = v ?? 1,
                      ),
                    )),
              ),
              _labeled(
                'Care Type',
                Obx(() => _dropdownBox(
                      DropdownButton<String>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
                        value: selectedCareType.value,
                        isExpanded: true,
                        items: careTypes
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c, style: itemStyle)))
                            .toList(),
                        onChanged: (v) =>
                            selectedCareType.value = v ?? careTypes.first,
                      ),
                    )),
              ),
              _labeled(
                'Service Gender',
                Obx(() => _dropdownBox(
                      DropdownButton<String>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
                        value: selectedGender.value,
                        isExpanded: true,
                        items: const ['Any', 'Male', 'Female']
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text(g, style: itemStyle)))
                            .toList(),
                        onChanged: (v) => selectedGender.value = v ?? 'Any',
                      ),
                    )),
              ),
            ]),
            const SizedBox(height: 20),
            Divider(height: 1, color: AppColor.borderSubtle),
            const SizedBox(height: 16),
            Text(
              'Pricing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'A new rate needs an effective-from date.',
              style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
            ),
            const SizedBox(height: 12),
            // ── Rate + Market Rate + Effective From ──────────────────────────
            _row([
              _labeled(
                'Rate (₹/day)',
                TextField(
                  controller: rateCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'e.g. 1200'),
                ),
              ),
              _labeled(
                'Market Rate (₹)',
                TextField(
                  controller: marketRateCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'e.g. 1500'),
                ),
              ),
              // ── Effective From Date ───────────────────────────────────────
              Obx(() {
                final date = selectedEffectiveDate.value;
                final label = date != null
                    ? DateFormat('dd MMM yyyy').format(date)
                    : 'Select date';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text('Effective From', style: _labelStyle),
                        const SizedBox(width: 2),
                        Obx(() {
                          final rateText = rateObs.value;
                          final rateChanged =
                              rateText != originalRate && rateText.isNotEmpty;
                          return rateChanged
                              ? Text(' *',
                                  style: _labelStyle.copyWith(
                                      color: AppColor.danger))
                              : const SizedBox.shrink();
                        }),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) selectedEffectiveDate.value = picked;
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            suffixIcon: Icon(LucideIcons.calendar,
                                size: 16),
                          ),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: date != null
                                  ? AppColor.textPrimary
                                  : AppColor.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ]),
          ],
        ),
      );
    },
  );
}

TextStyle get _labelStyle => TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColor.textSecondary,
    );

/// Label above a field (13/w600, secondary text).
Widget _labeled(String label, Widget field) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: _labelStyle),
      const SizedBox(height: 6),
      field,
    ],
  );
}

/// Fields side by side in equal columns; stacked when the dialog is narrow.
Widget _row(List<Widget> children) {
  return LayoutBuilder(builder: (context, constraints) {
    if (constraints.maxWidth < 180.0 * children.length) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            children[i],
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: children[i]),
        ],
      ],
    );
  });
}

/// Dropdown inside a theme-styled input frame (same fill, border and radius
/// as the text fields).
Widget _dropdownBox(Widget child) {
  return InputDecorator(
    decoration: const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 14),
    ),
    child: DropdownButtonHideUnderline(child: child),
  );
}
