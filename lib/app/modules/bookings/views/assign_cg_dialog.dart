import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../register_cg/controllers/register_cg_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart'; // Phase 4.4 — branch list
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/bookings_controller.dart';

class AssignCgDialog extends StatelessWidget {
  final int bookingId;
  AssignCgDialog({super.key, required this.bookingId});

  final RegisterCgController cgController   = Get.put(RegisterCgController());
  final BookingsController bookingController = Get.find<BookingsController>();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final booking = bookingController.bookingsByBookingId.value.first;

    return Dialog(
      insetPadding: EdgeInsets.all(SizeConfig.spacingMD),
      backgroundColor: AppColor.cAppBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
      ),
      child: Container(
        width:  MediaQuery.of(context).size.width  * 0.92,
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: AppColor.cAppBackgroundColor,
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(booking),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(SizeConfig.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookingDetails(booking),
                    SizedBox(height: SizeConfig.spacingMD),
                    _buildFiltersCard(),
                  ],
                ),
              ),
            ),
            _buildTableSection(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(dynamic booking) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(SizeConfig.radiusMD),
          topRight: Radius.circular(SizeConfig.radiusMD),
        ),
        border: Border(
          bottom: BorderSide(color: AppColor.divColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.spacingXS),
            decoration: BoxDecoration(
              color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
            ),
            child: Icon(
              Icons.person_add_outlined,
              color: AppColor.cPrimaryButtonColor,
              size: SizeConfig.iconMD,
            ),
          ),
          SizedBox(width: SizeConfig.spacingSM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Health Professional',
                style: AppTextStyles.heading.copyWith(
                  fontSize: SizeConfig.fontH2,
                ),
              ),
              Text(
                'Booking ID: #${booking.id}',
                style: AppTextStyles.regular14Gre.copyWith(
                  fontSize: SizeConfig.fontCaption,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              size: SizeConfig.iconMD,
              color: AppColor.fontColorGrey,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColor.fieldColorGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOOKING DETAILS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBookingDetails(dynamic booking) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingMD,
              vertical: SizeConfig.spacingSM,
            ),
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(SizeConfig.radiusMD),
                topRight: Radius.circular(SizeConfig.radiusMD),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: SizeConfig.iconSM,
                  color: AppColor.cPrimaryButtonColor,
                ),
                SizedBox(width: SizeConfig.spacingXS),
                Text(
                  'Booking Details',
                  style: AppTextStyles.regular14black.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: SizeConfig.fontBody,
                  ),
                ),
              ],
            ),
          ),
          // Info row
          Padding(
            padding: EdgeInsets.all(SizeConfig.spacingMD),
            child: Row(
              children: [
                _infoCell(
                  icon: Icons.medical_services_outlined,
                  label: 'Service',
                  value: booking.serviceName ?? 'Nursing',
                ),
                _verticalDivider(),
                _infoCell(
                  icon: Icons.location_city_outlined,
                  label: 'City',
                  value: (booking.branchCity as String?)?.isNotEmpty == true
                      ? booking.branchCity
                      : (booking.city ?? '-'),
                ),
                _verticalDivider(),
                _infoCell(
                  icon: Icons.wc_outlined,
                  label: 'Patient Gender',
                  value: _genderLabel(booking.patientGender),
                ),
                _verticalDivider(),
                _infoCell(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Patient Weight',
                  value: (booking.patientWeight as String?)?.isNotEmpty == true
                      ? '${booking.patientWeight} kg'
                      : '-',
                ),
                _verticalDivider(),
                _infoCell(
                  icon: Icons.medical_services_outlined,
                  label: 'Service Type',
                  value: booking.serviceTypeName ?? booking.serviceName ?? '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _genderLabel(dynamic gender) {
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
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: SizeConfig.iconSM, color: AppColor.cPrimaryButtonColor),
          SizedBox(width: SizeConfig.spacingXS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.regular14Gre.copyWith(
                    fontSize: SizeConfig.fontCaption,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.regular14black.copyWith(
                    fontSize: SizeConfig.fontBody,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 36,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spacingSM),
      color: AppColor.divColor,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTERS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFiltersCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingMD,
              vertical: SizeConfig.spacingSM,
            ),
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(SizeConfig.radiusMD),
                topRight: Radius.circular(SizeConfig.radiusMD),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_outlined,
                  size: SizeConfig.iconSM,
                  color: AppColor.cPrimaryButtonColor,
                ),
                SizedBox(width: SizeConfig.spacingXS),
                Text(
                  'Filter Health Professionals',
                  style: AppTextStyles.regular14black.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: SizeConfig.fontBody,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeConfig.spacingMD),
            child: Obx(
              () {
                final dashCtrl  = Get.find<DashboardController>();
                final languages = cgController.availableLanguages;
                return Wrap(
                  spacing:  SizeConfig.spacingMD,
                  runSpacing: SizeConfig.spacingMD,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    // ── Phase 4.4: City / Branch filter ──────────────────
                    SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('City / Branch',
                              style: AppTextStyles.regular14Gre.copyWith(
                                  fontSize: SizeConfig.fontCaption)),
                          SizedBox(height: SizeConfig.spacingXS),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor,
                              border: Border.all(color: AppColor.divColor),
                              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                            ),
                            child: DropdownButton<int?>(
                              value: cgController.filterAssignBranchId.value,
                              hint: Text('All',
                                  style: AppTextStyles.regular14Gre.copyWith(
                                      fontSize: SizeConfig.fontCaption)),
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              isExpanded: true,
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
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Language',
                              style: AppTextStyles.regular14Gre.copyWith(
                                  fontSize: SizeConfig.fontCaption)),
                          SizedBox(height: SizeConfig.spacingXS),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor,
                              border: Border.all(color: AppColor.divColor),
                              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                            ),
                            child: DropdownButton<String>(
                              value: cgController.filterAssignLanguage.value.isEmpty
                                  ? null
                                  : cgController.filterAssignLanguage.value,
                              hint: Text('All',
                                  style: AppTextStyles.regular14Gre.copyWith(
                                      fontSize: SizeConfig.fontCaption)),
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String>(
                                    value: null, child: Text('All Languages')),
                                ...languages.map((l) {
                                  final name = l['language_name'] as String? ??
                                      l['name']   as String? ?? '';
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

                    // Existing: Gender
                    SizedBox(
                      width: 140,
                      child: _buildDropdown(
                        label: 'Gender',
                        value: cgController.hpGender.value.isEmpty
                            ? null
                            : cgController.hpGender.value,
                        items: ['Male', 'Female'],
                        onChanged: (v) => cgController.hpGender.value = v ?? '',
                      ),
                    ),

                    // Existing: Min weight
                    SizedBox(width: 130, child: _buildTextField(label: 'Min Weight (kg)')),

                    // Existing: Max weight
                    SizedBox(width: 130, child: _buildTextField(label: 'Max Weight (kg)')),

                    // Existing: Search
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton.icon(
                        onPressed: cgController.getAllCgFromApi,
                        icon: Icon(Icons.search,
                            size: SizeConfig.iconSM, color: AppColor.buttonTextWhite),
                        label: Text('Search',
                            style: TextStyle(
                              color: AppColor.buttonTextWhite,
                              fontSize: SizeConfig.fontBody,
                              fontFamily: 'poppins_regular',
                              fontWeight: FontWeight.w500,
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cPrimaryButtonColor,
                          elevation: 0,
                          padding: SizeConfig.buttonPadding,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.radiusSM)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return AppDropdownFormField<String>(
      label: label,
      hint: 'Select',
      value: value,
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e,
            style: AppTextStyles.regular14black
                .copyWith(fontSize: SizeConfig.fontBody)),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.regular14Gre
              .copyWith(fontSize: SizeConfig.fontCaption),
        ),
        SizedBox(height: SizeConfig.spacingXS),
        TextField(
          style: AppTextStyles.regular14black
              .copyWith(fontSize: SizeConfig.fontBody),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColor.whiteColor,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingSM,
              vertical: SizeConfig.spacingSM,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              borderSide: BorderSide(color: AppColor.divColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              borderSide: BorderSide(color: AppColor.divColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              borderSide:
              BorderSide(color: AppColor.cPrimaryButtonColor, width: 1.5),
            ),
            hintText: 'Enter value',
            hintStyle: AppTextStyles.regular14Gre
                .copyWith(fontSize: SizeConfig.fontBody),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLE SECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTableSection() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          SizeConfig.spacingMD,
          0,
          SizeConfig.spacingMD,
          SizeConfig.spacingMD,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Phase 4.4: Tab bar (All HPs | AI Suggested) ──────────────
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
    return Obx(() {
      final tab = cgController.assignDialogTab.value;
      return Container(
        decoration: BoxDecoration(
          color: AppColor.fieldColorGrey,
          borderRadius: BorderRadius.only(
            topLeft:  Radius.circular(SizeConfig.radiusMD),
            topRight: Radius.circular(SizeConfig.radiusMD),
          ),
          border: Border(bottom: BorderSide(color: AppColor.divColor)),
        ),
        child: Row(
          children: [
            _tabButton(
              label: 'All HPs',
              icon: Icons.people_outline,
              selected: tab == 0,
              onTap: () => cgController.assignDialogTab.value = 0,
              badge: () {
                // Show available count (exclude already-assigned & globally-active HPs)
                final assigned = bookingController.allBookingHpData.value
                    .map((hp) => hp.hpRegId ?? 0).toSet();
                final active = bookingController.globalActiveHpIds;
                final available = cgController.getAllCgData.value
                    .where((cg) => !assigned.contains(cg.hpRegId) && !active.contains(cg.hpRegId))
                    .length;
                return '$available';
              }(),
            ),
            _tabButton(
              label: 'AI Suggested',
              icon: Icons.auto_awesome,
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
              accentColor: const Color(0xFF7C3AED),
            ),
          ],
        ),
      );
    });
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spacingMD,
          vertical: SizeConfig.spacingSM,
        ),
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
            Icon(icon, size: SizeConfig.iconSM,
                color: selected ? color : AppColor.fontColorGrey),
            SizedBox(width: SizeConfig.spacingXS),
            Text(
              label,
              style: AppTextStyles.regular14black.copyWith(
                fontSize: SizeConfig.fontBody,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : AppColor.fontColorGrey,
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: SizeConfig.spacingXS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.12)
                      : AppColor.divColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : AppColor.fontColorGrey,
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 56, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No AI matches yet',
                  style: AppTextStyles.regular14black
                      .copyWith(fontSize: SizeConfig.fontH2, fontWeight: FontWeight.w600)),
              SizedBox(height: SizeConfig.spacingXS),
              Text('Tap "AI Suggested" to load scored matches',
                  style: AppTextStyles.regular14Gre
                      .copyWith(fontSize: SizeConfig.fontBody)),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Column headers
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingMD,
              vertical: SizeConfig.spacingSM,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColor.divColor)),
            ),
            child: Row(
              children: [
                _tableHeader('Score',    flex: 1),
                _tableHeader('HP ID',    flex: 1),
                _tableHeader('Name',     flex: 2),
                _tableHeader('City',     flex: 2),
                _tableHeader('Languages', flex: 2),
                _tableHeader('Exp',      flex: 1),
                _tableHeader('Action',   flex: 1),
              ],
            ),
          ),
          // Rows
          Expanded(
            child: ListView.builder(
              itemCount: cgController.matchedHPs.length,
              itemBuilder: (_, i) => _buildAiHpRow(cgController.matchedHPs[i]),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAiHpRow(Map<String, dynamic> hp) {
    final score = (hp['score_pct'] as num? ?? 0).toInt();
    final name  = hp['name']  as String? ?? 'HP #${hp['hp_reg_id']}';
    final hpId  = hp['hp_reg_id'];
    final city  = hp['city']  as String? ?? '—';
    final langs = hp['languages'] as String? ?? '—';
    final exp   = hp['experience'] != null ? '${hp['experience']} yr' : '—';

    // Score colour: green ≥ 70, amber ≥ 40, red < 40
    final scoreColor = score >= 70
        ? const Color(0xFF059669)
        : score >= 40
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        children: [
          // Score badge
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$score%',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // HP ID
          Expanded(
            flex: 1,
            child: Text(
              'HP-${hpId.toString().padLeft(3, '0')}',
              style: AppTextStyles.regular14black.copyWith(
                color: AppColor.cPrimaryButtonColor,
                fontWeight: FontWeight.w600,
                fontSize: SizeConfig.fontBody,
              ),
            ),
          ),
          // Name
          Expanded(
            flex: 2,
            child: Text(name,
                style: AppTextStyles.regular14black.copyWith(
                    fontSize: SizeConfig.fontBody),
                overflow: TextOverflow.ellipsis),
          ),
          // City
          Expanded(
            flex: 2,
            child: Text(city,
                style: AppTextStyles.regular14Gre.copyWith(
                    fontSize: SizeConfig.fontBody),
                overflow: TextOverflow.ellipsis),
          ),
          // Languages
          Expanded(
            flex: 2,
            child: Text(langs,
                style: AppTextStyles.regular14Gre.copyWith(
                    fontSize: SizeConfig.fontBody),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
          // Experience
          Expanded(
            flex: 1,
            child: Text(exp,
                style: AppTextStyles.regular14Gre.copyWith(
                    fontSize: SizeConfig.fontBody)),
          ),
          // Assign button
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () => bookingController.assignCgToBooking(
                bookingId: bookingId,
                cgId:      hpId is int ? hpId : int.tryParse('$hpId') ?? 0,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radiusSM)),
              ),
              child: Text('Assign',
                  style: TextStyle(
                      color: AppColor.buttonTextWhite,
                      fontSize: SizeConfig.fontCaption,
                      fontWeight: FontWeight.w500)),
            ),
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
              !activeElsewhere.contains(cg.hpRegId))
          .toList();
      // ───────────────────────────────────────────────────────────────

      if (availableCgs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline,
                  size: 56, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingSM),
              Text(
                'No available health professionals',
                style: AppTextStyles.regular14black.copyWith(
                  fontSize: SizeConfig.fontH2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: SizeConfig.spacingXS),
              Text(
                'All matching HPs are already assigned to a booking',
                style: AppTextStyles.regular14Gre
                    .copyWith(fontSize: SizeConfig.fontBody),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Table header row
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingMD,
              vertical: SizeConfig.spacingSM,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColor.divColor),
              ),
            ),
            child: Row(
              children: [
                _tableHeader('HP ID',      flex: 1),
                _tableHeader('Name',       flex: 2),
                _tableHeader('Phone',      flex: 2),
                _tableHeader('Gender',     flex: 1),
                _tableHeader('Languages',  flex: 2),
                _tableHeader('Experience', flex: 1),
                _tableHeader('Action',     flex: 1),
              ],
            ),
          ),
          // Table rows (filtered list only)
          Expanded(
            child: ListView.builder(
              itemCount: availableCgs.length,
              itemBuilder: (_, index) => _buildCgRow(availableCgs[index]),
            ),
          ),
          // Pagination footer
          _buildTableFooter(overrideCount: availableCgs.length),
        ],
      );
    });
  }

  Widget _tableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.regular14black.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.fontBody,
              color: AppColor.fontColorGrey,
            ),
          ),
          SizedBox(width: SizeConfig.spacingXS / 2),
          Icon(Icons.unfold_more,
              size: SizeConfig.iconSM, color: AppColor.lightGrey),
        ],
      ),
    );
  }

  Widget _buildCgRow(dynamic cg) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        children: [
          // HP ID
          Expanded(
            flex: 1,
            child: Text(
              'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
              style: AppTextStyles.regular14black.copyWith(
                color: AppColor.cPrimaryButtonColor,
                fontWeight: FontWeight.w600,
                fontSize: SizeConfig.fontBody,
              ),
            ),
          ),
          // Name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cg.hpRegFirstName} ${cg.hpRegLastName}',
                  style: AppTextStyles.regular14black.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: SizeConfig.fontBody,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (cg.hpRegEducation != null)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cg.hpRegEducation,
                      style: TextStyle(
                        color: AppColor.cPrimaryButtonColor,
                        fontSize: SizeConfig.fontCaption,
                        fontFamily: 'poppins_regular',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // Phone
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.phone_outlined,
                    size: SizeConfig.iconSM, color: AppColor.lightGrey),
                SizedBox(width: SizeConfig.spacingXS),
                Text(
                  cg.hpRegPhoneNumber ?? '-',
                  style: AppTextStyles.regular14Gre
                      .copyWith(fontSize: SizeConfig.fontBody),
                ),
              ],
            ),
          ),
          // Gender
          Expanded(
            flex: 1,
            child: _genderPill(cg.hpRegGender.isNotEmpty ? cg.hpRegGender : '-'),
          ),
          // Languages
          Expanded(
            flex: 2,
            child: Text(
              cg.hpRegLanguages ?? '-',
              style: AppTextStyles.regular14Gre
                  .copyWith(fontSize: SizeConfig.fontBody),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Experience
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(Icons.work_outline,
                    size: SizeConfig.iconSM, color: AppColor.lightGrey),
                SizedBox(width: SizeConfig.spacingXS),
                Text(
                  '${cg.hpRegExperience.isNotEmpty ? cg.hpRegExperience : '0'} yrs',
                  style: AppTextStyles.regular14black
                      .copyWith(fontSize: SizeConfig.fontBody),
                ),
              ],
            ),
          ),
          // Assign button
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () => _assignCg(cg.hpRegId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spacingSM,
                  vertical: SizeConfig.spacingXS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                ),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Assign',
                style: TextStyle(
                  color: AppColor.buttonTextWhite,
                  fontSize: SizeConfig.fontBody,
                  fontFamily: 'poppins_regular',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(SizeConfig.radiusMD),
          bottomRight: Radius.circular(SizeConfig.radiusMD),
        ),
        border: Border(top: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $count health professionals',
            style: AppTextStyles.regular14Gre
                .copyWith(fontSize: SizeConfig.fontCaption),
          ),
          Row(
            children: [
              _paginationBtn('Previous', false, () {}),
              SizedBox(width: SizeConfig.spacingXS),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor,
                  borderRadius:
                  BorderRadius.circular(SizeConfig.radiusSM),
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    color: AppColor.buttonTextWhite,
                    fontSize: SizeConfig.fontBody,
                    fontFamily: 'poppins_regular',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.spacingXS),
              _paginationBtn('Next', true, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paginationBtn(String label, bool enabled, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.fontColorGrey,
        side: BorderSide(color: AppColor.divColor),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spacingSM,
          vertical: SizeConfig.spacingXS,
        ),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.regular14Gre
            .copyWith(fontSize: SizeConfig.fontBody),
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

    final Color bg = isMale
        ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.12)
        : isFemale
        ? const Color(0xFFFDF2F8)
        : AppColor.fieldColorGrey;
    final Color fg = isMale
        ? AppColor.cPrimaryButtonColor2
        : isFemale
        ? const Color(0xFF9D174D)
        : AppColor.fontColorGrey;
    final String text = isMale
        ? 'Male'
        : isFemale
        ? 'Female'
        : gender;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: SizeConfig.fontCaption,
          fontFamily: 'poppins_regular',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}