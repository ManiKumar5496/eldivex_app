import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/register_cg_controller.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../widgets/dropdown_common.dart';
import '../models/attendance_model.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class AttendanceListView extends GetView<RegisterCgController> {
  const AttendanceListView({super.key});

  /// Below this width the desktop table scrolls horizontally.
  static const double _tableMinWidth = 960;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.isMobile;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        // Horizontal page padding comes from the Attendance shell page.
        padding: EdgeInsets.only(top: 20, bottom: isMobile ? 12 : 24),
        child: isMobile ? _mobileBody() : _desktopBody(),
      ),
    );
  }

  // ================= DESKTOP BODY =================

  Widget _desktopBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summaryCards(),
        const SizedBox(height: 20),
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            expandChild: true,
            footer: _footer(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _filterSection(),
                ),
                Divider(height: 1, color: AppColor.borderSubtle),
                Expanded(child: _desktopTable()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _desktopTable() {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth < _tableMinWidth
          ? _tableMinWidth
          : constraints.maxWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          height: constraints.maxHeight,
          child: Column(
            children: [
              _tableHeader(),
              Expanded(child: _attendanceListTable()),
            ],
          ),
        ),
      );
    });
  }

  // ================= MOBILE BODY =================

  Widget _mobileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _headerMobile(),
        const SizedBox(height: 16),
        _filterSectionMobile(),
        const SizedBox(height: 12),
        _summaryCardsMobile(),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Attendance Records',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const Spacer(),
            Obx(() => Text(
                  '${controller.attendanceList.length} records',
                  style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
                )),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(child: _attendanceCardList()),
      ],
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return AppSectionTitle(
      title: 'Attendance Records',
      subtitle: 'View and manage attendance history',
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: () => _exportAttendance(),
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Export Report'),
          ),
          ElevatedButton.icon(
            onPressed: () => _generateMonthlyReport(),
            icon: const Icon(LucideIcons.chartColumn, size: 18),
            label: const Text('Monthly Report'),
          ),
        ],
      ),
    );
  }

  Widget _headerMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(
          title: 'Attendance Records',
          subtitle: 'View and manage attendance history',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportAttendance(),
                icon: const Icon(LucideIcons.download, size: 18),
                label: const Text('Export'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _generateMonthlyReport(),
                icon: const Icon(LucideIcons.chartColumn, size: 18),
                label: const Text('Monthly'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= FILTER SECTION =================

  Widget _filterSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(width: 280, child: _searchField()),
        SizedBox(
          width: 220,
          child: Obx(() => _filterTypeToggle()),
        ),
        SizedBox(
          width: 200,
          child: Obx(() => controller.attendanceFilterType.value == 'date'
              ? _datePickerField()
              : _monthPickerField()),
        ),
        _statusFilter(),
      ],
    );
  }

  Widget _filterSectionMobile() {
    return Column(
      children: [
        _searchField(),
        const SizedBox(height: 8),
        Obx(() => _filterTypeToggle()),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(() => controller.attendanceFilterType.value == 'date'
                  ? _datePickerField()
                  : _monthPickerField()),
            ),
            const SizedBox(width: 8),
            _statusFilter(),
          ],
        ),
      ],
    );
  }

  Widget _searchField() {
    return AppSearchField(
      hint: 'Search by HP name or ID...',
      onChanged: (value) {},
    );
  }

  Widget _filterTypeToggle() {
    final filterType = controller.attendanceFilterType.value;

    Widget segment(String label, String value) {
      final selected = filterType == value;
      return Expanded(
        child: InkWell(
          onTap: () => controller.attendanceFilterType.value = value,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColor.whiteColor : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColor.divColor : Colors.transparent,
              ),
              boxShadow: selected ? AppShadows.card : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColor.textPrimary : AppColor.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          segment('By Date', 'date'),
          const SizedBox(width: 2),
          segment('By Month', 'month'),
        ],
      ),
    );
  }

  Widget _datePickerField() {
    return Obx(() => _PickerBox(
          icon: LucideIcons.calendar,
          text: DateFormat('dd MMM yyyy').format(controller.attendanceFilterDate.value),
          onTap: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: controller.attendanceFilterDate.value,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColor.cPrimaryButtonColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.attendanceFilterDate.value = picked;
              _fetchAttendanceByDate(picked);
            }
          },
        ));
  }

  Widget _monthPickerField() {
    return Obx(() => _PickerBox(
          icon: LucideIcons.calendarDays,
          text: DateFormat('MMMM yyyy').format(controller.attendanceFilterMonth.value),
          onTap: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: controller.attendanceFilterMonth.value,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDatePickerMode: DatePickerMode.year,
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColor.cPrimaryButtonColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.attendanceFilterMonth.value = picked;
              _fetchAttendanceByMonth(picked);
            }
          },
        ));
  }

  Widget _statusFilter() {
    return Obx(() => SizedBox(
          // Fixed width: the dropdown expands to fill its parent and sits in
          // a Row/Wrap, which would otherwise give it unbounded width.
          width: SizeConfig.isMobile ? 136 : 160,
          child: AppDropdown<String>(
            hint: 'All Status',
            height: 40,
            isDense: true,
            value: controller.attendanceStatusFilter.value == 'all'
                ? null
                : controller.attendanceStatusFilter.value,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Status')),
              DropdownMenuItem(value: 'present', child: Text('Present')),
              DropdownMenuItem(value: 'absent', child: Text('Absent')),
              DropdownMenuItem(value: 'half_day', child: Text('Half Day')),
              DropdownMenuItem(value: 'leave', child: Text('Leave')),
            ],
            onChanged: (v) {
              controller.attendanceStatusFilter.value = v ?? 'all';
            },
          ),
        ));
  }

  // ================= SUMMARY =================

  Widget _summaryCards() {
    return Obx(() {
      final s = _getAttendanceStats();
      return AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: [
          AppStatCard(
            label: 'Total Present',
            value: '${s['present']!}',
            icon: LucideIcons.circleCheck,
            tone: toneForStatus('present'),
          ),
          AppStatCard(
            label: 'Total Absent',
            value: '${s['absent']!}',
            icon: LucideIcons.circleX,
            tone: toneForStatus('absent'),
          ),
          AppStatCard(
            label: 'Half Day',
            value: '${s['halfDay']!}',
            icon: LucideIcons.clock,
            tone: toneForStatus('half_day'),
          ),
          AppStatCard(
            label: 'On Leave',
            value: '${s['leave']!}',
            icon: LucideIcons.calendarX,
            tone: toneForStatus('leave'),
          ),
        ],
      );
    });
  }

  Widget _summaryCardsMobile() {
    return Obx(() {
      final s = _getAttendanceStats();
      return AppResponsiveGrid(
        minItemWidth: 140,
        maxColumns: 4,
        spacing: 8,
        children: [
          _CompactStat(
            label: 'Present',
            count: s['present']!,
            icon: LucideIcons.circleCheck,
            tone: toneForStatus('present'),
          ),
          _CompactStat(
            label: 'Absent',
            count: s['absent']!,
            icon: LucideIcons.circleX,
            tone: toneForStatus('absent'),
          ),
          _CompactStat(
            label: 'Half Day',
            count: s['halfDay']!,
            icon: LucideIcons.clock,
            tone: toneForStatus('half_day'),
          ),
          _CompactStat(
            label: 'On Leave',
            count: s['leave']!,
            icon: LucideIcons.calendarX,
            tone: toneForStatus('leave'),
          ),
        ],
      );
    });
  }

  // ================= TABLE (DESKTOP) =================

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: const Row(
        children: [
          _HeaderCell('HP ID', flex: 1),
          _HeaderCell('Name', flex: 2),
          _HeaderCell('Date', flex: 2),
          _HeaderCell('Check In', flex: 1),
          _HeaderCell('Check Out', flex: 1),
          _HeaderCell('Working Hours', flex: 2),
          _HeaderCell('Status', flex: 2),
          _HeaderCell('Marked By', flex: 2),
        ],
      ),
    );
  }

  Widget _attendanceListTable() {
    return Obx(() {
      if (controller.isAttendanceListLoading.value) {
        return const ShimmerLoader.table();
      }

      final statusFilter = controller.attendanceStatusFilter.value;
      final records = controller.attendanceList
          .whereType<Map<String, dynamic>>()
          .map((e) => AttendanceModel.fromJson(e))
          .where((m) => statusFilter == 'all' || m.attDetails.status == statusFilter)
          .map(_toDisplayRecord)
          .toList();

      if (records.isEmpty) {
        return _emptyState();
      }

      return ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) => _attendanceRecordRow(records[index]),
      );
    });
  }

  Widget _attendanceRecordRow(AttendanceRecord record) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          _DataCell(
            'HP-${record.cgId.toString().padLeft(3, '0')}',
            flex: 1,
            color: AppColor.cPrimaryButtonColor,
            isBold: true,
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  AppAvatar(name: record.cgName, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.cgName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _DataCell(record.date, flex: 2),
          _DataCell(record.checkIn, flex: 1),
          _DataCell(record.checkOut, flex: 1),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Icon(LucideIcons.clock,
                      size: 16, color: AppColor.textTertiary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      record.workingHours,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColor.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(record.status),
            ),
          ),
          _DataCell(record.markedBy, flex: 2),
        ],
      ),
    );
  }

  // ================= CARD LIST (MOBILE) =================

  Widget _attendanceCardList() {
    return Obx(() {
      if (controller.isAttendanceListLoading.value) {
        return const ShimmerLoader.cardList();
      }

      final statusFilter = controller.attendanceStatusFilter.value;
      final records = controller.attendanceList
          .whereType<Map<String, dynamic>>()
          .map((e) => AttendanceModel.fromJson(e))
          .where((m) => statusFilter == 'all' || m.attDetails.status == statusFilter)
          .map(_toDisplayRecord)
          .toList();

      if (records.isEmpty) {
        return _emptyState();
      }

      return ListView.separated(
        itemCount: records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _attendanceCard(records[index]),
      );
    });
  }

  Widget _attendanceCard(AttendanceRecord record) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HP ID + Name + Status
          Row(
            children: [
              AppAvatar(name: record.cgName, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.cgName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HP-${record.cgId.toString().padLeft(3, '0')}',
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
              _statusBadgeMobile(record.status),
            ],
          ),
          Divider(height: 24, color: AppColor.borderSubtle),

          // Date
          Row(
            children: [
              Icon(LucideIcons.calendar,
                  size: 14, color: AppColor.textTertiary),
              const SizedBox(width: 6),
              Text(record.date,
                  style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary)),
              const Spacer(),
              Icon(LucideIcons.user,
                  size: 14, color: AppColor.textTertiary),
              const SizedBox(width: 4),
              Text('Marked by ${record.markedBy}',
                  style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),

          // Check In / Check Out / Working Hours
          Row(
            children: [
              Expanded(
                child: _infoTile('Check In', record.checkIn, LucideIcons.logIn),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoTile('Check Out', record.checkOut, LucideIcons.logOut),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoTile(
                    'Hours', record.workingHours, LucideIcons.clock),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColor.textTertiary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: AppColor.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary)),
        ],
      ),
    );
  }

  // ================= STATUS BADGE =================

  Widget _statusBadge(String status) => AppStatusBadge.status(status);

  Widget _statusBadgeMobile(String status) =>
      AppStatusBadge.status(status, dense: true);

  // ================= EMPTY STATE =================

  Widget _emptyState() {
    return AppEmptyState(
      icon: LucideIcons.calendarX,
      title: 'No attendance records found',
      message: 'Try selecting a different date or filter',
      compact: SizeConfig.isMobile,
    );
  }

  // ================= HELPERS =================

  AttendanceRecord _toDisplayRecord(AttendanceModel m) {
    final d = m.attDetails;
    String statusLabel;
    switch (d.status) {
      case 'present':  statusLabel = 'Present';  break;
      case 'absent':   statusLabel = 'Absent';   break;
      case 'half_day': statusLabel = 'Half Day'; break;
      case 'leave':    statusLabel = 'Leave';    break;
      default:         statusLabel = 'Not Marked';
    }
    final hrs = d.workingHours;
    final hrsLabel = hrs > 0
        ? '${hrs.floor()}h ${((hrs % 1) * 60).round()}m'
        : '--';
    return AttendanceRecord(
      cgId:         m.hpId,
      cgName:       m.hpName.isNotEmpty ? m.hpName : 'HP-${m.hpId}',
      date:         m.fromDate.isNotEmpty
          ? DateFormat('dd MMM yyyy').format(
              DateTime.tryParse(m.fromDate) ?? DateTime.now())
          : '--',
      checkIn:      d.checkIn ?? '--',
      checkOut:     d.checkOut ?? '--',
      workingHours: hrsLabel,
      status:       statusLabel,
      markedBy:     'Admin',
    );
  }

  Map<String, int> _getAttendanceStats() {
    final list = controller.attendanceList
        .whereType<Map<String, dynamic>>()
        .map((e) => AttendanceModel.fromJson(e))
        .toList();
    return {
      'present': list.where((r) => r.attDetails.status == 'present').length,
      'absent':  list.where((r) => r.attDetails.status == 'absent').length,
      'halfDay': list.where((r) => r.attDetails.status == 'half_day').length,
      'leave':   list.where((r) => r.attDetails.status == 'leave').length,
    };
  }

  void _fetchAttendanceByDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    controller.getAttendanceListFromApi(fromDate: dateStr, toDate: dateStr);
  }

  void _fetchAttendanceByMonth(DateTime month) {
    final from = DateFormat('yyyy-MM-dd').format(
        DateTime(month.year, month.month, 1));
    final to = DateFormat('yyyy-MM-dd').format(
        DateTime(month.year, month.month + 1, 0));
    controller.getAttendanceListFromApi(fromDate: from, toDate: to);
  }

  void _exportAttendance() {
    Get.snackbar(
      'Export',
      'Attendance report exported successfully',
      backgroundColor: AppColor.lightGreen.withValues(alpha: 0.1),
      colorText: AppColor.lightGreen,
    );
  }

  void _generateMonthlyReport() {
    Get.dialog(
      AppDialog(
        title: 'Generate Monthly Report',
        subtitle: 'Select month to generate attendance report',
        icon: LucideIcons.chartColumn,
        maxWidth: 440,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Monthly report generated successfully',
                backgroundColor:
                    AppColor.lightGreen.withValues(alpha: 0.1),
                colorText: AppColor.lightGreen,
              );
            },
            child: const Text('Generate'),
          ),
        ],
        child: AppDropdownFormField<String>(
          hint: 'Select Month',
          items: List.generate(12, (index) {
            final month = DateTime(2024, index + 1);
            return DropdownMenuItem(
              value: DateFormat('MMMM yyyy').format(month),
              child: Text(DateFormat('MMMM yyyy').format(month)),
            );
          }),
          onChanged: (value) {},
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Obx(() => Text(
                'Showing ${controller.attendanceList.length} attendance records',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
              )),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              tooltip: 'Previous page',
              icon: const Icon(LucideIcons.chevronLeft, size: 20),
              color: AppColor.textSecondary,
              visualDensity: VisualDensity.compact,
            ),
            Text('Page 1 of 1',
                style: TextStyle(fontSize: 13, color: AppColor.textSecondary)),
            IconButton(
              onPressed: () {},
              tooltip: 'Next page',
              icon: const Icon(LucideIcons.chevronRight, size: 20),
              color: AppColor.textSecondary,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }
}

// ================= MODELS =================
class AttendanceRecord {
  final int cgId;
  final String cgName;
  final String date;
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final String status;
  final String markedBy;

  AttendanceRecord({
    required this.cgId,
    required this.cgName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    required this.status,
    required this.markedBy,
  });
}

// ================= REUSABLE WIDGETS =================
class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AppColor.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  final bool isBold;

  const _DataCell(
    this.text, {
    required this.flex,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.5,
            color: color ?? AppColor.textPrimary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// 40px read-only field that opens a picker (date/month) on tap.
/// Must sit in a width-bounded parent.
class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColor.borderStrong),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: AppColor.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small KPI tile for phones, where full [AppStatCard]s would leave no room
/// for the list below.
class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.label,
    required this.count,
    required this.icon,
    required this.tone,
  });

  final String label;
  final int count;
  final IconData icon;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppIconTile(icon: icon, tone: tone, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
