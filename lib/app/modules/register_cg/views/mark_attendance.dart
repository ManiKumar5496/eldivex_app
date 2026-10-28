import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/register_cg_controller.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../widgets/dropdown_common.dart';
import '../models/get_cg_details_model.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class MarkAttendanceView extends GetView<RegisterCgController> {
  const MarkAttendanceView({super.key});

  /// Below this width the desktop table scrolls horizontally instead of
  /// squeezing the time pickers and dropdowns.
  static const double _tableMinWidth = 1080;

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
                  child: _dateAndSearchSection(),
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
              Expanded(child: _cgAttendanceTable()),
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
        _dateAndSearchSectionMobile(),
        const SizedBox(height: 12),
        _summaryCardsMobile(),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Attendance List',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const Spacer(),
            Obx(() => Text(
                  '${controller.activeCgList.length} HPs',
                  style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
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
    return AppSectionTitle(
      title: 'Mark Attendance',
      subtitle: 'Mark daily attendance for health professionals',
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Export'),
          ),
          ElevatedButton.icon(
            onPressed: () => _submitAttendance(),
            icon: const Icon(LucideIcons.check, size: 18),
            label: const Text('Submit Attendance'),
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
          title: 'Mark Attendance',
          subtitle: 'Mark daily attendance for health professionals',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 18),
                label: const Text('Export'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submitAttendance(),
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text('Submit'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= DATE & SEARCH =================

  Widget _dateAndSearchSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(width: 320, child: _searchField()),
        SizedBox(width: 200, child: _datePickerField()),
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
    return AppSearchField(
      hint: 'Search by name, ID...',
      onChanged: (v) => controller.markAttendanceSearch.value = v,
    );
  }

  Widget _datePickerField() {
    return Obx(() => _PickerBox(
          icon: LucideIcons.calendar,
          text: DateFormat('dd/MM/yyyy')
              .format(controller.markAttendanceSelectedDate.value),
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
        ));
  }

  Widget _filterChip(String label) {
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
        children: [
          Icon(LucideIcons.listFilter,
              size: 18, color: AppColor.textTertiary),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary)),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronDown,
              size: 18, color: AppColor.textTertiary),
        ],
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryCards() {
    return Obx(() {
      final attendanceData = _getAttendanceSummary();
      return AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: [
          AppStatCard(
            label: 'Total HP',
            value: '${controller.activeCgList.length}',
            icon: LucideIcons.users,
            tone: AppTone.primary,
          ),
          AppStatCard(
            label: 'Present',
            value: '${attendanceData['present']!}',
            icon: LucideIcons.circleCheck,
            tone: AppTone.success,
          ),
          AppStatCard(
            label: 'Absent',
            value: '${attendanceData['absent']!}',
            icon: LucideIcons.circleX,
            tone: AppTone.danger,
          ),
          AppStatCard(
            label: 'Not Marked',
            value: '${attendanceData['notMarked']!}',
            icon: LucideIcons.circleMinus,
            tone: AppTone.neutral,
          ),
        ],
      );
    });
  }

  Widget _summaryCardsMobile() {
    return Obx(() {
      final attendanceData = _getAttendanceSummary();
      return AppResponsiveGrid(
        minItemWidth: 140,
        maxColumns: 4,
        spacing: 8,
        children: [
          _CompactStat(
            label: 'Total HP',
            count: controller.activeCgList.length,
            icon: LucideIcons.users,
            tone: AppTone.primary,
          ),
          _CompactStat(
            label: 'Present',
            count: attendanceData['present']!,
            icon: LucideIcons.circleCheck,
            tone: AppTone.success,
          ),
          _CompactStat(
            label: 'Absent',
            count: attendanceData['absent']!,
            icon: LucideIcons.circleX,
            tone: AppTone.danger,
          ),
          _CompactStat(
            label: 'Not Marked',
            count: attendanceData['notMarked']!,
            icon: LucideIcons.circleMinus,
            tone: AppTone.neutral,
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

      return ListView.builder(
        itemCount: cgList.length,
        itemBuilder: (context, index) {
          final cg = cgList[index];
          return _attendanceRow(cg, index);
        },
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

    final fullName = '${cg.hpRegFirstName} ${cg.hpRegLastName}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          _DataCell(
            'HP-${cg.hpRegId.toString().padLeft(3, '0')}',
            flex: 1,
            color: AppColor.cPrimaryButtonColor,
            isBold: true,
          ),
          _cell(
            flex: 2,
            child: Row(
              children: [
                AppAvatar(name: fullName, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fullName,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _cell(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cg.hpRegEmail,
                    style: TextStyle(fontSize: 13.5, color: AppColor.textPrimary),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(cg.hpRegPhoneNumber,
                    style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary)),
              ],
            ),
          ),
          _cell(
            flex: 2,
            child: Obx(() => _timePickerButton(
                  checkInTime.value,
                  'Check In',
                  (time) { checkInTime.value = time; syncDraft(); },
                )),
          ),
          _cell(
            flex: 2,
            child: Obx(() => _timePickerButton(
                  checkOutTime.value,
                  'Check Out',
                  (time) { checkOutTime.value = time; syncDraft(); },
                )),
          ),
          _cell(
            flex: 2,
            child: Obx(() => _shiftTypeDropdown(shiftType, onChanged: syncDraft)),
          ),
          _cell(
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

  /// Table cell with the same flex and right gutter as [_HeaderCell].
  Widget _cell({required int flex, required Widget child}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: child,
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

    final fullName = '${cg.hpRegFirstName} ${cg.hpRegLastName}';

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: fullName, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(LucideIcons.mail, size: 14, color: AppColor.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(cg.hpRegEmail,
                    style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.phone, size: 14, color: AppColor.textTertiary),
              const SizedBox(width: 6),
              Text(cg.hpRegPhoneNumber,
                  style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary)),
            ],
          ),
          Divider(height: 24, color: AppColor.borderSubtle),
          Row(
            children: [
              Expanded(
                child: Obx(() => _timePickerButtonMobile(
                      checkInTime.value, 'Check In',
                      (t) { checkInTime.value = t; syncDraft(); }, LucideIcons.logIn)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => _timePickerButtonMobile(
                      checkOutTime.value, 'Check Out',
                      (t) { checkOutTime.value = t; syncDraft(); }, LucideIcons.logOut)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() => _shiftTypeDropdown(shiftType, onChanged: syncDraft)),
          const SizedBox(height: 10),
          Obx(() => _statusDropdownMobile(attendanceStatus, onChanged: syncDraft)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final marking = controller.markingHpIds.contains(cg.hpRegId);
              return ElevatedButton(
                onPressed: marking
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
                child: marking
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.cAppPrimaryColor),
                      )
                    : const Text('Mark Attendance'),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ================= TIME PICKER =================

  Widget _timePickerButton(
      TimeOfDay? time, String label, Function(TimeOfDay) onTimePicked) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clock,
                size: 16, color: AppColor.textTertiary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                time != null ? time.format(Get.context!) : label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  color: time != null
                      ? AppColor.textPrimary
                      : AppColor.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePickerButtonMobile(TimeOfDay? time, String label,
      Function(TimeOfDay) onTimePicked, IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
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
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColor.borderStrong),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColor.textTertiary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                time != null ? time.format(Get.context!) : label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: time != null
                      ? AppColor.textPrimary
                      : AppColor.textTertiary,
                ),
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
          child: Obx(() {
            final marking = controller.markingHpIds.contains(cg.hpRegId);
            return TextButton(
              onPressed: marking
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
              style: AppButtonStyles.compact.merge(AppButtonStyles.soft),
              child: marking
                  ? SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.cAppPrimaryColor),
                    )
                  : const Text('Mark'),
            );
          }),
        ),
      ],
    );
  }

  // ================= EMPTY STATE =================

  Widget _emptyState() {
    return AppEmptyState(
      icon: LucideIcons.users,
      title: 'No Health Professionals found',
      compact: SizeConfig.isMobile,
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

    Get.dialog(
      AppDialog(
        title: 'Confirm Submission',
        icon: LucideIcons.circleCheck,
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
              // Build all records and submit them in ONE request
              // (server upserts), instead of N separate calls.
              final records = <Map<String, dynamic>>[];
              for (final entry in pending) {
                final hpId    = entry.key;
                final d       = entry.value;
                final cgMatch = controller.activeCgList
                    .firstWhereOrNull((c) => c.hpRegId == hpId);
                if (cgMatch == null) continue;
                final bookingId = controller.activeHpBookingIdMap[hpId] ?? 0;
                if (bookingId <= 0) continue; // no active booking → skip
                records.add(controller.buildAttendanceRecord(
                  bookingId:      bookingId,
                  attendanceDate: controller.markAttendanceSelectedDate.value,
                  cgId:           hpId.toString(),
                  invoiceId:      0,
                  status:         d['status'] as String? ?? 'present',
                  shiftType:      d['shift_type'] as String? ?? 'live_out',
                  checkIn:        _parseTime(d['check_in'] as String?),
                  checkOut:       _parseTime(d['check_out'] as String?),
                ));
              }
              controller.submitAttendanceBatch(records);
            },
            child: const Text('Submit'),
          ),
        ],
        child: Text(
          'Submit attendance for ${pending.length} HP(s)?',
          style: TextStyle(
              fontSize: 14, height: 1.5, color: AppColor.textSecondary),
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
      return Text(
        q.isEmpty
            ? 'Showing $total health professionals'
            : 'Showing $showing of $total health professionals',
        style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
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
