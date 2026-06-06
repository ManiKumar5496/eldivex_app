import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/register_cg_controller.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../widgets/dropdown_common.dart';
import '../models/get_cg_details_model.dart';

class MarkAttendanceView extends GetView<RegisterCgController> {
  const MarkAttendanceView({super.key});

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
        _dateAndSearchSection(),
        const SizedBox(height: 24),
        _summaryCards(),
        const SizedBox(height: 24),
        _tableHeader(),
        Expanded(child: _cgAttendanceTable()),
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
        _dateAndSearchSectionMobile(),
        const SizedBox(height: 16),
        _summaryCardsMobile(),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Attendance List', style: AppTextStyles.semiBold16),
            const Spacer(),
            Obx(() => Text(
                  '${controller.activeCgList.length} HPs',
                  style: AppTextStyles.regular14Gre,
                )),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(child: _cgAttendanceCardList()),
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
              Text('Mark Attendance', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Mark daily attendance for health professionals',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export'),
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
              onPressed: () => _submitAttendance(),
              icon: const Icon(Icons.check, color: Colors.white, size: 18),
              label: const Text('Submit Attendance',
                  style: TextStyle(color: Colors.white)),
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
        Text('Mark Attendance',
            style: AppTextStyles.heading.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          'Mark daily attendance for health professionals',
          style: AppTextStyles.regular14Gre,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
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
                onPressed: () => _submitAttendance(),
                icon: const Icon(Icons.check, color: Colors.white, size: 16),
                label: const Text('Submit',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
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

  // ================= DATE & SEARCH =================

  Widget _dateAndSearchSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _searchField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _datePickerField(),
        ),
        const SizedBox(width: 16),
        _filterChip('All HP'),
      ],
    );
  }

  Widget _dateAndSearchSectionMobile() {
    return Column(
      children: [
        _searchField(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _datePickerField()),
            const SizedBox(width: 8),
            _filterChip('All HP'),
          ],
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      onChanged: (v) => controller.markAttendanceSearch.value = v,
      decoration: InputDecoration(
        hintText: 'Search by name, ID...',
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
    );
  }

  Widget _datePickerField() {
    return Obx(() => InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: controller.markAttendanceSelectedDate.value,
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
              controller.markAttendanceSelectedDate.value = picked;
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
                  DateFormat('dd/MM/yyyy').format(
                      controller.markAttendanceSelectedDate.value),
                  style: AppTextStyles.regular14black,
                ),
                Icon(Icons.calendar_today,
                    size: 16, color: AppColor.fontColorGrey),
              ],
            ),
          ),
        ));
  }

  Widget _filterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.regular14black),
          const SizedBox(width: 8),
          Icon(Icons.arrow_drop_down, size: 20, color: AppColor.fontColorGrey),
        ],
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryCards() {
    return Obx(() {
      final attendanceData = _getAttendanceSummary();
      return Row(
        children: [
          _summaryCard('Total HP', controller.activeCgList.length,
              Icons.people, AppColor.cPrimaryButtonColor),
          _summaryCard('Present', attendanceData['present']!,
              Icons.check_circle, AppColor.lightGreen),
          _summaryCard('Absent', attendanceData['absent']!, Icons.cancel,
              AppColor.calenderRed),
          _summaryCard('Not Marked', attendanceData['notMarked']!,
              Icons.remove_circle, Colors.grey),
        ],
      );
    });
  }

  Widget _summaryCardsMobile() {
    return Obx(() {
      final attendanceData = _getAttendanceSummary();
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryCardMobile('Total HP',
                    controller.activeCgList.length, Icons.people,
                    AppColor.cPrimaryButtonColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryCardMobile('Present',
                    attendanceData['present']!, Icons.check_circle,
                    AppColor.lightGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _summaryCardMobile('Absent',
                    attendanceData['absent']!, Icons.cancel,
                    AppColor.calenderRed),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryCardMobile('Not Marked',
                    attendanceData['notMarked']!, Icons.remove_circle,
                    Colors.grey),
              ),
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
                Text('$count',
                    style: AppTextStyles.semiBold16),
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
          _HeaderCell('Contact', flex: 2),
          _HeaderCell('Check In', flex: 2),
          _HeaderCell('Check Out', flex: 2),
          _HeaderCell('Shift Type', flex: 2),
          _HeaderCell('Status', flex: 2),
          _HeaderCell('Actions', flex: 2),
        ],
      ),
    );
  }

  Widget _cgAttendanceTable() {
    return Obx(() {
      if (controller.getAllCGLoading.value) {
        return const ShimmerLoader.table();
      }

      final q = controller.markAttendanceSearch.value.trim().toLowerCase();
      final cgList = q.isEmpty
          ? controller.activeCgList
          : controller.activeCgList.where((cg) {
              final name = '${cg.hpRegFirstName} ${cg.hpRegLastName}'.toLowerCase();
              final id = 'hp-${cg.hpRegId.toString().padLeft(3, '0')}';
              return name.contains(q) || id.contains(q) || cg.hpRegPhoneNumber.contains(q);
            }).toList();

      if (cgList.isEmpty) {
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
          itemCount: cgList.length,
          itemBuilder: (context, index) {
            final cg = cgList[index];
            return _attendanceRow(cg, index);
          },
        ),
      );
    });
  }

  Widget _attendanceRow(GetCgDetails cg, int index) {
    final draft = controller.attendanceDraft[cg.hpRegId] ?? {
      'status': 'not_marked',
      'shift_type': 'live_out',
      'check_in': null,
      'check_out': null,
    };
    final attendanceStatus = RxString(draft['status'] as String? ?? 'not_marked');
    final shiftType        = RxString(draft['shift_type'] as String? ?? 'live_out');
    final checkInTime      = Rx<TimeOfDay?>(_parseTime(draft['check_in'] as String?));
    final checkOutTime     = Rx<TimeOfDay?>(_parseTime(draft['check_out'] as String?));

    void syncDraft() {
      controller.attendanceDraft[cg.hpRegId] = {
        'status':     attendanceStatus.value,
        'shift_type': shiftType.value,
        'check_in':   checkInTime.value != null ? _fmtTime(checkInTime.value!) : null,
        'check_out':  checkOutTime.value != null ? _fmtTime(checkOutTime.value!) : null,
      };
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        children: [
          _DataCell(
            'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
            flex: 1,
            color: AppColor.cPrimaryButtonColor,
            isBold: true,
          ),
          _DataCell('${cg.hpRegFirstName} ${cg.hpRegLastName}', flex: 2),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cg.hpRegEmail,
                    style: AppTextStyles.regular14black,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(cg.hpRegPhoneNumber, style: AppTextStyles.regular12Gre),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Obx(() => _timePickerButton(
                  checkInTime.value,
                  'Check In',
                  (time) { checkInTime.value = time; syncDraft(); },
                )),
          ),
          Expanded(
            flex: 2,
            child: Obx(() => _timePickerButton(
                  checkOutTime.value,
                  'Check Out',
                  (time) { checkOutTime.value = time; syncDraft(); },
                )),
          ),
          Expanded(
            flex: 2,
            child: Obx(() => _shiftTypeDropdown(shiftType, onChanged: syncDraft)),
          ),
          Expanded(
            flex: 2,
            child: Obx(() => _statusDropdown(attendanceStatus, onChanged: syncDraft)),
          ),
          Expanded(
            flex: 2,
            child: _actionButtons(cg, attendanceStatus, shiftType, checkInTime, checkOutTime),
          ),
        ],
      ),
    );
  }

  // ================= CARD LIST (MOBILE) =================

  Widget _cgAttendanceCardList() {
    return Obx(() {
      if (controller.getAllCGLoading.value) {
        return const ShimmerLoader.cardList();
      }

      final q = controller.markAttendanceSearch.value.trim().toLowerCase();
      final cgList = q.isEmpty
          ? controller.activeCgList
          : controller.activeCgList.where((cg) {
              final name = '${cg.hpRegFirstName} ${cg.hpRegLastName}'.toLowerCase();
              final id = 'hp-${cg.hpRegId.toString().padLeft(3, '0')}';
              return name.contains(q) || id.contains(q) || cg.hpRegPhoneNumber.contains(q);
            }).toList();

      if (cgList.isEmpty) {
        return _emptyState();
      }

      return ListView.separated(
        itemCount: cgList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final cg = cgList[index];
          return _attendanceCard(cg, index);
        },
      );
    });
  }

  Widget _attendanceCard(GetCgDetails cg, int index) {
    controller.attendanceDraft.putIfAbsent(cg.hpRegId, () => {
      'status': 'not_marked',
      'shift_type': 'live_out',
      'check_in': null,
      'check_out': null,
    });

    final draft = controller.attendanceDraft[cg.hpRegId]!;
    final attendanceStatus = RxString(draft['status'] as String? ?? 'not_marked');
    final shiftType        = RxString(draft['shift_type'] as String? ?? 'live_out');
    final checkInTime      = Rx<TimeOfDay?>(_parseTime(draft['check_in'] as String?));
    final checkOutTime     = Rx<TimeOfDay?>(_parseTime(draft['check_out'] as String?));

    void syncDraft() {
      controller.attendanceDraft[cg.hpRegId] = {
        'status':     attendanceStatus.value,
        'shift_type': shiftType.value,
        'check_in':   checkInTime.value != null ? _fmtTime(checkInTime.value!) : null,
        'check_out':  checkOutTime.value != null ? _fmtTime(checkOutTime.value!) : null,
      };
    }

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
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
                  '${cg.hpRegFirstName} ${cg.hpRegLastName}',
                  style: AppTextStyles.semiBold16.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 14, color: AppColor.fontColorGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(cg.hpRegEmail,
                    style: AppTextStyles.regular12Gre,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 14, color: AppColor.fontColorGrey),
              const SizedBox(width: 6),
              Text(cg.hpRegPhoneNumber, style: AppTextStyles.regular12Gre),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Obx(() => _timePickerButtonMobile(
                      checkInTime.value, 'Check In',
                      (t) { checkInTime.value = t; syncDraft(); }, Icons.login)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => _timePickerButtonMobile(
                      checkOutTime.value, 'Check Out',
                      (t) { checkOutTime.value = t; syncDraft(); }, Icons.logout)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() => _shiftTypeDropdown(shiftType, onChanged: syncDraft)),
          const SizedBox(height: 10),
          Obx(() => _statusDropdownMobile(attendanceStatus, onChanged: syncDraft)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isMarkCgAttendanceLoading.value
                  ? null
                  : () {
                      if (attendanceStatus.value == 'not_marked') {
                        Get.snackbar('Error', 'Please select attendance status',
                            backgroundColor: AppColor.calenderRed.withValues(alpha: 0.1),
                            colorText: AppColor.calenderRed);
                      } else {
                        _markAttendance(cg, attendanceStatus.value, shiftType.value,
                            checkInTime.value, checkOutTime.value);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.lightGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Mark Attendance',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            )),
          ),
        ],
      ),
    );
  }

  // ================= TIME PICKER =================

  Widget _timePickerButton(
      TimeOfDay? time, String label, Function(TimeOfDay) onTimePicked) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: Get.context!,
          initialTime: time ?? TimeOfDay.now(),
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
          onTimePicked(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.fieldColorGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time,
                size: 16, color: AppColor.cPrimaryButtonColor),
            const SizedBox(width: 8),
            Text(
              time != null ? time.format(Get.context!) : label,
              style: AppTextStyles.regular14black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePickerButtonMobile(TimeOfDay? time, String label,
      Function(TimeOfDay) onTimePicked, IconData icon) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: Get.context!,
          initialTime: time ?? TimeOfDay.now(),
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
          onTimePicked(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.fieldColorGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColor.cPrimaryButtonColor),
            const SizedBox(width: 8),
            Text(
              time != null ? time.format(Get.context!) : label,
              style: TextStyle(
                fontSize: 13,
                color: time != null
                    ? AppColor.fontColorBlack
                    : AppColor.fontColorGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STATUS DROPDOWN =================

  Widget _shiftTypeDropdown(RxString shiftType, {VoidCallback? onChanged}) {
    return AppDropdownFormField<String>(
      hint: 'Shift Type',
      value: shiftType.value,
      items: const [
        DropdownMenuItem(value: 'live_out', child: Text('Live Out')),
        DropdownMenuItem(value: 'live_in',  child: Text('Live In')),
      ],
      onChanged: (value) {
        if (value != null) { shiftType.value = value; onChanged?.call(); }
      },
    );
  }

  Widget _statusDropdown(RxString status, {VoidCallback? onChanged}) {
    return AppDropdownFormField<String>(
      hint: 'Select Status',
      value: status.value,
      items: const [
        DropdownMenuItem(value: 'not_marked', child: Text('Not Marked')),
        DropdownMenuItem(value: 'present',    child: Text('Present')),
        DropdownMenuItem(value: 'absent',     child: Text('Absent')),
        DropdownMenuItem(value: 'half_day',   child: Text('Half Day')),
        DropdownMenuItem(value: 'leave',      child: Text('Leave')),
      ],
      onChanged: (value) {
        if (value != null) { status.value = value; onChanged?.call(); }
      },
    );
  }

  Widget _statusDropdownMobile(RxString status, {VoidCallback? onChanged}) {
    return AppDropdownFormField<String>(
      label: 'Status',
      hint: 'Select Status',
      value: status.value,
      items: const [
        DropdownMenuItem(value: 'not_marked', child: Text('Not Marked')),
        DropdownMenuItem(value: 'present',    child: Text('Present')),
        DropdownMenuItem(value: 'absent',     child: Text('Absent')),
        DropdownMenuItem(value: 'half_day',   child: Text('Half Day')),
        DropdownMenuItem(value: 'leave',      child: Text('Leave')),
      ],
      onChanged: (value) {
        if (value != null) { status.value = value; onChanged?.call(); }
      },
    );
  }

  // ================= ACTION BUTTONS (DESKTOP) =================

  Widget _actionButtons(
      GetCgDetails cg,
      RxString status,
      RxString shiftType,
      Rx<TimeOfDay?> checkIn,
      Rx<TimeOfDay?> checkOut) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isMarkCgAttendanceLoading.value
                ? null
                : () {
                    if (status.value == 'not_marked') {
                      Get.snackbar(
                        'Error',
                        'Please select attendance status',
                        backgroundColor: AppColor.calenderRed.withValues(alpha: 0.1),
                        colorText: AppColor.calenderRed,
                      );
                    } else {
                      _markAttendance(cg, status.value, shiftType.value,
                          checkIn.value, checkOut.value);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.lightGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Mark',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          )),
        ),
      ],
    );
  }

  // ================= EMPTY STATE =================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: SizeConfig.isMobile ? 48 : 64, color: AppColor.divColor),
          const SizedBox(height: 16),
          Text('No Health Professionals found', style: AppTextStyles.regular14Gre),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Map<String, int> _getAttendanceSummary() {
    final draft = controller.attendanceDraft;
    int present = 0, absent = 0, notMarked = 0;
    for (final cg in controller.activeCgList) {
      final status = draft[cg.hpRegId]?['status'] as String? ?? 'not_marked';
      if (status == 'present' || status == 'half_day') {
        present++;
      } else if (status == 'absent' || status == 'leave') {
        absent++;
      } else {
        notMarked++;
      }
    }
    return {'present': present, 'absent': absent, 'notMarked': notMarked};
  }

  void _markAttendance(
      GetCgDetails cg,
      String status,
      String shiftType,
      TimeOfDay? checkIn,
      TimeOfDay? checkOut) {
    controller.markCgAttendance(
      bookingId:      controller.activeHpBookingIdMap[cg.hpRegId] ?? 0,
      attendanceDate: controller.markAttendanceSelectedDate.value,
      cgId:           cg.hpRegId.toString(),
      invoiceId:      0,
      status:         status,
      shiftType:      shiftType,
      checkIn:        checkIn,
      checkOut:       checkOut,
    );
  }

  void _submitAttendance() {
    final pending = controller.attendanceDraft.entries
        .where((e) => (e.value['status'] as String?) != 'not_marked')
        .toList();

    if (pending.isEmpty) {
      Get.snackbar('Nothing to submit', 'Mark at least one HP before submitting.',
          backgroundColor: AppColor.calenderRed.withValues(alpha: 0.1),
          colorText: AppColor.calenderRed);
      return;
    }

    final isMobile = SizeConfig.isMobile;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                child: Icon(Icons.check_circle_outline,
                    size: 32, color: AppColor.cPrimaryButtonColor),
              ),
              const SizedBox(height: 16),
              Text('Confirm Submission', style: AppTextStyles.semiBold18),
              const SizedBox(height: 8),
              Text(
                'Submit attendance for ${pending.length} HP(s)?',
                style: AppTextStyles.regular14Gre,
                textAlign: TextAlign.center,
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
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        for (final entry in pending) {
                          final hpId    = entry.key;
                          final d       = entry.value;
                          final cgMatch = controller.activeCgList
                              .firstWhereOrNull((c) => c.hpRegId == hpId);
                          if (cgMatch == null) continue;
                          controller.markCgAttendance(
                            bookingId:      controller.activeHpBookingIdMap[hpId] ?? 0,
                            attendanceDate: controller.markAttendanceSelectedDate.value,
                            cgId:           hpId.toString(),
                            invoiceId:      0,
                            status:         d['status'] as String? ?? 'present',
                            shiftType:      d['shift_type'] as String? ?? 'live_out',
                            checkIn:        _parseTime(d['check_in'] as String?),
                            checkOut:       _parseTime(d['check_out'] as String?),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Submit'),
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

  TimeOfDay? _parseTime(String? s) {
    if (s == null || s.isEmpty) { return null; }
    final parts = s.split(':');
    if (parts.length != 2) { return null; }
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) { return null; }
    return TimeOfDay(hour: h, minute: m);
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _footer() {
    return Obx(() {
      final q = controller.markAttendanceSearch.value.trim().toLowerCase();
      final total = controller.activeCgList.length;
      final showing = q.isEmpty
          ? total
          : controller.activeCgList
              .where((cg) {
                final name = '${cg.hpRegFirstName} ${cg.hpRegLastName}'.toLowerCase();
                final id = 'hp-${cg.hpRegId.toString().padLeft(3, '0')}';
                return name.contains(q) || id.contains(q) || cg.hpRegPhoneNumber.contains(q);
              })
              .length;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          q.isEmpty
              ? 'Showing $total health professionals'
              : 'Showing $showing of $total health professionals',
          style: AppTextStyles.regular14Gre,
        ),
      );
    });
  }
}

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
