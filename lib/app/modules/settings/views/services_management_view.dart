import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/settings_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

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
              Text('Services Management', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Add, edit, and activate or deactivate services offered.',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // ── Branch filter ─────────────────────────────────────────────────
        Obx(() {
          final branches = controller.branchesList;
          return Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.divColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                // Value must be one of the items or the dropdown asserts.
                value: branches.any((b) =>
                        SettingsController.toIntOrNull(b['br_id']) ==
                        controller.servicesFilterBranchId.value)
                    ? controller.servicesFilterBranchId.value
                    : null,
                hint: Text('All Branches', style: AppTextStyles.regular14Gre),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Branches', style: AppTextStyles.regular14Gre),
                  ),
                  ...branches.map((b) {
                    final id = SettingsController.toIntOrNull(b['br_id']);
                    final name = b['br_name']?.toString() ?? '—';
                    return DropdownMenuItem<int?>(
                      value: id,
                      child: Text(name, style: AppTextStyles.regular14Gre),
                    );
                  }),
                ],
                onChanged: (val) {
                  controller.servicesFilterBranchId.value = val;
                  controller.fetchServices();
                },
              ),
            ),
          );
        }),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showServiceDialog(context, controller),
          icon: Icon(Icons.add, size: 18, color: AppColor.buttonTextWhite),
          label: Text('Add Service', style: AppTextStyles.regular14white),
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

// ── Services List ─────────────────────────────────────────────────────────────

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
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.medical_services_outlined,
                  size: 56, color: AppColor.lightGrey),
              const SizedBox(height: 16),
              Text('No services yet', style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text(
                'Click "Add Service" to create your first service.',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.divColor),
            ),
            child: TextField(
              onChanged: controller.searchServices,
              decoration: const InputDecoration(
                hintText: 'Search services by name, description, category...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
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
                  flex: 3,
                  child: Text('Service Name',
                      style: AppTextStyles.regular14Gre
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Description',
                      style: AppTextStyles.regular14Gre
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Branch',
                      style: AppTextStyles.regular14Gre
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Category',
                      style: AppTextStyles.regular14Gre
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Rate',
                      style: AppTextStyles.regular14Gre
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('Status',
                      style: AppTextStyles.regular14Gre
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 80),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: controller.filteredServices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final svc = controller.filteredServices[index];
                return _ServiceRow(
                  service: svc,
                  controller: controller,
                  onEdit: () => _showServiceDialog(context, controller, svc),
                );
              },
            ),
          ),
        ],
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: AppTextStyles.regular16
                        .copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _Tag(
                      label: isPremium ? 'Premium' : 'Normal',
                      color: isPremium ? AppColor.cAppPrimaryColor : AppColor.lightGrey,
                    ),
                    if (careType.isNotEmpty)
                      _Tag(label: careType, color: AppColor.cAppPrimaryColor),
                    if (gender.isNotEmpty && gender != 'Any')
                      _Tag(label: gender, color: AppColor.lightGrey),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: AppTextStyles.regular14Gre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              branchName,
              style: AppTextStyles.regular14Gre,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              categoryName.isEmpty ? '—' : categoryName,
              style: AppTextStyles.regular14Gre,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: serviceRate.isEmpty
                ? Text('—', style: AppTextStyles.regular14Gre)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₹$serviceRate',
                          style: AppTextStyles.regular14Gre
                              .copyWith(fontWeight: FontWeight.w500)),
                      if (effectiveFrom.isNotEmpty)
                        Text('from $effectiveFrom',
                            style: AppTextStyles.regular14Gre
                                .copyWith(fontSize: 11)),
                    ],
                  ),
          ),
          SizedBox(
            width: 80,
            child: Switch(
              value: isActive,
              activeThumbColor: AppColor.cAppPrimaryColor,
              activeTrackColor: AppColor.cAppPrimaryColor.withValues(alpha: 0.3),
              onChanged: (_) =>
                  controller.toggleServiceStatus(id, status),
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

// ── Small pill tag (service type / gender) ─────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.regular14Gre.copyWith(fontSize: 11, color: color),
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
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isEdit ? 'Edit Service' : 'Add Service',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service Name *', style: AppTextStyles.fieldsHeading16),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: _inputDecoration('e.g. Elder Care'),
                ),
                const SizedBox(height: 16),
                Text('Description', style: AppTextStyles.fieldsHeading16),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: _inputDecoration('Brief description of the service'),
                ),
                const SizedBox(height: 16),
                Text('Category *', style: AppTextStyles.fieldsHeading16),
                const SizedBox(height: 6),
                Obx(() {
                  final dashboard = Get.find<DashboardController>();
                  final categories = dashboard.categoriesList;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColor.fieldColorGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.textFieldBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: selectedCategoryId.value,
                        hint: Text('Select category',
                            style: AppTextStyles.regular14Gre),
                        isExpanded: true,
                        items: [
                          ...categories.map((c) => DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text(c.catName,
                                    style: AppTextStyles.regular14Gre),
                              )),
                        ],
                        onChanged: (val) => selectedCategoryId.value = val,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text('Branch *', style: AppTextStyles.fieldsHeading16),
                const SizedBox(height: 6),
                Obx(() {
                  final branches = controller.branchesList;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColor.fieldColorGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.textFieldBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: branches.any((b) =>
                                SettingsController.toIntOrNull(b['br_id']) ==
                                selectedBranchId.value)
                            ? selectedBranchId.value
                            : null,
                        hint: Text('Select branch',
                            style: AppTextStyles.regular14Gre),
                        isExpanded: true,
                        items: [
                          ...branches.map((b) {
                            final id = SettingsController.toIntOrNull(b['br_id']);
                            final name = b['br_name']?.toString() ?? '—';
                            return DropdownMenuItem<int?>(
                              value: id,
                              child: Text(name, style: AppTextStyles.regular14Gre),
                            );
                          }),
                        ],
                        onChanged: (val) => selectedBranchId.value = val,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // ── Service Type + Care Type ──────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Service Type', style: AppTextStyles.fieldsHeading16),
                          const SizedBox(height: 6),
                          Obx(() => _dropdownBox(
                                DropdownButton<int>(
                                  value: selectedServiceType.value,
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(value: 1, child: Text('Normal', style: AppTextStyles.regular14Gre)),
                                    DropdownMenuItem(value: 2, child: Text('Premium', style: AppTextStyles.regular14Gre)),
                                  ],
                                  onChanged: (v) => selectedServiceType.value = v ?? 1,
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Care Type', style: AppTextStyles.fieldsHeading16),
                          const SizedBox(height: 6),
                          Obx(() => _dropdownBox(
                                DropdownButton<String>(
                                  value: selectedCareType.value,
                                  isExpanded: true,
                                  items: careTypes
                                      .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c, style: AppTextStyles.regular14Gre)))
                                      .toList(),
                                  onChanged: (v) => selectedCareType.value = v ?? careTypes.first,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Service Gender ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Service Gender', style: AppTextStyles.fieldsHeading16),
                          const SizedBox(height: 6),
                          Obx(() => _dropdownBox(
                                DropdownButton<String>(
                                  value: selectedGender.value,
                                  isExpanded: true,
                                  items: const ['Any', 'Male', 'Female']
                                      .map((g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g, style: AppTextStyles.regular14Gre)))
                                      .toList(),
                                  onChanged: (v) => selectedGender.value = v ?? 'Any',
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Rate + Market Rate ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rate (₹/day)', style: AppTextStyles.fieldsHeading16),
                          const SizedBox(height: 6),
                          TextField(
                            controller: rateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('e.g. 1200'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Market Rate (₹)', style: AppTextStyles.fieldsHeading16),
                          const SizedBox(height: 6),
                          TextField(
                            controller: marketRateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('e.g. 1500'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ── Effective From Date ───────────────────────────────
                    Expanded(
                      child: Obx(() {
                        final date = selectedEffectiveDate.value;
                        final label = date != null
                            ? DateFormat('dd MMM yyyy').format(date)
                            : 'Select date';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Effective From', style: AppTextStyles.fieldsHeading16),
                                const SizedBox(width: 4),
                                Obx(() {
                                  final rateText = rateObs.value;
                                  final rateChanged = rateText != originalRate && rateText.isNotEmpty;
                                  return rateChanged
                                      ? Text(' *',
                                          style: AppTextStyles.fieldsHeading16
                                              .copyWith(color: Colors.red))
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                decoration: BoxDecoration(
                                  color: AppColor.fieldColorGrey,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColor.textFieldBorderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(label,
                                          style: date != null
                                              ? AppTextStyles.regular14Gre
                                              : AppTextStyles.regular14Gre
                                                  .copyWith(color: AppColor.fontColorGrey)),
                                    ),
                                    Icon(Icons.calendar_today_outlined,
                                        size: 16, color: AppColor.lightGrey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTextStyles.regular16Gre),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.buttonTextWhite),
                    )
                  : Text(isEdit ? 'Save Changes' : 'Create',
                      style: AppTextStyles.regular16white),
            );
          }),
        ],
      );
    },
  );
}

Widget _dropdownBox(Widget child) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColor.fieldColorGrey,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColor.textFieldBorderColor),
    ),
    child: DropdownButtonHideUnderline(child: child),
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
