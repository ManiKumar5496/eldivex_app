import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/settings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
    return AppPageHeader(
      title: 'Service Categories',
      subtitle: 'Define the service categories your organisation offers.',
      onBack: () => Get.back(),
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showCategoryDialog(context, controller),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add Category'),
        ),
      ],
    );
  }
}

// ── Categories List ─────────────────────────────────────────────────────────

const double _kStatusCol = 96;
const double _kActionCol = 64;

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
        return AppCard(
          child: AppEmptyState(
            icon: LucideIcons.shapes,
            tone: AppTone.primary,
            title: 'No categories yet',
            message:
                'Click "Add Category" to create your first product category.',
            actionLabel: 'Add Category',
            actionIcon: LucideIcons.plus,
            onAction: () => _showCategoryDialog(context, controller),
          ),
        );
      }

      final count = controller.filteredServiceCategories.length;
      final total = controller.serviceCategoriesList.length;
      final headerStyle = TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColor.textTertiary,
      );

      return AppCard(
        expandChild: true,
        padding: EdgeInsets.zero,
        title: 'All categories',
        subtitle: '$count of $total ${total == 1 ? 'category' : 'categories'}',
        actions: [
          AppSearchField(
            hint: 'Search categories by name...',
            onChanged: controller.searchServiceCategories,
            width: MediaQuery.sizeOf(context).width < 600 ? null : 300,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: AppColor.surfaceMuted,
                border:
                    Border(bottom: BorderSide(color: AppColor.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('Category Name', style: headerStyle)),
                  SizedBox(
                      width: _kStatusCol,
                      child: Text('Status', style: headerStyle)),
                  SizedBox(
                    width: _kActionCol,
                    child: Text('Actions',
                        style: headerStyle, textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
            Expanded(
              child: count == 0
                  ? const AppEmptyState(
                      icon: LucideIcons.searchX,
                      title: 'No matching categories',
                      message: 'Try a different name.',
                      compact: true,
                    )
                  : ListView.separated(
                      itemCount: controller.filteredServiceCategories.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: AppColor.borderSubtle),
                      itemBuilder: (context, index) {
                        final cat = controller.filteredServiceCategories[index];
                        return _CategoryRow(
                          category: cat,
                          controller: controller,
                          onEdit: () =>
                              _showCategoryDialog(context, controller, cat),
                        );
                      },
                    ),
            ),
          ],
        ),
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

    return _HoverRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  AppIconTile(
                    icon: LucideIcons.shapes,
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
            SizedBox(
              width: _kStatusCol,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message:
                      isActive ? 'Deactivate category' : 'Activate category',
                  child: Switch(
                    value: isActive,
                    onChanged: (_) =>
                        controller.toggleServiceCategoryStatus(id, status),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _kActionCol,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Edit category',
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
      return AppDialog(
        title: isEdit ? 'Edit Category' : 'Add Category',
        subtitle: 'Services are grouped under these categories.',
        icon: LucideIcons.shapes,
        maxWidth: 460,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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
            Text(
              'Category Name *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: 'e.g. Caregiving, Nursing, Baby Care'),
            ),
          ],
        ),
      );
    },
  );
}
