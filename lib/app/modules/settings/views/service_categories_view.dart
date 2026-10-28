import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/settings_controller.dart';

/// Per-organisation service catalogue. Each tenant defines its own product
/// categories (e.g. Caregiving, Nursing, Baby Care) — they are never shared
/// across orgs. Individual services are then grouped under these categories
/// in Services Management.
class ServiceCategoriesView extends StatefulWidget {
  const ServiceCategoriesView({super.key});

  @override
  State<ServiceCategoriesView> createState() => _ServiceCategoriesViewState();
}

class _ServiceCategoriesViewState extends State<ServiceCategoriesView> {
  SettingsController get controller => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    // Fetch once per visit (not from build, which re-runs on every rebuild).
    if (!controller.categoriesLoaded) controller.fetchServiceCategories();
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
              Expanded(child: _CategoriesList(controller: controller)),
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
              Text('Service Categories', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Define the service categories your organisation offers.',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showCategoryDialog(context, controller),
          icon: Icon(Icons.add, size: 18, color: AppColor.buttonTextWhite),
          label: Text('Add Category', style: AppTextStyles.regular14white),
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

// ── Categories List ─────────────────────────────────────────────────────────

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCategoriesLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.serviceCategoriesList.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined, size: 56, color: AppColor.lightGrey),
              const SizedBox(height: 16),
              Text('No categories yet', style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text(
                'Click "Add Category" to create your first product category.',
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
              onChanged: controller.searchServiceCategories,
              decoration: const InputDecoration(
                hintText: 'Search categories by name...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Category Name',
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
              itemCount: controller.filteredServiceCategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cat = controller.filteredServiceCategories[index];
                return _CategoryRow(
                  category: cat,
                  controller: controller,
                  onEdit: () => _showCategoryDialog(context, controller, cat),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ── Category Row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.controller,
    required this.onEdit,
  });
  final Map<String, dynamic> category;
  final SettingsController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final id = SettingsController.toInt(category['id'], fallback: 0);
    final name = category['cat_name']?.toString() ?? '—';
    final status = SettingsController.toInt(category['status'], fallback: 0);
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
            child: Text(name,
                style: AppTextStyles.regular16
                    .copyWith(fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            width: 80,
            child: Switch(
              value: isActive,
              activeThumbColor: AppColor.cAppPrimaryColor,
              activeTrackColor: AppColor.cAppPrimaryColor.withValues(alpha: 0.3),
              onChanged: (_) =>
                  controller.toggleServiceCategoryStatus(id, status),
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

void _showCategoryDialog(
  BuildContext context,
  SettingsController controller, [
  Map<String, dynamic>? existing,
]) {
  final isEdit = existing != null;
  final nameCtrl = TextEditingController(
      text: isEdit ? existing['cat_name']?.toString() : '');

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isEdit ? 'Edit Category' : 'Add Category',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category Name *', style: AppTextStyles.fieldsHeading16),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: _inputDecoration('e.g. Caregiving, Nursing, Baby Care'),
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
            final loading = controller.isCategorySubmitting.value;
            return ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      final ok = isEdit
                          ? await controller.updateServiceCategory(
                              id: SettingsController.toInt(existing['id']), name: name)
                          : await controller.createServiceCategory(name);
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
