import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/register_cg/views/review_cg_details_view.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/register_cg_controller.dart';
import '../models/get_cg_details_model.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ManageCgView extends GetView<RegisterCgController> {
  const ManageCgView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RegisterCgController());
    SizeConfig.init(context);

    if (SizeConfig.isMobile) {
      return Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        body: Padding(
          padding: SizeConfig.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 16),
              _summaryCards(),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColor.borderSubtle)),
                ),
                child: _tabs(),
              ),
              const SizedBox(height: 12),
              _searchAndFilters(),
              const SizedBox(height: 12),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            const SizedBox(height: 24),
            _summaryCards(),
            const SizedBox(height: 20),
            Expanded(
              child: AppCard(
                padding: EdgeInsets.zero,
                expandChild: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _tabs(),
                    ),
                    Divider(height: 1, color: AppColor.borderSubtle),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _searchAndFilters(),
                    ),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _header() {
    return AppPageHeader(
      title: 'HP Management',
      subtitle: 'Manage Health Professional registration applications',
      actions: [
        OutlinedButton.icon(
          onPressed: () => HelperUi.showToast(message: 'Export feature coming soon'),
          icon: const Icon(LucideIcons.download, size: 18),
          label: const Text('Export'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Get.toNamed(Routes.REGISTER_CG);
          },
          icon: const Icon(LucideIcons.userPlus, size: 18),
          label: const Text('Register HP'),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _filterChip('All Specialities')),
              const SizedBox(width: 8),
              Expanded(
                child: _filterChip('Date',
                    icon: LucideIcons.calendar),
              ),
            ],
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: _searchField('Search by name, ID, or speciality...'),
        ),
        _filterChip('All Specialities'),
        _filterChip('dd/mm/yyyy', icon: LucideIcons.calendar),
      ],
    );
  }

  Widget _searchField(String hint) {
    return AppSearchField(
      hint: hint,
      onChanged: (v) => controller.searchQueryManageCg.value = v,
    );
  }

  Widget _filterChip(String label, {IconData? icon}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon ?? LucideIcons.chevronDown,
              size: icon == null ? 18 : 16, color: AppColor.textTertiary),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUMMARY — KPI tiles (desktop), compact scrollable pills (mobile)
  // ═══════════════════════════════════════════════════════════════

  Widget _summaryCards() {
    return Obx(() {
      final items = [
        _StatItem(
          'Total',
          controller.getAllCgData.value.length,
          AppTone.primary,
          LucideIcons.users,
        ),
        _StatItem('Pending', _countByStatus(1), toneForStatus('Pending'),
            LucideIcons.hourglass),
        _StatItem('Approved', _countByStatus(2), toneForStatus('Approved'),
            LucideIcons.badgeCheck),
        _StatItem('Rejected', _countByStatus(3), toneForStatus('Rejected'),
            LucideIcons.circleX),
        _StatItem('Terminated', _countByStatus(4),
            toneForStatus('Terminated'), LucideIcons.ban),
      ];

      if (SizeConfig.isMobile) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatPill(item: item),
                ),
            ],
          ),
        );
      }

      return AppResponsiveGrid(
        minItemWidth: 170,
        maxColumns: 5,
        children: [
          for (final item in items)
            AppStatCard(
              label: item.label,
              value: '${item.count}',
              icon: item.icon,
              tone: item.tone,
            ),
        ],
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
          return InkWell(
            onTap: () {
              controller.selectedTab.value = key;
              controller.currentPage.value = 0;
              controller.fetchCgByTab(tab.status);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColor.cPrimaryButtonColor
                          : AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColor.primarySoft
                          : AppColor.neutralSoft,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '${tab.count}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColor.cPrimaryButtonColor
                            : AppColor.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );

      return SingleChildScrollView(scrollDirection: Axis.horizontal, child: row);
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
        return AppEmptyState(
          icon: LucideIcons.users,
          title: 'No records found',
          message: 'Try another tab or a different search term.',
          compact: SizeConfig.isMobile,
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

  /// Profile photo URL, or null when the HP has none (the API stores a
  /// placeholder path ending in `/NA`).
  String? _photoUrl(GetCgDetails cg) {
    final p = cg.hpRegPhoto;
    return (p.isNotEmpty && !p.contains('/NA')) ? p : null;
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
    final name = '${cg.hpRegFirstName} ${cg.hpRegLastName}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(name: name, imageUrl: _photoUrl(cg), size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColor.cPrimaryButtonColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusPill(cg.hpRegStatus),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(LucideIcons.graduationCap, cg.hpRegEducation),
            const SizedBox(height: 6),
            _infoRow(LucideIcons.mail, cg.hpRegEmail),
            const SizedBox(height: 6),
            _infoRow(LucideIcons.phone, cg.hpRegPhoneNumber),
            const SizedBox(height: 6),
            _infoRow(
              LucideIcons.calendar,
              cg.hpRegDob != null
                  ? cg.hpRegDob!.toIso8601String().split('T').first
                  : '-',
            ),
            Divider(height: 24, color: AppColor.borderSubtle),
            _buildMobileActions(cg),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
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
          child: OutlinedButton.icon(
            onPressed: () => Get.to(() => CgReviewDetailScreen(cgDetails: cg)),
            icon: const Icon(LucideIcons.eye, size: 18),
            label: const Text('Review Details'),
          ),
        ),
        const SizedBox(height: 8),
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
                  child: OutlinedButton.icon(
                    onPressed: () => _showConfirmationDialog(
                      Get.context!,
                      title: 'Terminate Caregiver',
                      message:
                          'Are you sure you want to terminate ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                      confirmLabel: 'Terminate',
                      tone: AppTone.danger,
                      onConfirm: () => controller.updateCgStatus(cg.hpRegId, 4),
                    ),
                    style: AppButtonStyles.dangerOutlined,
                    icon: const Icon(LucideIcons.ban, size: 18),
                    label: const Text('Terminate'),
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
                          tone: AppTone.success,
                          onConfirm: () =>
                              controller.updateCgStatus(cg.hpRegId, 2),
                        ),
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showConfirmationDialog(
                          Get.context!,
                          title: 'Reject Caregiver',
                          message:
                              'Are you sure you want to reject ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                          confirmLabel: 'Reject',
                          tone: AppTone.danger,
                          onConfirm: () =>
                              controller.updateCgStatus(cg.hpRegId, 3),
                        ),
                        style: AppButtonStyles.dangerOutlined,
                        icon: const Icon(LucideIcons.x, size: 18),
                        label: const Text('Reject'),
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
            child: DataTable2(
              columnSpacing: 16,
              horizontalMargin: 16,
              minWidth: 960,
              dividerThickness: 0,
              dataRowHeight: 68,
              headingRowHeight: 44,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: AppColor.borderSubtle,
                  width: 1,
                ),
              ),
              columns: const [
                DataColumn2(
                  label: Text('ID'),
                  size: ColumnSize.S,
                  fixedWidth: 88,
                ),
                DataColumn2(label: Text('HP Info'), size: ColumnSize.L),
                DataColumn2(label: Text('Contact'), size: ColumnSize.M),
                DataColumn2(label: Text('Date / Docs'), size: ColumnSize.S),
                DataColumn2(label: Text('Status'), size: ColumnSize.S),
                DataColumn2(
                  label: Text('Actions'),
                  size: ColumnSize.S,
                  fixedWidth: 152,
                ),
              ],
              rows: pageData.map<DataRow>((cg) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
                        style: TextStyle(
                          color: AppColor.cPrimaryButtonColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
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
          Divider(height: 1, color: AppColor.borderSubtle),
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
    final name = '${cg.hpRegFirstName} ${cg.hpRegLastName}';
    return Row(
      children: [
        AppAvatar(name: name, imageUrl: _photoUrl(cg), size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                cg.hpRegEducation,
                style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
            Icon(LucideIcons.mail, size: 14, color: AppColor.textTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                cg.hpRegEmail,
                style: TextStyle(fontSize: 13, color: AppColor.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(LucideIcons.phone, size: 14, color: AppColor.textTertiary),
            const SizedBox(width: 6),
            Text(
              cg.hpRegPhoneNumber,
              style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
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
              LucideIcons.calendar,
              size: 14,
              color: AppColor.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              cg.hpRegDob != null
                  ? cg.hpRegDob!.toIso8601String().split('T').first
                  : '-',
              style: TextStyle(fontSize: 13, color: AppColor.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(LucideIcons.paperclip,
                size: 14, color: AppColor.textTertiary),
            const SizedBox(width: 6),
            Text(
              '4 files',
              style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableActions(GetCgDetails cg) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RowAction(
          tooltip: 'Review details',
          icon: LucideIcons.eye,
          color: AppColor.textSecondary,
          onTap: () => Get.to(() => CgReviewDetailScreen(cgDetails: cg)),
        ),
        Obx(
          () => controller.manageCgStatusLoading.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (cg.hpRegStatus == 2 || cg.hpRegStatus == 3)
              ? _RowAction(
                  tooltip: 'Terminate',
                  icon: LucideIcons.ban,
                  color: AppColor.danger,
                  onTap: () => _showConfirmationDialog(
                    Get.context!,
                    title: 'Terminate Caregiver',
                    message:
                        'Are you sure you want to terminate ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                    confirmLabel: 'Terminate',
                    tone: AppTone.danger,
                    onConfirm: () => controller.updateCgStatus(cg.hpRegId, 4),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RowAction(
                      tooltip: 'Approve',
                      icon: LucideIcons.circleCheck,
                      color: AppColor.success,
                      onTap: () => _showConfirmationDialog(
                        Get.context!,
                        title: 'Approve Caregiver',
                        message:
                            'Are you sure you want to approve ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                        confirmLabel: 'Approve',
                        tone: AppTone.success,
                        onConfirm: () =>
                            controller.updateCgStatus(cg.hpRegId, 2),
                      ),
                    ),
                    _RowAction(
                      tooltip: 'Reject',
                      icon: LucideIcons.circleX,
                      color: AppColor.danger,
                      onTap: () => _showConfirmationDialog(
                        Get.context!,
                        title: 'Reject Caregiver',
                        message:
                            'Are you sure you want to reject ${cg.hpRegFirstName} ${cg.hpRegLastName}?',
                        confirmLabel: 'Reject',
                        tone: AppTone.danger,
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
    final captionStyle = TextStyle(fontSize: 13, color: AppColor.textTertiary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rows per page:', style: captionStyle),
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
                style: captionStyle.copyWith(color: AppColor.textSecondary),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navBtn(
                LucideIcons.chevronFirst,
                currentPage > 0,
                () => controller.currentPage.value = 0,
                tooltip: 'First page',
              ),
              _navBtn(
                LucideIcons.chevronLeft,
                currentPage > 0,
                () => controller.currentPage.value = currentPage - 1,
                tooltip: 'Previous page',
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
                LucideIcons.chevronRight,
                currentPage < totalPages - 1,
                () => controller.currentPage.value = currentPage + 1,
                tooltip: 'Next page',
              ),
              _navBtn(
                LucideIcons.chevronLast,
                currentPage < totalPages - 1,
                () => controller.currentPage.value = totalPages - 1,
                tooltip: 'Last page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, bool enabled, VoidCallback onTap,
      {String? tooltip}) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      tooltip: tooltip,
      icon: Icon(
        icon,
        size: 18,
        color: enabled ? AppColor.textSecondary : AppColor.lightGrey,
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
    AppTone tone = AppTone.primary,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        icon: tone == AppTone.danger
            ? LucideIcons.triangleAlert
            : tone == AppTone.success
                ? LucideIcons.circleCheck
                : LucideIcons.circleHelp,
        tone: tone,
        maxWidth: 440,
        onClose: () => Navigator.of(ctx).pop(),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: tone == AppTone.danger ? AppButtonStyles.danger : null,
            child: Text(confirmLabel),
          ),
        ],
        child: Text(
          message,
          style: TextStyle(
              fontSize: 14, height: 1.5, color: AppColor.textSecondary),
        ),
      ),
    );
  }

  int _countByStatus(int status) => controller.getAllCgData.value
      .where((e) => e.hpRegStatus == status)
      .length;

  /// HP registration status badge (0 Inactive, 1 Pending, 2 Approved,
  /// 3 Rejected, 4 Terminated).
  Widget _statusPill(int status) {
    late String text;

    switch (status) {
      case 0:
        text = 'Inactive';
        break;
      case 1:
        text = 'Pending';
        break;
      case 2:
        text = 'Approved';
        break;
      case 3:
        text = 'Rejected';
        break;
      case 4:
        text = 'Terminated';
        break;
      default:
        text = 'Pending';
    }

    return AppStatusBadge.status(text);
  }
}

// ═══════════════════════════════════════════════════════════════
// ROW ACTION — 18px icon button with tooltip
// ═══════════════════════════════════════════════════════════════

class _RowAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RowAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 18, color: color),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? color : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: selected ? color : AppColor.borderSubtle),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: Text(
                '${number + 1}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? AppColor.buttonTextWhite
                      : AppColor.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SUMMARY PILL (mobile)
// ═══════════════════════════════════════════════════════════════

class _StatPill extends StatelessWidget {
  final _StatItem item;
  const _StatPill({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.tone.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.label,
            style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.count}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
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
  final AppTone tone;
  final IconData icon;
  _StatItem(this.label, this.count, this.tone, this.icon);
}

class _TabDef {
  final String label;
  final int? status;
  final int count;
  _TabDef(this.label, this.status, this.count);
}
