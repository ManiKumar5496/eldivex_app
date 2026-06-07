import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/register_cg_controller.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../widgets/dropdown_common.dart';
import '../models/attendance_model.dart';

class AttendanceListView extends GetView<RegisterCgController> {
  const AttendanceListView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.isMobile;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: isMobile ? _mobileBody() : _desktopBody(),
      ),
    );
  }

  // ================= DESKTOP BODY =================

  Widget _desktopBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 24),
        _filterSection(),
        const SizedBox(height: 24),
        _summaryCards(),
        const SizedBox(height: 24),
        _tableHeader(),
        Expanded(child: _attendanceListTable()),
        _footer(),
      ],
    );
  }

  // ================= MOBILE BODY =================

  Widget _mobileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerMobile(),
        const SizedBox(height: 16),
        _filterSectionMobile(),
        const SizedBox(height: 16),
        _summaryCardsMobile(),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Attendance Records', style: AppTextStyles.semiBold16),
            const Spacer(),
            Obx(() => Text(
                  '${controller.attendanceList.length} records',
                  style: AppTextStyles.regular12Gre,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance Records', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'View and manage attendance history',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _exportAttendance(),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.fontColorBlack,
                side: BorderSide(color: AppColor.divColor),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _generateMonthlyReport(),
              icon: Icon(Icons.assessment, color: AppColor.buttonTextWhite, size: 18),
              label: Text('Monthly Report',
                  style: TextStyle(color: AppColor.buttonTextWhite)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _headerMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Records',
            style: AppTextStyles.heading.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          'View and manage attendance history',
          style: AppTextStyles.regular14Gre,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportAttendance(),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.fontColorBlack,
                  side: BorderSide(color: AppColor.divColor),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _generateMonthlyReport(),
                icon:
                    Icon(Icons.assessment, color: AppColor.buttonTextWhite, size: 16),
                label: Text('Monthly',
                    style: TextStyle(color: AppColor.buttonTextWhite, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= FILTER SECTION =================

  Widget _filterSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _searchField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() => _filterTypeToggle()),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() => controller.attendanceFilterType.value == 'date'
              ? _datePickerField()
              : _monthPickerField()),
        ),
        const SizedBox(width: 16),
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
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by HP name or ID...',
        hintStyle: AppTextStyles.regular14Gre,
        prefixIcon: Icon(Icons.search, color: AppColor.fontColorGrey, size: 20),
        filled: true,
        fillColor: AppColor.whiteColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.divColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.divColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.cPrimaryButtonColor),
        ),
      ),
      onChanged: (value) {},
    );
  }

  Widget _filterTypeToggle() {
    final isMobile = SizeConfig.isMobile;
    final filterType = controller.attendanceFilterType.value;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => controller.attendanceFilterType.value = 'date',
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: filterType == 'date'
                      ? AppColor.cPrimaryButtonColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'By Date',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: filterType == 'date'
                          ? AppColor.buttonTextWhite
                          : AppColor.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => controller.attendanceFilterType.value = 'month',
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: filterType == 'month'
                      ? AppColor.cPrimaryButtonColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'By Month',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: filterType == 'month'
                          ? AppColor.buttonTextWhite
                          : AppColor.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePickerField() {
    return Obx(() => InkWell(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.divColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(controller.attendanceFilterDate.value),
                  style: AppTextStyles.regular14black,
                ),
                Icon(Icons.calendar_today,
                    size: 16, color: AppColor.fontColorGrey),
              ],
            ),
          ),
        ));
  }

  Widget _monthPickerField() {
    return Obx(() => InkWell(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.divColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(controller.attendanceFilterMonth.value),
                  style: AppTextStyles.regular14black,
                ),
                Icon(Icons.calendar_today,
                    size: 16, color: AppColor.fontColorGrey),
              ],
            ),
          ),
        ));
  }

  Widget _statusFilter() {
    return Obx(() => SizedBox(
          width: SizeConfig.isMobile ? null : 148,
          child: AppDropdown<String>(
            hint: 'All Status',
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
      return Row(
        children: [
          _summaryCard('Total Present', s['present']!, Icons.check_circle, AppColor.lightGreen),
          _summaryCard('Total Absent',  s['absent']!,  Icons.cancel,        AppColor.calenderRed),
          _summaryCard('Half Day',      s['halfDay']!, Icons.access_time,   Colors.orange),
          _summaryCard('On Leave',      s['leave']!,   Icons.event_busy,    Colors.purple),
        ],
      );
    });
  }

  Widget _summaryCardsMobile() {
    return Obx(() {
      final s = _getAttendanceStats();
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _summaryCardMobile('Present', s['present']!, Icons.check_circle, AppColor.lightGreen)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCardMobile('Absent',  s['absent']!,  Icons.cancel,       AppColor.calenderRed)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _summaryCardMobile('Half Day', s['halfDay']!, Icons.access_time, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCardMobile('On Leave', s['leave']!,   Icons.event_busy,  Colors.purple)),
            ],
          ),
        ],
      );
    });
  }

  Widget _summaryCard(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.regular14Gre),
                const SizedBox(height: 4),
                Text('$count', style: AppTextStyles.bold20),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryCardMobile(
      String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.regular12Gre,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('$count', style: AppTextStyles.semiBold16),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= TABLE (DESKTOP) =================

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: AppColor.divColor),
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

      return Container(
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(12)),
          border: Border.all(color: AppColor.divColor),
        ),
        child: ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) => _attendanceRecordRow(records[index]),
        ),
      );
    });
  }

  Widget _attendanceRecordRow(AttendanceRecord record) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.divColor),
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
          _DataCell(record.cgName, flex: 2),
          _DataCell(record.date, flex: 2),
          _DataCell(record.checkIn, flex: 1),
          _DataCell(record.checkOut, flex: 1),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 16, color: AppColor.cPrimaryButtonColor),
                const SizedBox(width: 4),
                Text(record.workingHours,
                    style: AppTextStyles.regular14black),
              ],
            ),
          ),
          Expanded(flex: 2, child: _statusBadge(record.status)),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HP ID + Name + Status
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'HP-${record.cgId.toString().padLeft(3, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.cgName,
                  style: AppTextStyles.semiBold16.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _statusBadgeMobile(record.status),
            ],
          ),
          const Divider(height: 20),

          // Date
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: AppColor.fontColorGrey),
              const SizedBox(width: 6),
              Text(record.date, style: AppTextStyles.regular12Gre),
              const Spacer(),
              Icon(Icons.person_outline,
                  size: 14, color: AppColor.fontColorGrey),
              const SizedBox(width: 4),
              Text('Marked by ${record.markedBy}',
                  style: AppTextStyles.regular12Gre),
            ],
          ),
          const SizedBox(height: 10),

          // Check In / Check Out / Working Hours
          Row(
            children: [
              Expanded(
                child: _infoTile('Check In', record.checkIn, Icons.login),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoTile('Check Out', record.checkOut, Icons.logout),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoTile(
                    'Hours', record.workingHours, Icons.access_time),
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
        color: AppColor.fieldColorGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColor.fontColorGrey),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                fontSize: 11,
                color: AppColor.fontColorGrey,
              )),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ================= STATUS BADGE =================

  Widget _statusBadge(String status) {
    final (bg, fg, icon) = _getStatusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(status,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _statusBadgeMobile(String status) {
    final (bg, fg, icon) = _getStatusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w500, fontSize: 11)),
        ],
      ),
    );
  }

  (Color, Color, IconData) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return (
          AppColor.lightGreen.withValues(alpha: 0.15),
          AppColor.lightGreen,
          Icons.check_circle
        );
      case 'absent':
        return (
          AppColor.calenderRed.withValues(alpha: 0.15),
          AppColor.calenderRed,
          Icons.cancel
        );
      case 'half day':
        return (
          Colors.orange.withValues(alpha: 0.15),
          Colors.orange,
          Icons.access_time
        );
      case 'leave':
        return (
          Colors.purple.withValues(alpha: 0.15),
          Colors.purple,
          Icons.event_busy
        );
      default:
        return (
          Colors.grey.withValues(alpha: 0.15),
          AppColor.fontColorGrey,
          Icons.help_outline
        );
    }
  }

  // ================= EMPTY STATE =================

  Widget _emptyState() {
    final isMobile = SizeConfig.isMobile;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy,
              size: isMobile ? 48 : 64, color: AppColor.divColor),
          const SizedBox(height: 16),
          Text('No attendance records found',
              style: AppTextStyles.regular14Gre),
          const SizedBox(height: 8),
          Text('Try selecting a different date or filter',
              style: AppTextStyles.regular12Gre),
        ],
      ),
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
    final isMobile = SizeConfig.isMobile;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: isMobile ? double.infinity : 420,
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assessment,
                    size: 32, color: AppColor.cPrimaryButtonColor),
              ),
              const SizedBox(height: 16),
              Text('Generate Monthly Report',
                  style: AppTextStyles.semiBold18),
              const SizedBox(height: 8),
              Text(
                'Select month to generate attendance report',
                style: AppTextStyles.regular14Gre,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppDropdownFormField<String>(
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.fontColorBlack,
                        side: BorderSide(color: AppColor.divColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        foregroundColor: AppColor.buttonTextWhite,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Generate'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            'Showing ${controller.attendanceList.length} attendance records',
            style: AppTextStyles.regular14Gre,
          )),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left, size: 20),
                color: AppColor.cPrimaryButtonColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text('Page 1 of 1', style: AppTextStyles.regular14black),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, size: 20),
                color: AppColor.cPrimaryButtonColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
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
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.fontColorGrey,
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
      child: Text(
        text,
        style: AppTextStyles.regular14black.copyWith(
          color: color,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
