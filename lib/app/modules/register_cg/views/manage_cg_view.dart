import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/register_cg/views/review_cg_details_view.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/register_cg_controller.dart';
import '../models/get_cg_details_model.dart';

class ManageCgView extends GetView<RegisterCgController> {
  const ManageCgView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RegisterCgController());
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            SizedBox(height: SizeConfig.spacingLG),
            _searchAndFilters(),
            SizedBox(height: SizeConfig.spacingMD),
            _summaryCards(),
            SizedBox(height: SizeConfig.spacingMD),
            _tabs(),
            SizedBox(height: SizeConfig.spacingMD),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _header() {
    if (SizeConfig.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HP Registration',
            style: AppTextStyles.heading.copyWith(fontSize: SizeConfig.fontH1),
          ),
          SizedBox(height: SizeConfig.spacingXS),
          Text(
            'Manage Health Professional registration applications',
            style: AppTextStyles.regular14Gre.copyWith(
              fontSize: SizeConfig.fontCaption,
            ),
          ),
          SizedBox(height: SizeConfig.spacingMD),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => HelperUi.showToast(message: 'Export feature coming soon'),
                  icon: Icon(Icons.download, size: SizeConfig.iconSM),
                  label: Text(
                    'Export',
                    style: TextStyle(fontSize: SizeConfig.fontCaption),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM,
                      vertical: SizeConfig.spacingSM,
                    ),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.spacingXS),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.REGISTER_CG),
                  icon: Icon(
                    Icons.add,
                    color: AppColor.buttonTextWhite,
                    size: SizeConfig.iconSM,
                  ),
                  label: Text(
                    'New',
                    style: TextStyle(fontSize: SizeConfig.fontCaption),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM,
                      vertical: SizeConfig.spacingSM,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HP Management',
                style: AppTextStyles.heading.copyWith(
                  fontSize: SizeConfig.fontH1,
                ),
              ),
              SizedBox(height: SizeConfig.spacingXS),
              Text(
                'Manage Health Professional registration applications',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => HelperUi.showToast(message: 'Export feature coming soon'),
              icon: Icon(Icons.download, size: SizeConfig.iconSM),
              label: const Text('Export'),
              style: OutlinedButton.styleFrom(
                padding: SizeConfig.buttonPadding,
              ),
            ),
            SizedBox(width: SizeConfig.spacingSM),
            ElevatedButton.icon(
              onPressed: () { 
                Get.toNamed(Routes.REGISTER_CG);
              },
              icon: Icon(
                Icons.add,
                color: AppColor.buttonTextWhite,
                size: SizeConfig.iconSM,
              ),
              label: Text(SizeConfig.isTablet ? 'New' : 'New Registration',style: TextStyle(color: AppColor.buttonTextWhite),),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                padding: SizeConfig.buttonPadding,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════

  Widget _searchAndFilters() {
    if (SizeConfig.isMobile) {
      return Column(
        children: [
          _searchField('Search...'),
          SizedBox(height: SizeConfig.spacingSM),
          Row(
            children: [
              Expanded(child: _filterChip('All Specialities')),
              SizedBox(width: SizeConfig.spacingXS),
              Expanded(child: _filterChip('Date', icon: Icons.calendar_today)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _searchField('Search by name, ID, or speciality...'),
        ),
        SizedBox(width: SizeConfig.spacingMD),
        _filterChip('All Specialities'),
        SizedBox(width: SizeConfig.spacingMD),
        _filterChip('dd/mm/yyyy', icon: Icons.calendar_today),
      ],
    );
  }

  Widget _searchField(String hint) {
    return TextField(
      onChanged: (v) => controller.searchQueryManageCg.value = v,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: SizeConfig.fontBody),
        prefixIcon: Icon(Icons.search, size: SizeConfig.iconMD),
        filled: true,
        fillColor: AppColor.whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          borderSide: BorderSide(color: AppColor.divColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          borderSide: BorderSide(color: AppColor.divColor),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: SizeConfig.spacingSM,
          horizontal: SizeConfig.spacingSM,
        ),
      ),
    );
  }

  Widget _filterChip(String label, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingMD,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.regular14black.copyWith(
                fontSize: SizeConfig.isMobile
                    ? SizeConfig.fontCaption
                    : SizeConfig.fontBody,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: SizeConfig.spacingXS),
            Icon(icon, size: SizeConfig.iconSM),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COMPACT SUMMARY CARDS — single-line pill style
  // ═══════════════════════════════════════════════════════════════

  Widget _summaryCards() {
    return Obx(() {
      final items = [
        _StatItem(
          'Total',
          controller.getAllCgData.value.length,
          AppColor.cPrimaryButtonColor,
        ),
        _StatItem('Pending', _countByStatus(1), const Color(0xFFE65100)),
        _StatItem('Approved', _countByStatus(2), const Color(0xFF2E7D32)),
        _StatItem('Rejected', _countByStatus(3), const Color(0xFFC62828)),
        _StatItem('Terminated', _countByStatus(4), AppColor.fontColorGrey),
      ];

      return Row(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: i < items.length - 1 ? SizeConfig.spacingSM : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
                border: Border.all(color: AppColor.divColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'poppins_regular',
                        fontSize: SizeConfig.fontCaption,
                        color: AppColor.fontColorGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.count}',
                    style: TextStyle(
                      fontFamily: 'poppins_regular',
                      fontSize: SizeConfig.fontBody,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // TABS — reactive, switchable, fetches filtered data
  // ═══════════════════════════════════════════════════════════════

  Widget _tabs() {
    return Obx(() {
      final tabDefs = [
        _TabDef('All', null, controller.getAllCgData.value.length),
        _TabDef('Pending', 1, _countByStatus(1)),
        _TabDef('Approved', 2, _countByStatus(2)),
        _TabDef('Rejected', 3, _countByStatus(3)),
        _TabDef('Terminated', 4, _countByStatus(4)),
      ];

      final row = Row(
        children: tabDefs.map((tab) {
          final key = tab.status?.toString() ?? 'null';
          final selected = controller.selectedTab.value == key;
          return GestureDetector(
            onTap: () {
              controller.selectedTab.value = key;
              controller.currentPage.value = 0;
              controller.fetchCgByTab(tab.status);
            },
            child: Container(
              margin: EdgeInsets.only(right: SizeConfig.spacingMD),
              padding: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected
                        ? AppColor.cPrimaryButtonColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                '${tab.label} (${tab.count})',
                style: TextStyle(
                  fontFamily: 'poppins_regular',
                  fontSize: SizeConfig.isMobile
                      ? SizeConfig.fontBodySmall
                      : SizeConfig.fontBody,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.fontColorGrey,
                ),
              ),
            ),
          );
        }).toList(),
      );

      return SizeConfig.isMobile
          ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row)
          : row;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // CONTENT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContent() {
    return Obx(() {
      if (controller.getAllCGLoading.value) {
        return Center(child: HelperUi().loader());
      }

      final list = _filteredList();

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingMD),
              Text(
                'No records found',
                style: TextStyle(
                  fontSize: SizeConfig.fontH2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }

      if (SizeConfig.isMobile) return _buildMobileCardList(list);
      return _buildTableWithPagination(list);
    });
  }

  List<GetCgDetails> _filteredList() {
    final all = controller.getAllCgData.value;
    final tab = controller.selectedTab.value;
    final query = controller.searchQueryManageCg.value.trim().toLowerCase();

    List<GetCgDetails> byTab;
    if (tab == 'null') {
      byTab = all;
    } else {
      final status = int.tryParse(tab);
      byTab = status == null ? all : all.where((e) => e.hpRegStatus == status).toList();
    }

    if (query.isEmpty) return byTab;
    return byTab.where((cg) {
      final name = '${cg.hpRegFirstName} ${cg.hpRegLastName}'.toLowerCase();
      final id = 'hp-${cg.hpRegId.toString().padLeft(3, '0')}';
      return name.contains(query) ||
          id.contains(query) ||
          cg.hpRegEmail.toLowerCase().contains(query) ||
          cg.hpRegPhoneNumber.contains(query);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE CARD LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileCardList(List<GetCgDetails> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => _buildCgCard(list[index]),
    );
  }

  Widget _buildCgCard(GetCgDetails cg) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: SizeConfig.cardPadding,
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SizeConfig.radiusMD),
                topRight: Radius.circular(SizeConfig.radiusMD),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
                  style: AppTextStyles.regular14black.copyWith(
                    color: AppColor.cPrimaryButtonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.fontBody,
                  ),
                ),
                _statusPill(cg.hpRegStatus),
              ],
            ),
          ),
          Padding(
            padding: SizeConfig.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(
                  Icons.person_outline,
                  '${cg.hpRegFirstName} ${cg.hpRegLastName}',
                  bold: true,
                ),
                SizedBox(height: SizeConfig.spacingXS),
                _infoRow(Icons.school_outlined, cg.hpRegEducation),
                SizedBox(height: SizeConfig.spacingXS),
                _infoRow(Icons.email_outlined, cg.hpRegEmail),
                SizedBox(height: SizeConfig.spacingXS / 2),
                _infoRow(Icons.phone_outlined, cg.hpRegPhoneNumber),
                SizedBox(height: SizeConfig.spacingXS),
                _infoRow(
                  Icons.calendar_today_outlined,
                  cg.hpRegDob != null
                      ? cg.hpRegDob!.toIso8601String().split('T').first
                      : '-',
                ),
                SizedBox(height: SizeConfig.spacingSM),
                const Divider(height: 1),
                SizedBox(height: SizeConfig.spacingSM),
                _buildMobileActions(cg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool bold = false}) {
    return Row(
      children: [
        Icon(icon, size: SizeConfig.iconSM, color: AppColor.lightGrey),
        SizedBox(width: SizeConfig.spacingXS),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.regular14Gre.copyWith(
              fontSize: SizeConfig.fontBodySmall,
              color: bold ? AppColor.fontColorBlack : null,
              fontWeight: bold ? FontWeight.w600 : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActions(GetCgDetails cg) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.to(() => CgReviewDetailScreen(cgDetails: cg)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: SizeConfig.spacingSM),
              side: BorderSide(color: AppColor.cPrimaryButtonColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              ),
            ),
            child: Text(
              'Review Details',
              style: TextStyle(
                color: AppColor.cPrimaryButtonColor,
                fontSize: SizeConfig.fontBodySmall,
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.spacingXS),
        Obx(
          () => controller.manageCgStatusLoading.value
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (cg.hpRegStatus == 2 || cg.hpRegStatus == 3)
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showConfirmationDialog(
                      Get.context!,
                      title: 'Terminate Caregiver',
                      message:
                          'Are you sure you want to terminate ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                      confirmLabel: 'Terminate',
                      confirmColor: AppColor.fontColorGrey,
                      onConfirm: () => controller.updateCgStatus(cg.hpRegId, 4),
                    ),
                    icon: Icon(
                      Icons.block,
                      color: AppColor.buttonTextWhite,
                      size: 15,
                    ),
                    label: Text(
                      'Terminate',
                      style: TextStyle(
                        color: AppColor.buttonTextWhite,
                        fontSize: SizeConfig.fontBodySmall,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.fontColorGrey,
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.spacingSM,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SizeConfig.radiusSM,
                        ),
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showConfirmationDialog(
                          Get.context!,
                          title: 'Approve Caregiver',
                          message:
                              'Are you sure you want to approve ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                          confirmLabel: 'Approve',
                          confirmColor: const Color(0xFF2E7D32),
                          onConfirm: () =>
                              controller.updateCgStatus(cg.hpRegId, 2),
                        ),
                        icon: Icon(
                          Icons.check,
                          color: AppColor.buttonTextWhite,
                          size: 15,
                        ),
                        label: Text(
                          'Approve',
                          style: TextStyle(
                            color: AppColor.buttonTextWhite,
                            fontSize: SizeConfig.fontBodySmall,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.spacingSM,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SizeConfig.radiusSM,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.spacingXS),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showConfirmationDialog(
                          Get.context!,
                          title: 'Reject Caregiver',
                          message:
                              'Are you sure you want to reject ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                          confirmLabel: 'Reject',
                          confirmColor: const Color(0xFFC62828),
                          onConfirm: () =>
                              controller.updateCgStatus(cg.hpRegId, 3),
                        ),
                        icon: Icon(
                          Icons.close,
                          color: AppColor.buttonTextWhite,
                          size: 15,
                        ),
                        label: Text(
                          'Reject',
                          style: TextStyle(
                            color: AppColor.buttonTextWhite,
                            fontSize: SizeConfig.fontBodySmall,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.spacingSM,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SizeConfig.radiusSM,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLE WITH PAGINATION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTableWithPagination(List<GetCgDetails> allData) {
    return Obx(() {
      final rowsPerPage = controller.rowsPerPage.value;
      final currentPage = controller.currentPage.value;
      final totalPages = (allData.length / rowsPerPage).ceil().clamp(1, 9999);
      final safePage = currentPage.clamp(0, totalPages - 1);
      if (safePage != currentPage) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => controller.currentPage.value = safePage,
        );
      }
      final start = safePage * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, allData.length);
      final pageData = allData.sublist(start, end);

      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                border: Border.all(color: AppColor.divColor),
              ),
              child: DataTable2(
                columnSpacing: SizeConfig.spacingMD,
                horizontalMargin: SizeConfig.spacingMD,
                dividerThickness: 0,
                dataRowHeight: SizeConfig.isTablet ? 70 : 74,
                headingRowHeight: SizeConfig.isTablet ? 46 : 50,
                headingTextStyle: TextStyle(
                  fontFamily: 'poppins_regular',
                  fontSize: SizeConfig.isTablet
                      ? SizeConfig.fontCaption
                      : SizeConfig.fontBody,
                  fontWeight: FontWeight.w600,
                  color: AppColor.fontColorBlack,
                ),
                dataTextStyle: TextStyle(
                  fontFamily: 'poppins_regular',
                  fontSize: SizeConfig.isTablet
                      ? SizeConfig.fontCaption
                      : SizeConfig.fontBodySmall,
                  color: AppColor.fontColorBlack,
                ),
                headingRowColor: WidgetStateProperty.all<Color>(
                  AppColor.fieldColorGrey,
                ),
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: AppColor.fieldColorGrey,
                    width: 1,
                  ),
                ),
                columns: const [
                  DataColumn2(
                    label: Text('ID'),
                    size: ColumnSize.S,
                    fixedWidth: 80,
                  ),
                  DataColumn2(label: Text('HP Info'), size: ColumnSize.L),
                  DataColumn2(label: Text('Contact'), size: ColumnSize.M),
                  DataColumn2(label: Text('Date / Docs'), size: ColumnSize.S),
                  DataColumn2(label: Text('Status'), size: ColumnSize.S),
                  DataColumn2(label: Text('Actions'), size: ColumnSize.M),
                ],
                rows: pageData.map<DataRow>((cg) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
                          style: AppTextStyles.regular14black.copyWith(
                            color: AppColor.cPrimaryButtonColor,
                            fontWeight: FontWeight.w600,
                            fontSize: SizeConfig.isTablet
                                ? SizeConfig.fontCaption
                                : SizeConfig.fontBody,
                          ),
                        ),
                      ),
                      DataCell(_buildCgInfoCell(cg)),
                      DataCell(_buildContactCell(cg)),
                      DataCell(_buildDateDocsCell(cg)),
                      DataCell(_statusPill(cg.hpRegStatus)),
                      DataCell(_buildTableActions(cg)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          _buildPaginationBar(
            currentPage: safePage,
            totalPages: totalPages,
            totalItems: allData.length,
            rowsPerPage: rowsPerPage,
            startIndex: start,
            endIndex: end,
          ),
        ],
      );
    });
  }

  Widget _buildCgInfoCell(GetCgDetails cg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${cg.hpRegFirstName} ${cg.hpRegLastName}',
          style: AppTextStyles.regular14black.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: SizeConfig.isTablet
                ? SizeConfig.fontCaption
                : SizeConfig.fontBody,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColor.cPrimaryButtonColor.withValues(alpha:0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            cg.hpRegEducation,
            style: TextStyle(
              color: AppColor.cPrimaryButtonColor,
              fontSize: SizeConfig.fontCaption,
              fontFamily: 'poppins_regular',
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCell(GetCgDetails cg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.email_outlined, size: 12, color: AppColor.lightGrey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                cg.hpRegEmail,
                style: AppTextStyles.regular14black.copyWith(
                  fontSize: SizeConfig.fontCaption,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.phone_outlined, size: 12, color: AppColor.lightGrey),
            const SizedBox(width: 4),
            Text(
              cg.hpRegPhoneNumber,
              style: AppTextStyles.regular14Gre.copyWith(
                fontSize: SizeConfig.fontCaption,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateDocsCell(GetCgDetails cg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: AppColor.lightGrey,
            ),
            const SizedBox(width: 4),
            Text(
              cg.hpRegDob != null
                  ? cg.hpRegDob!.toIso8601String().split('T').first
                  : '-',
              style: AppTextStyles.regular14black.copyWith(
                fontSize: SizeConfig.fontCaption,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.attach_file, size: 12, color: AppColor.lightGrey),
            const SizedBox(width: 4),
            Text(
              '4 files',
              style: AppTextStyles.regular14Gre.copyWith(
                fontSize: SizeConfig.fontCaption,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableActions(GetCgDetails cg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActionBtn(
          label: 'Review',
          color: AppColor.cPrimaryButtonColor,
          outlined: true,
          onTap: () => Get.to(() => CgReviewDetailScreen(cgDetails: cg)),
        ),
        const SizedBox(height: 6),
        Obx(
          () => controller.manageCgStatusLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : (cg.hpRegStatus == 2 || cg.hpRegStatus == 3)
              ? _ActionBtn(
                  label: 'Terminate',
                  color: AppColor.fontColorGrey,
                  icon: Icons.block,
                  onTap: () => _showConfirmationDialog(
                    Get.context!,
                    title: 'Terminate Caregiver',
                    message:
                        'Are you sure you want to terminate ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                    confirmLabel: 'Terminate',
                    confirmColor: AppColor.fontColorGrey,
                    onConfirm: () => controller.updateCgStatus(cg.hpRegId, 4),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionBtn(
                      label: 'Approve',
                      color: const Color(0xFF2E7D32),
                      icon: Icons.check,
                      onTap: () => _showConfirmationDialog(
                        Get.context!,
                        title: 'Approve Caregiver',
                        message:
                            'Are you sure you want to approve ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                        confirmLabel: 'Approve',
                        confirmColor: const Color(0xFF2E7D32),
                        onConfirm: () =>
                            controller.updateCgStatus(cg.hpRegId, 2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ActionBtn(
                      label: 'Reject',
                      color: const Color(0xFFC62828),
                      icon: Icons.close,
                      onTap: () => _showConfirmationDialog(
                        Get.context!,
                        title: 'Reject Caregiver',
                        message:
                            'Are you sure you want to reject ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                        confirmLabel: 'Reject',
                        confirmColor: const Color(0xFFC62828),
                        onConfirm: () =>
                            controller.updateCgStatus(cg.hpRegId, 3),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PAGINATION BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPaginationBar({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required int rowsPerPage,
    required int startIndex,
    required int endIndex,
  }) {
    return Container(
      margin: EdgeInsets.only(top: SizeConfig.spacingSM),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          Text(
            'Rows per page:',
            style: AppTextStyles.regular14Gre.copyWith(
              fontSize: SizeConfig.fontCaption,
            ),
          ),
          const SizedBox(width: 8),
          AppDropdown<int>(
            hint: '',
            value: rowsPerPage,
            isDense: true,
            isExpanded: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            items: [10, 20, 50]
                .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                controller.rowsPerPage.value = v;
                controller.currentPage.value = 0;
              }
            },
          ),
          const SizedBox(width: 16),
          Text(
            '${startIndex + 1}–$endIndex of $totalItems',
            style: AppTextStyles.regular14Gre.copyWith(
              fontSize: SizeConfig.fontCaption,
            ),
          ),
          const Spacer(),
          _navBtn(
            Icons.first_page,
            currentPage > 0,
            () => controller.currentPage.value = 0,
          ),
          _navBtn(
            Icons.chevron_left,
            currentPage > 0,
            () => controller.currentPage.value = currentPage - 1,
          ),
          ...List.generate(totalPages, (i) => i)
              .where(
                (i) =>
                    i == 0 ||
                    i == totalPages - 1 ||
                    (i - currentPage).abs() <= 1,
              )
              .map(
                (i) => _PageDot(
                  number: i,
                  selected: i == currentPage,
                  color: AppColor.cPrimaryButtonColor,
                  onTap: () => controller.currentPage.value = i,
                ),
              ),
          _navBtn(
            Icons.chevron_right,
            currentPage < totalPages - 1,
            () => controller.currentPage.value = currentPage + 1,
          ),
          _navBtn(
            Icons.last_page,
            currentPage < totalPages - 1,
            () => controller.currentPage.value = totalPages - 1,
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(
        icon,
        size: SizeConfig.iconSM,
        color: enabled ? AppColor.fontColorBlack : AppColor.divColor,
      ),
      splashRadius: 18,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        ),
        title: Text(
          title,
          style: AppTextStyles.heading.copyWith(fontSize: SizeConfig.fontH2),
        ),
        content: Text(
          message,
          style: AppTextStyles.regular14Gre.copyWith(
            fontSize: SizeConfig.fontBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: SizeConfig.fontBody,
                color: AppColor.fontColorGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              ),
            ),
            child: Text(
              confirmLabel,
              style: TextStyle(color: AppColor.buttonTextWhite),
            ),
          ),
        ],
      ),
    );
  }

  int _countByStatus(int status) => controller.getAllCgData.value
      .where((e) => e.hpRegStatus == status)
      .length;

  /// Clean pill-style status badge — no icon, just colour + text
  Widget _statusPill(int status) {
    late Color bg, fg;
    late String text;

    switch (status) {
      case 0:
        bg = AppColor.divColor;
        fg = AppColor.fontColorGrey;
        text = 'Inactive';
        break;
      case 1:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        text = 'Pending';
        break;
      case 2:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        text = 'Approved';
        break;
      case 3:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        text = 'Rejected';
        break;
      case 4:
        bg = AppColor.divColor;
        fg = AppColor.fontColorGrey;
        text = 'Terminated';
        break;
      default:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: SizeConfig.fontCaption,
          fontFamily: 'poppins_regular',
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ACTION BUTTON WIDGET
// ═══════════════════════════════════════════════════════════════

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final textChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: outlined ? color : AppColor.buttonTextWhite),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.fontCaption,
            color: outlined ? color : AppColor.buttonTextWhite,
            fontFamily: 'poppins_regular',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: const Size(0, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: textChild,
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: textChild,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE DOT
// ═══════════════════════════════════════════════════════════════

class _PageDot extends StatelessWidget {
  final int number;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PageDot({
    required this.number,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? color : AppColor.divColor),
        ),
        child: Text(
          '${number + 1}',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'poppins_regular',
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppColor.buttonTextWhite : AppColor.fontColorBlack,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INTERNAL DATA MODELS
// ═══════════════════════════════════════════════════════════════

class _StatItem {
  final String label;
  final int count;
  final Color color;
  _StatItem(this.label, this.count, this.color);
}

class _TabDef {
  final String label;
  final int? status;
  final int count;
  _TabDef(this.label, this.status, this.count);
}
