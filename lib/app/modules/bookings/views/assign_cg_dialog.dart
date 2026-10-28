import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../register_cg/controllers/register_cg_controller.dart';
import '../../register_cg/models/get_cg_details_model.dart';
import '../models/get_bookings_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart'; // Phase 4.4 — branch list
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/bookings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class AssignCgDialog extends StatefulWidget {
  final int bookingId;
  const AssignCgDialog({super.key, required this.bookingId});

  @override
  State<AssignCgDialog> createState() => _AssignCgDialogState();
}

class _AssignCgDialogState extends State<AssignCgDialog> {
  late final RegisterCgController cgController;
  late final BookingsController bookingController;

  /// Local gender filter (the controller's hpGender belongs to the HP form).
  final RxString genderFilter = ''.obs;

  /// Local, view-only text search over the loaded lists (name, phone, HP ID).
  final RxString searchQuery = ''.obs;

  int get bookingId => widget.bookingId;

  /// Below this list width the tables switch to stacked cards.
  static const double _cardBreakpoint = 720;

  @override
  void initState() {
    super.initState();
    cgController = Get.isRegistered<RegisterCgController>()
        ? Get.find<RegisterCgController>()
        : Get.put(RegisterCgController());
    bookingController = Get.isRegistered<BookingsController>()
        ? Get.find<BookingsController>()
        : Get.put(BookingsController());
    // The HP list is loaded once; filters below apply to it in memory.
    if (cgController.getAllCgData.value.isEmpty &&
        !cgController.getAllCGLoading.value) {
      cgController.getAllCgFromApi();
    }
    if (cgController.availableLanguages.isEmpty) cgController.fetchLanguages();
  }

  static int _int(dynamic v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}'.trim()) ?? 0;

  static String _str(dynamic v, [String fallback = '—']) {
    final s = '${v ?? ''}'.trim();
    return s.isEmpty || s == 'NA' || s == 'null' ? fallback : s;
  }

  String _langName(Map l) => _str(l['language_name'] ?? l['name'], '');

  bool _matchesFilters(GetCgDetails cg) {
    final branchId = cgController.filterAssignBranchId.value;
    if (branchId != null && cg.hpRegBranchId != branchId) return false;

    final gender = genderFilter.value.toLowerCase();
    if (gender.isNotEmpty) {
      final g = cg.hpRegGender.trim().toLowerCase();
      final code = gender == 'male' ? '1' : '2';
      if (g != gender && g != code) return false;
    }

    final lang = cgController.filterAssignLanguage.value.trim().toLowerCase();
    if (lang.isNotEmpty) {
      // HP languages are stored as ids; accept names for older rows.
      final match = cgController.availableLanguages
          .firstWhereOrNull((l) => _langName(l).toLowerCase() == lang);
      final id = match == null ? '' : '${match['id']}';
      final hpLangs = cg.hpRegLanguages
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .toSet();
      if (!hpLangs.contains(lang) && !(id.isNotEmpty && hpLangs.contains(id))) {
        return false;
      }
    }
    return true;
  }

  /// View-only text search. Narrows the visible rows; selection and assign
  /// logic are unchanged.
  bool _matchesSearch(GetCgDetails cg) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return true;
    final name = '${cg.hpRegFirstName} ${cg.hpRegLastName}'.toLowerCase();
    final hpId = 'hp-${cg.hpRegId.toString().padLeft(3, '0')}';
    return name.contains(q) ||
        cg.hpRegPhoneNumber.toLowerCase().contains(q) ||
        hpId.contains(q) ||
        '${cg.hpRegId}'.contains(q);
  }

  bool _aiMatchesSearch(Map<String, dynamic> hp) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return true;
    final hpId = _int(hp['hp_reg_id']);
    final name = _str(hp['name'], '').toLowerCase();
    return name.contains(q) ||
        'hp-${hpId.toString().padLeft(3, '0')}'.contains(q) ||
        '$hpId'.contains(q);
  }

  void _clearFilters() {
    cgController.filterAssignBranchId.value = null;
    cgController.filterAssignLanguage.value = '';
    genderFilter.value = '';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final booking = bookingController.bookingsByBookingId.value.firstOrNull;
    if (booking == null) {
      return AppDialog(
        title: 'Assign Health Professional',
        icon: LucideIcons.userPlus,
        maxWidth: 440,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
        child: Text(
          'Booking details are still loading. Please try again.',
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColor.textSecondary),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final narrow = size.width < 600;
    final hPad = narrow ? 16.0 : 24.0;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: math.min(size.width * 0.92, 1240.0),
        height: size.height * 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(booking),
            Divider(height: 1, color: AppColor.borderSubtle),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height * (narrow ? 0.34 : 0.42),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBookingDetails(booking),
                    const SizedBox(height: 16),
                    _buildFiltersCard(),
                  ],
                ),
              ),
            ),
            _buildTableSection(hPad),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(GetBookingsModel booking) {
    final narrow = SizeConfig.isMobile;
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 18 : 24, 18, 12, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppIconTile(icon: LucideIcons.userPlus, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Assign Health Professional',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Booking ID: #${booking.id}',
                  style: TextStyle(fontSize: 13.5, color: AppColor.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Get.back(),
            icon: Icon(
              LucideIcons.x,
              size: 20,
              color: AppColor.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOOKING DETAILS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBookingDetails(GetBookingsModel booking) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeading(LucideIcons.info, 'Booking Details'),
          const SizedBox(height: 14),
          AppResponsiveGrid(
            minItemWidth: 170,
            maxColumns: 5,
            spacing: 16,
            children: [
              _infoCell(
                icon: LucideIcons.stethoscope,
                label: 'Service',
                value: booking.serviceName ?? 'Nursing',
              ),
              _infoCell(
                icon: LucideIcons.building,
                label: 'City',
                value: (booking.branchCity ?? '').isNotEmpty
                    ? booking.branchCity!
                    : (booking.city ?? '-'),
              ),
              _infoCell(
                icon: LucideIcons.venusAndMars,
                label: 'Patient Gender',
                value: _genderLabel(booking.patientGender),
              ),
              _infoCell(
                icon: LucideIcons.scale,
                label: 'Patient Weight',
                value: (booking.patientWeight ?? '').isNotEmpty
                    ? '${booking.patientWeight} kg'
                    : '-',
              ),
              _infoCell(
                icon: LucideIcons.shapes,
                label: 'Service Type',
                value: booking.serviceTypeName ?? booking.serviceName ?? '-',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _genderLabel(int? gender) {
    switch (gender) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      case 3:
        return 'Other';
      default:
        return '-';
    }
  }

  Widget _infoCell({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconTile(icon: icon, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTERS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _filterLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColor.textTertiary,
          ),
        ),
      );

  BoxDecoration get _selectDecoration => BoxDecoration(
        color: AppColor.whiteColor,
        border: Border.all(color: AppColor.borderStrong),
        borderRadius: BorderRadius.circular(AppRadius.md),
      );

  Widget _buildFiltersCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeading(LucideIcons.slidersHorizontal, 'Filter Health Professionals'),
        const SizedBox(height: 12),
        Obx(
          () {
            final dashCtrl  = Get.find<DashboardController>();
            final languages = cgController.availableLanguages;
            final hintStyle = TextStyle(fontSize: 14, color: AppColor.textTertiary);
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                // ── Phase 4.4: City / Branch filter ──────────────────
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterLabel('City / Branch'),
                      Container(
                        height: 44,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _selectDecoration,
                        child: DropdownButton<int?>(
                          value: cgController.filterAssignBranchId.value,
                          hint: Text('All', style: hintStyle),
                          underline: const SizedBox.shrink(),
                          isDense: true,
                          isExpanded: true,
                          icon: Icon(LucideIcons.chevronDown,
                              size: 18, color: AppColor.textTertiary),
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                          dropdownColor: AppColor.whiteColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          items: [
                            const DropdownMenuItem<int?>(
                                value: null, child: Text('All Branches')),
                            ...dashCtrl.getAllBranches.map((b) =>
                                DropdownMenuItem<int?>(
                                    value: b.brId,
                                    child: Text(b.brName,
                                        overflow: TextOverflow.ellipsis))),
                          ],
                          onChanged: (v) =>
                              cgController.filterAssignBranchId.value = v,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Phase 4.4: Language filter ────────────────────────
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterLabel('Language'),
                      Container(
                        height: 44,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _selectDecoration,
                        child: DropdownButton<String>(
                          value: cgController.filterAssignLanguage.value.isEmpty
                              ? null
                              : cgController.filterAssignLanguage.value,
                          hint: Text('All', style: hintStyle),
                          underline: const SizedBox.shrink(),
                          isDense: true,
                          isExpanded: true,
                          icon: Icon(LucideIcons.chevronDown,
                              size: 18, color: AppColor.textTertiary),
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                          dropdownColor: AppColor.whiteColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          items: [
                            const DropdownMenuItem<String>(
                                value: null, child: Text('All Languages')),
                            ...languages
                                .map(_langName)
                                .where((n) => n.isNotEmpty)
                                .toSet()
                                .map((name) {
                              return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name,
                                      overflow: TextOverflow.ellipsis));
                            }),
                          ],
                          onChanged: (v) =>
                              cgController.filterAssignLanguage.value = v ?? '',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 170,
                  child: _buildDropdown(
                    label: 'Gender',
                    value: genderFilter.value.isEmpty
                        ? null
                        : genderFilter.value,
                    items: ['Male', 'Female'],
                    onChanged: (v) => genderFilter.value = v ?? '',
                  ),
                ),

                // Filters apply instantly to the loaded list.
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(LucideIcons.funnelX, size: 18),
                  label: const Text('Clear Filters'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _filterLabel(label),
        AppDropdownFormField<String>(
          hint: 'Select',
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e,
                style: TextStyle(fontSize: 14, color: AppColor.textPrimary)),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLE SECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTableSection(double hPad) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Phase 4.4: Tab bar (All HPs | AI Suggested) + search ─────
            _buildAssignTabBar(),
            // Tab content
            Expanded(
              child: Obx(() => cgController.assignDialogTab.value == 0
                  ? _buildCgTable()
                  : _buildAiSuggestedContent()),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phase 4.4: Tab bar ─────────────────────────────────────────────────────

  Widget _buildAssignTabBar() {
    final tabs = Obx(() {
      final tab = cgController.assignDialogTab.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _tabButton(
              label: 'All HPs',
              icon: LucideIcons.users,
              selected: tab == 0,
              onTap: () => cgController.assignDialogTab.value = 0,
              badge: () {
                // Show available count (exclude already-assigned & globally-active HPs)
                final assigned = bookingController.allBookingHpData.value
                    .map((hp) => hp.hpRegId ?? 0).toSet();
                final active = bookingController.globalActiveHpIds;
                final available = cgController.getAllCgData.value
                    .where((cg) =>
                        !assigned.contains(cg.hpRegId) &&
                        !active.contains(cg.hpRegId) &&
                        _matchesFilters(cg) &&
                        _matchesSearch(cg))
                    .length;
                return '$available';
              }(),
            ),
            _tabButton(
              label: 'AI Suggested',
              icon: LucideIcons.sparkles,
              selected: tab == 1,
              onTap: () {
                cgController.assignDialogTab.value = 1;
                if (cgController.matchedHPs.isEmpty &&
                    !cgController.matchedHPsLoading.value) {
                  cgController.fetchMatchedHPs(bookingId);
                }
              },
              badge: tab == 1 && cgController.matchedHPs.isNotEmpty
                  ? '${cgController.matchedHPs.length}'
                  : null,
              accentColor: AppColor.violet,
            ),
          ],
        ),
      );
    });

    final search = AppSearchField(
      hint: 'Search name, phone or HP ID…',
      onChanged: (v) => searchQuery.value = v,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: tabs),
              Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: search),
            ],
          );
        }
        return Row(
          children: [
            const SizedBox(width: 4),
            Expanded(child: tabs),
            const SizedBox(width: 12),
            SizedBox(width: 280, child: search),
            const SizedBox(width: 12),
          ],
        );
      }),
    );
  }

  Widget _tabButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColor.cPrimaryButtonColor;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18,
                color: selected ? color : AppColor.textTertiary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColor.textTertiary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.12)
                      : AppColor.neutralSoft,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : AppColor.textTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Phase 4.4: AI Suggested tab content ────────────────────────────────────

  Widget _buildAiSuggestedContent() {
    return Obx(() {
      if (cgController.matchedHPsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (cgController.matchedHPs.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.sparkles,
          tone: AppTone.violet,
          title: 'No AI matches yet',
          message: 'Tap "AI Suggested" to load scored matches',
        );
      }

      final rows = cgController.matchedHPs.where(_aiMatchesSearch).toList();
      if (rows.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.searchX,
          title: 'No matching health professionals',
          message: 'Try a different name or HP ID.',
        );
      }

      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < _cardBreakpoint) {
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColor.borderSubtle),
            itemBuilder: (_, i) => _buildAiHpCard(rows[i]),
          );
        }
        return Column(
          children: [
            // Column headers
            _headerRow([
              _tableHeader('Score',     flex: 2),
              _tableHeader('HP ID',     flex: 1),
              _tableHeader('Name',      flex: 3),
              _tableHeader('City',      flex: 2),
              _tableHeader('Languages', flex: 2),
              _tableHeader('Exp',       flex: 1),
              _tableHeader('Action',    flex: 1, alignEnd: true),
            ]),
            // Rows
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (_, i) => _buildAiHpRow(rows[i]),
              ),
            ),
          ],
        );
      });
    });
  }

  AppTone _scoreTone(int score) => score >= 70
      ? AppTone.success
      : score >= 40
          ? AppTone.warning
          : AppTone.danger;

  /// Score pill with a thin match bar.
  Widget _scoreIndicator(int score) {
    // Score colour: green ≥ 70, amber ≥ 40, red < 40
    final tone = _scoreTone(score);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: tone.soft,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Text(
            '$score%',
            style: TextStyle(
              color: tone.color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (score.clamp(0, 100)) / 100,
              minHeight: 4,
              backgroundColor: AppColor.neutralSoft,
              valueColor: AlwaysStoppedAnimation<Color>(tone.color),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildAiHpRow(Map<String, dynamic> hp) {
    final score = (num.tryParse('${hp['score_pct'] ?? 0}') ?? 0).round();
    final hpId  = _int(hp['hp_reg_id']);
    final name  = _str(hp['name'], 'HP #$hpId');
    final city  = _str(hp['city']);
    final langs = _str(hp['languages']);
    final expRaw = _str(hp['experience'], '');
    final exp   = expRaw.isEmpty ? '—' : '$expRaw yr';

    return _HoverRow(
      child: Row(
        children: [
          // Score badge
          Expanded(flex: 2, child: _scoreIndicator(score)),
          // HP ID
          _cell(
            1,
            Text(
              'HP-${hpId.toString().padLeft(3, '0')}',
              style: _idStyle,
            ),
          ),
          // Name
          _cell(
            3,
            Row(
              children: [
                AppAvatar(name: name, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(name, style: _nameStyle, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          // City
          _cell(2, Text(city, style: _mutedStyle, overflow: TextOverflow.ellipsis)),
          // Languages
          _cell(
            2,
            Text(langs,
                style: _mutedStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
          // Experience
          _cell(1, Text(exp, style: _mutedStyle)),
          // Assign button
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: hpId <= 0
                    ? null
                    : () => bookingController.assignCgToBooking(
                          bookingId: bookingId,
                          cgId: hpId,
                        ),
                style: AppButtonStyles.compact,
                child: const Text('Assign'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiHpCard(Map<String, dynamic> hp) {
    final score = (num.tryParse('${hp['score_pct'] ?? 0}') ?? 0).round();
    final hpId  = _int(hp['hp_reg_id']);
    final name  = _str(hp['name'], 'HP #$hpId');
    final city  = _str(hp['city']);
    final langs = _str(hp['languages']);
    final expRaw = _str(hp['experience'], '');
    final exp   = expRaw.isEmpty ? '—' : '$expRaw yr';

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(name: name, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: _nameStyle, overflow: TextOverflow.ellipsis),
                    Text('HP-${hpId.toString().padLeft(3, '0')}', style: _idStyle),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: hpId <= 0
                    ? null
                    : () => bookingController.assignCgToBooking(
                          bookingId: bookingId,
                          cgId: hpId,
                        ),
                style: AppButtonStyles.compact,
                child: const Text('Assign'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _scoreIndicator(score),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _metaText(LucideIcons.building, city),
              _metaText(LucideIcons.languages, langs),
              _metaText(LucideIcons.briefcase, exp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCgTable() {
    return Obx(() {
      if (cgController.getAllCGLoading.value ||
          bookingController.isGlobalActiveHpLoading.value) {
        return const ShimmerLoader.cardList(itemCount: 5);
      }

      // ── Two-layer filter ───────────────────────────────────────────
      // Layer A: HPs already on THIS booking (any lifecycle stage).
      //          Prevents shortlisting the same person twice.
      final Set<int> alreadyOnThisBooking = bookingController
          .allBookingHpData.value
          .map((hp) => hp.hpRegId ?? 0)
          .where((id) => id != 0)
          .toSet();

      // Layer B: HPs actively deployed on ANY other booking (status 4).
      //          Prevents double-booking a caregiver.
      final Set<int> activeElsewhere = bookingController.globalActiveHpIds;

      final availableCgs = cgController.getAllCgData.value
          .where((cg) =>
              !alreadyOnThisBooking.contains(cg.hpRegId) &&
              !activeElsewhere.contains(cg.hpRegId) &&
              _matchesFilters(cg) &&
              _matchesSearch(cg))
          .toList();
      // ───────────────────────────────────────────────────────────────

      if (availableCgs.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.users,
          title: 'No available health professionals',
          message: 'No unassigned HP matches the current filters',
        );
      }

      return Column(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < _cardBreakpoint) {
                return ListView.separated(
                  itemCount: availableCgs.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColor.borderSubtle),
                  itemBuilder: (_, index) => _buildCgCard(availableCgs[index]),
                );
              }
              return Column(
                children: [
                  // Table header row
                  _headerRow([
                    _tableHeader('HP ID',      flex: 1),
                    _tableHeader('Name',       flex: 3),
                    _tableHeader('Phone',      flex: 2),
                    _tableHeader('Gender',     flex: 1),
                    _tableHeader('Languages',  flex: 2),
                    _tableHeader('Experience', flex: 1),
                    _tableHeader('Action',     flex: 1, alignEnd: true),
                  ]),
                  // Table rows (filtered list only)
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableCgs.length,
                      itemBuilder: (_, index) => _buildCgRow(availableCgs[index]),
                    ),
                  ),
                ],
              );
            }),
          ),
          // Pagination footer
          _buildTableFooter(overrideCount: availableCgs.length),
        ],
      );
    });
  }

  Widget _headerRow(List<Widget> cells) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(children: cells),
    );
  }

  Widget _tableHeader(String title, {int flex = 1, bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          title,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: AppColor.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _cell(int flex, Widget child) => Expanded(
        flex: flex,
        child: Padding(padding: const EdgeInsets.only(right: 12), child: child),
      );

  TextStyle get _idStyle => TextStyle(
        color: AppColor.cPrimaryButtonColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      );

  TextStyle get _nameStyle => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColor.textPrimary,
      );

  TextStyle get _mutedStyle =>
      TextStyle(fontSize: 13.5, color: AppColor.textSecondary);

  Widget _metaText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColor.textTertiary),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _educationPill(GetCgDetails cg) {
    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColor.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        cg.hpRegEducation,
        style: TextStyle(
          color: AppColor.cPrimaryButtonColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCgRow(GetCgDetails cg) {
    final fullName = '${cg.hpRegFirstName} ${cg.hpRegLastName}';
    return _HoverRow(
      child: Row(
        children: [
          // HP ID
          _cell(
            1,
            Text(
              'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
              style: _idStyle,
            ),
          ),
          // Name
          _cell(
            3,
            Row(
              children: [
                AppAvatar(name: fullName, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fullName,
                        style: _nameStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cg.hpRegEducation.isNotEmpty && cg.hpRegEducation != 'NA')
                        _educationPill(cg),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Phone
          _cell(
            2,
            Row(
              children: [
                Icon(LucideIcons.phone,
                    size: 15, color: AppColor.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cg.hpRegPhoneNumber.isEmpty ? '-' : cg.hpRegPhoneNumber,
                    style: _mutedStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Gender
          _cell(
            1,
            Align(
              alignment: Alignment.centerLeft,
              child: _genderPill(cg.hpRegGender.isNotEmpty ? cg.hpRegGender : '-'),
            ),
          ),
          // Languages
          _cell(
            2,
            Text(
              cg.hpRegLanguages.isEmpty ? '-' : cg.hpRegLanguages,
              style: _mutedStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Experience
          _cell(
            1,
            Row(
              children: [
                Icon(LucideIcons.briefcase,
                    size: 15, color: AppColor.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${cg.hpRegExperience.isNotEmpty ? cg.hpRegExperience : '0'} yrs',
                    style: TextStyle(fontSize: 13.5, color: AppColor.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Assign button
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _assignCg(cg.hpRegId),
                style: AppButtonStyles.compact,
                child: const Text('Assign'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCgCard(GetCgDetails cg) {
    final fullName = '${cg.hpRegFirstName} ${cg.hpRegLastName}';
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(name: fullName, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName, style: _nameStyle, overflow: TextOverflow.ellipsis),
                    Text('HP-${cg.hpRegId.toString().padLeft(3, '0')}', style: _idStyle),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _assignCg(cg.hpRegId),
                style: AppButtonStyles.compact,
                child: const Text('Assign'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _genderPill(cg.hpRegGender.isNotEmpty ? cg.hpRegGender : '-'),
              if (cg.hpRegEducation.isNotEmpty && cg.hpRegEducation != 'NA')
                _educationPill(cg),
              _metaText(LucideIcons.phone,
                  cg.hpRegPhoneNumber.isEmpty ? '-' : cg.hpRegPhoneNumber),
              _metaText(LucideIcons.briefcase,
                  '${cg.hpRegExperience.isNotEmpty ? cg.hpRegExperience : '0'} yrs'),
              _metaText(LucideIcons.languages,
                  cg.hpRegLanguages.isEmpty ? '-' : cg.hpRegLanguages),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableFooter({int? overrideCount}) {
    // No Obx needed here — this method is always called from inside the
    // parent Obx in _buildCgTable (line 865), which already tracks
    // getAllCgData / allBookingHpData and passes a plain int as overrideCount.
    // Wrapping in a second Obx that receives a non-null overrideCount would
    // register zero reactive reads and trigger GetX's "improper use" warning.
    final count = overrideCount ?? cgController.getAllCgData.value.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(top: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $count health professionals',
            style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _assignCg(int cgId) {
    // assignCgToBooking handles success/error toasts AND closes the dialog on
    // success. Do not pop or show a success snackbar here — doing so popped the
    // dialog early and reported success even when the request later failed.
    bookingController.assignCgToBooking(cgId: cgId, bookingId: bookingId);
  }

  Widget _genderPill(String gender) {
    final isMale   = gender.toLowerCase() == 'male' ||
        gender.toLowerCase() == '1';
    final isFemale = gender.toLowerCase() == 'female' ||
        gender.toLowerCase() == '2';

    final AppTone tone = isMale
        ? AppTone.primary
        : isFemale
        ? AppTone.violet
        : AppTone.neutral;
    final String text = isMale
        ? 'Male'
        : isFemale
        ? 'Female'
        : gender;

    return AppStatusBadge(label: text, tone: tone, showDot: false, dense: true);
  }
}

/// Table row with a hover tint and a bottom hairline.
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _hover ? AppColor.surfaceMuted : Colors.transparent,
          border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
        ),
        child: widget.child,
      ),
    );
  }
}
