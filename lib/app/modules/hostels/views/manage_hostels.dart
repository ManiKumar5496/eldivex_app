import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/hostels_controller.dart';
import '../models/get_hostels_model.dart';
import 'create_hostel_screen.dart';
import 'hostel_detail_view.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ManageHostelsView extends StatelessWidget {
  const ManageHostelsView({super.key});

  void _openCreate(HostelsController c) {
    c.prepareCreate();
    Get.to(() => const CreateHostelScreen());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final c = Get.isRegistered<HostelsController>()
        ? Get.find<HostelsController>()
        : Get.put(HostelsController());
    final pad = SizeConfig.pagePadding;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: RefreshIndicator(
        onRefresh: c.fetchHostels,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: pad.copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      title: 'Manage Hostels',
                      subtitle:
                          'Caregiver accommodation, daily rates and occupancy',
                      actions: [
                        ElevatedButton.icon(
                          onPressed: () => _openCreate(c),
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text('New Hostel'),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.isMobile ? 16 : 24),
                    _stats(c),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: AppSearchField(
                          onChanged: (v) => c.searchQuery.value = v,
                          hint: 'Search by name or city…',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: pad.copyWith(top: 0),
              sliver: Obx(() {
                if (c.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (c.loadError.value.isNotEmpty && c.allHostels.isEmpty) {
                  return SliverToBoxAdapter(
                    child: AppCard(
                      child: AppEmptyState(
                        icon: LucideIcons.circleAlert,
                        tone: AppTone.danger,
                        title: 'Could not load hostels',
                        message: c.loadError.value,
                        actionLabel: 'Retry',
                        actionIcon: LucideIcons.refreshCw,
                        onAction: c.fetchHostels,
                      ),
                    ),
                  );
                }
                final list = c.filteredHostels;
                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: AppCard(
                      child: AppEmptyState(
                        icon: LucideIcons.building2,
                        title: c.allHostels.isEmpty
                            ? 'No hostels yet. Add one to get started.'
                            : 'No hostels match your search',
                        actionLabel:
                            c.allHostels.isEmpty ? 'New Hostel' : null,
                        actionIcon: LucideIcons.plus,
                        onAction:
                            c.allHostels.isEmpty ? () => _openCreate(c) : null,
                      ),
                    ),
                  );
                }
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 176,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _HostelCard(hostel: list[i], c: c),
                    childCount: list.length,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Hostel counts. Hidden while the first load is running or failed.
  Widget _stats(HostelsController c) {
    return Obx(() {
      final all = c.allHostels;
      if (all.isEmpty) return const SizedBox.shrink();
      final active = all.where((h) => h.status == 1).length;
      final beds = all.fold<int>(0, (sum, h) => sum + (h.capacity ?? 0));
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: AppResponsiveGrid(
          minItemWidth: SizeConfig.isMobile ? 140 : 200,
          maxColumns: 4,
          spacing: SizeConfig.isMobile ? 12 : 16,
          children: [
            AppStatCard(
              label: 'Total Hostels',
              value: '${all.length}',
              icon: LucideIcons.building2,
              tone: AppTone.primary,
            ),
            AppStatCard(
              label: 'Active',
              value: '$active',
              icon: LucideIcons.circleCheck,
              tone: AppTone.success,
            ),
            AppStatCard(
              label: 'Inactive',
              value: '${all.length - active}',
              icon: LucideIcons.circlePause,
              tone: AppTone.neutral,
            ),
            AppStatCard(
              label: 'Total Beds',
              value: '$beds',
              icon: LucideIcons.bed,
              tone: AppTone.info,
            ),
          ],
        ),
      );
    });
  }
}

class _HostelCard extends StatelessWidget {
  final GetHostelsModel hostel;
  final HostelsController c;
  const _HostelCard({required this.hostel, required this.c});

  @override
  Widget build(BuildContext context) {
    final genderLabel = HostelsController.normalizeGenderLabel(hostel.gender);
    final isMale = genderLabel == 'Male';
    final genderTone = isMale ? AppTone.info : AppTone.violet;
    return AppCard(
      expandChild: true,
      padding: const EdgeInsets.all(16),
      onTap: () {
        c.openHostel(hostel);
        Get.to(() => const HostelDetailView());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconTile(
                icon: LucideIcons.building2,
                tone: hostel.status == 1 ? AppTone.primary : AppTone.neutral,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hostel.hostelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin,
                            size: 14, color: AppColor.textTertiary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                              hostel.location.isEmpty ? '—' : hostel.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColor.textTertiary, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Hostel actions',
                icon: Icon(LucideIcons.ellipsisVertical,
                    size: 20, color: AppColor.textTertiary),
                onSelected: (v) {
                  if (v == 'edit') {
                    c.prepareEdit(hostel);
                    Get.to(() => const CreateHostelScreen());
                  } else if (v == 'toggle') {
                    _confirmToggle(hostel);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(hostel.status == 1 ? 'Deactivate' : 'Activate'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppStatusBadge(label: genderLabel, tone: genderTone, showDot: false),
              if (hostel.status != 1)
                const AppStatusBadge(label: 'Inactive', tone: AppTone.danger),
            ],
          ),
          const Spacer(),
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat('₹${hostel.ratePerDay.toStringAsFixed(0)}/day', LucideIcons.banknote),
              const SizedBox(width: 16),
              _stat(hostel.capacity == null ? 'No cap' : '${hostel.capacity} beds',
                  LucideIcons.bed),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmToggle(GetHostelsModel h) {
    final deactivate = h.status == 1;
    Get.dialog(
      AppDialog(
        title: deactivate ? 'Deactivate hostel?' : 'Activate hostel?',
        icon: deactivate ? LucideIcons.circlePause : LucideIcons.circlePlay,
        tone: deactivate ? AppTone.danger : AppTone.primary,
        maxWidth: 440,
        // Same guard as Cancel: no closing while the request runs.
        onClose: () {
          if (c.togglingHostelId.value == null) Get.back();
        },
        actions: [
          Obx(() => OutlinedButton(
                onPressed: c.togglingHostelId.value != null ? null : Get.back,
                child: const Text('Cancel'),
              )),
          Obx(() {
            final busy = c.togglingHostelId.value != null;
            return ElevatedButton(
              style: deactivate ? AppButtonStyles.danger : null,
              onPressed: busy
                  ? null
                  : () async {
                      final ok = await c.toggleStatus(h);
                      if (ok && (Get.isDialogOpen ?? false)) Get.back();
                    },
              child: busy
                  ? SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.textTertiary))
                  : Text(deactivate ? 'Deactivate' : 'Activate'),
            );
          }),
        ],
        child: Text(
          deactivate
              ? '${h.hostelName} will no longer accept new caregivers or appear in settlements.'
              : '${h.hostelName} will accept caregivers again.',
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColor.textSecondary),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _stat(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColor.textTertiary),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
