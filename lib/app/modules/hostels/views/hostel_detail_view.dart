import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../core/values/size_configue.dart';
import '../../register_cg/models/get_cg_details_model.dart';
import '../controllers/hostels_controller.dart';
import '../models/hostel_stay_model.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HostelDetailView extends StatelessWidget {
  const HostelDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final c = Get.find<HostelsController>();

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Obx(() {
        final h = c.selectedHostel.value;
        if (h == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          padding: SizeConfig.pagePadding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: h.hostelName.isEmpty ? 'Hostel' : h.hostelName,
                    breadcrumbs: const ['Hostels', 'Hostel details'],
                    // Same as the AppBar's automatic back button.
                    onBack: () => Navigator.of(context).maybePop(),
                    titleTrailing: h.status == 1
                        ? const AppStatusBadge(label: 'Active', tone: AppTone.success)
                        : const AppStatusBadge(label: 'Inactive', tone: AppTone.danger),
                    actions: [
                      if (h.status == 1)
                        ElevatedButton.icon(
                          onPressed: () => _showAssignDialog(c),
                          icon: const Icon(LucideIcons.userPlus, size: 18),
                          label: const Text('Assign CG'),
                        ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.isMobile ? 16 : 24),
                  _infoCard(c),
                  const SizedBox(height: 20),
                  AppCard(
                    title: 'Occupants',
                    icon: LucideIcons.users,
                    padding: EdgeInsets.zero,
                    child: _occupants(c, h.id),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Read inside the page `Obx` (stays, loading and error flags).
  Widget _occupants(HostelsController c, int hostelId) {
    if (c.loadingStays.value) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (c.staysError.value.isNotEmpty) {
      return AppEmptyState(
        compact: true,
        icon: LucideIcons.circleAlert,
        tone: AppTone.danger,
        title: 'Could not load occupants',
        message: c.staysError.value,
        actionLabel: 'Retry',
        actionIcon: LucideIcons.refreshCw,
        onAction: () => c.fetchStays(hostelId),
      );
    }
    if (c.stays.isEmpty) {
      return const AppEmptyState(
        compact: true,
        icon: LucideIcons.bed,
        title: 'No caregivers assigned yet.',
      );
    }
    final stays = c.stays.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stays.length; i++) ...[
          if (i > 0) Divider(height: 1, color: AppColor.borderSubtle),
          _stayTile(c, stays[i]),
        ],
      ],
    );
  }

  Widget _infoCard(HostelsController c) {
    final h = c.selectedHostel.value!;
    final hasLocation = h.location.isNotEmpty;
    final hasContact = (h.contactPersonName ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppResponsiveGrid(
          minItemWidth: SizeConfig.isMobile ? 140 : 200,
          maxColumns: 4,
          spacing: SizeConfig.isMobile ? 12 : 16,
          children: [
            AppStatCard(
              label: 'Rate / day',
              value: '₹${h.ratePerDay.toStringAsFixed(0)}',
              icon: LucideIcons.banknote,
              tone: AppTone.primary,
            ),
            AppStatCard(
              label: 'Capacity',
              value: h.capacity?.toString() ?? '—',
              icon: LucideIcons.bed,
              tone: AppTone.info,
            ),
            Obx(() => AppStatCard(
                  label: 'Occupied',
                  value: '${c.activeOccupancy}'
                      '${h.capacity != null ? ' / ${h.capacity}' : ''}',
                  icon: LucideIcons.users,
                  tone: AppTone.success,
                )),
            AppStatCard(
              label: 'Gender',
              value: HostelsController.normalizeGenderLabel(h.gender),
              icon: LucideIcons.venusAndMars,
              tone: AppTone.violet,
            ),
          ],
        ),
        if (hasLocation || hasContact) ...[
          const SizedBox(height: 20),
          AppCard(
            title: 'Details',
            child: Wrap(spacing: 40, runSpacing: 16, children: [
              if (hasLocation)
                AppInfoRow(
                    label: 'Location',
                    value: h.location,
                    icon: LucideIcons.mapPin),
              if (hasContact)
                AppInfoRow(
                    label: 'Contact',
                    value: '${h.contactPersonName} ${h.contactPhone ?? ''}',
                    icon: LucideIcons.phone),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _stayTile(HostelsController c, HostelStayModel s) {
    final closed = s.status != 'active';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AppAvatar(name: s.hpName.isEmpty ? 'CG' : s.hpName, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.hpName.isEmpty ? 'CG #${s.hpId}' : s.hpName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  'In: ${s.checkInDate}'
                  '${s.isOpen ? '  •  Ongoing' : '  •  Out: ${s.checkOutDate}'}'
                  '  •  ${s.nights} nights',
                  style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${s.charge.toStringAsFixed(0)}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          if (closed)
            const AppStatusBadge(label: 'Closed', tone: AppTone.neutral)
          else
            OutlinedButton(
              style: AppButtonStyles.compact.merge(AppButtonStyles.dangerOutlined),
              onPressed: () => _showCloseDialog(c, s),
              child: const Text('Check out'),
            ),
        ],
      ),
    );
  }

  // ── Assign CG dialog ─────────────────────────────────────────────────────────
  void _showAssignDialog(HostelsController c) {
    final h = c.selectedHostel.value!;
    final genderLabel = HostelsController.normalizeGenderLabel(h.gender);
    final Rxn<int> selectedCgId = Rxn<int>();
    // Loads the HP list if empty and refreshes who already has an open stay.
    c.loadCaregiverPicker();
    final checkInCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    Get.dialog(
      AppDialog(
        title: 'Assign CG to ${h.hostelName}',
        subtitle:
            'Only $genderLabel caregivers without an ongoing hostel stay are listed.',
        icon: LucideIcons.userPlus,
        maxWidth: 480,
        actions: [
          OutlinedButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: (c.isSubmitting.value || selectedCgId.value == null)
                    ? null
                    : () async {
                        final ok = await c.assignCg(
                          hostelId: h.id,
                          hpId: selectedCgId.value!,
                          checkInDate: checkInCtrl.text,
                        );
                        if (ok) Get.back();
                      },
                child: const Text('Assign'),
              )),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (c.loadingCgs.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final eligible = c.eligibleCgs(h.gender);
              if (eligible.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.dangerSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text('No $genderLabel caregivers available.',
                      style: TextStyle(fontSize: 13.5, color: AppColor.danger)),
                );
              }
              final current = eligible.any((cg) => cg.hpRegId == selectedCgId.value)
                  ? selectedCgId.value
                  : null;
              return DropdownButtonFormField<int>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
                    initialValue: current,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Caregiver'),
                    items: eligible
                        .map((GetCgDetails cg) => DropdownMenuItem<int>(
                              value: cg.hpRegId,
                              child: Text(
                                  '${cg.hpRegFirstName} ${cg.hpRegLastName}'.trim(),
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => selectedCgId.value = v,
                  );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: checkInCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Check-in date',
                  suffixIcon: Icon(LucideIcons.calendar, size: 18)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  checkInCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Close stay dialog ─────────────────────────────────────────────────────────
  void _showCloseDialog(HostelsController c, HostelStayModel s) {
    final outCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    Get.dialog(
      AppDialog(
        title: 'Check out ${s.hpName.isEmpty ? 'caregiver' : s.hpName}?',
        icon: LucideIcons.logOut,
        tone: AppTone.warning,
        maxWidth: 420,
        // Same guard as Cancel: no closing while the request runs.
        onClose: () {
          if (!c.isSubmitting.value) Get.back();
        },
        actions: [
          Obx(() => OutlinedButton(
                onPressed: c.isSubmitting.value ? null : Get.back,
                child: const Text('Cancel'),
              )),
          Obx(() => ElevatedButton(
                // Close the dialog only after the server confirms.
                onPressed: c.isSubmitting.value
                    ? null
                    : () async {
                        final ok = await c.closeStay(s, outCtrl.text);
                        if (ok && (Get.isDialogOpen ?? false)) Get.back();
                      },
                child: c.isSubmitting.value
                    ? SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.textTertiary))
                    : const Text('Confirm check-out'),
              )),
        ],
        child: TextField(
          controller: outCtrl,
          readOnly: true,
          decoration: const InputDecoration(
              labelText: 'Check-out date',
              suffixIcon: Icon(LucideIcons.calendar, size: 18)),
          onTap: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime.tryParse(s.checkInDate) ?? DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              outCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
            }
          },
        ),
      ),
    );
  }
}
