import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/common_textfield.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../widgets/dropdown_common.dart';
import '../../settings/models/get_discount_models.dart';
import '../controllers/bookings_controller.dart';
import '../../support/views/create_support_ticket.dart';
import 'assign_cg_dialog.dart';
import 'cg_review_detail_screen.dart';
import 'edit_booking_view.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ManageBookingView extends StatefulWidget {
  final int bookingId;

  const ManageBookingView({super.key, required this.bookingId});

  @override
  State<ManageBookingView> createState() => _ManageBookingViewState();
}

class _ManageBookingViewState extends State<ManageBookingView> {
  late final BookingsController controller;

  /// Below this width the HP table scrolls horizontally.
  static const double _hpTableMinWidth = 820;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BookingsController>()
        ? Get.find<BookingsController>()
        : Get.put(BookingsController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getBookingsFromApiByBkId(widget.bookingId);
      controller.getHealthProffApi(widget.bookingId);
      controller.userController.getAllEmployeesFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Obx(() {
        if (controller.allBookingsByBookingIdLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.cPrimaryButtonColor,
            ),
          );
        }

        if (controller.bookingsByBookingId.value.isEmpty) {
          return AppEmptyState(
            icon: LucideIcons.circleAlert,
            tone: AppTone.danger,
            title: 'Booking not found',
            message: 'This booking may have been removed or you may not have access to it.',
            actionLabel: 'Go Back',
            actionIcon: LucideIcons.arrowLeft,
            onAction: () => Get.back(),
          );
        }

        return SingleChildScrollView(
          padding: SizeConfig.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildUserPatientDetails(),
                  const SizedBox(height: 16),
                  _buildBookingStatusOverview(),
                  const SizedBox(height: 16),
                  _buildAssignedHPStatus(),
                  const SizedBox(height: 16),
                  _buildCouponAndPriceDetails(),
                  const SizedBox(height: 16),
                  _buildLeadDetails(),
                  const SizedBox(height: 16),
                  _buildAssignCareManager(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final booking = controller.bookingsByBookingId.value.first;
    final isMobile = SizeConfig.isMobile;

    return AppPageHeader(
      title: 'Manage Booking',
      subtitle: 'Booking ID: BK-${booking.id}',
      breadcrumbs: const ['Bookings', 'Manage Booking'],
      onBack: () => Get.back(),
      actions: [
        ElevatedButton.icon(
          onPressed: () =>
              Get.to(() => EditBookingView(bookingId: widget.bookingId)),
          icon: const Icon(LucideIcons.pencil, size: 18),
          label: Text(isMobile ? 'Edit' : 'Edit Booking'),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Layout helpers
  // ─────────────────────────────────────────────
  /// Responsive field grid: up to [maxColumns] columns on wide screens, one
  /// column on phones.
  Widget _responsiveFieldRow(List<Widget> fields, {int maxColumns = 2}) {
    return AppResponsiveGrid(
      minItemWidth: 200,
      maxColumns: maxColumns,
      spacing: 16,
      children: fields,
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
        ),
      );

  // ─────────────────────────────────────────────
  // User & Patient Details
  // ─────────────────────────────────────────────
  Widget _buildUserPatientDetails() {
    final isMobile = SizeConfig.isMobile;

    Widget userSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('User Information', LucideIcons.user, AppTone.info),
        const SizedBox(height: 16),
        CommonTextField(label: 'User ID', hint: 'User ID', controller: controller.detailUserIdController, enabled: false),
        const SizedBox(height: 16),
        CommonTextField(label: 'User Name', hint: 'User Name', controller: controller.detailUserNameController, enabled: false),
        const SizedBox(height: 16),
        CommonTextField(label: 'User Mobile', hint: 'Mobile Number', prefixIcon: LucideIcons.phone, controller: controller.detailUserMobileController, keyboardType: TextInputType.phone, enabled: false),
        const SizedBox(height: 16),
        CommonTextField(label: 'User Email', hint: 'Email', prefixIcon: LucideIcons.mail, controller: controller.detailUserEmailController, keyboardType: TextInputType.emailAddress, enabled: false),
      ],
    );

    Widget patientSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Patient Information', LucideIcons.bandage, AppTone.success),
        const SizedBox(height: 16),
        CommonTextField(label: 'Patient ID', hint: 'Patient ID', controller: controller.detailPatientIdController, enabled: false),
        const SizedBox(height: 16),
        CommonTextField(label: 'Patient Name', hint: 'Patient Name', controller: controller.detailPatientNameController, enabled: false),
        const SizedBox(height: 16),
        CommonTextField(label: 'Patient Phone', hint: 'Phone Number', prefixIcon: LucideIcons.phone, controller: controller.detailPatientPhoneController, keyboardType: TextInputType.phone, enabled: false),
        const SizedBox(height: 16),
        CommonTextField(label: 'Patient Email', hint: 'Email', prefixIcon: LucideIcons.mail, controller: controller.detailPatientEmailController, keyboardType: TextInputType.emailAddress, enabled: false),
      ],
    );

    return AppCard(
      title: 'User & Patient Details',
      icon: LucideIcons.users,
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                userSection,
                const SizedBox(height: 24),
                patientSection,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: userSection),
                const SizedBox(width: 24),
                Expanded(child: patientSection),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────────
  // Booking Status Overview
  // ─────────────────────────────────────────────
  Widget _buildBookingStatusOverview() {
    final booking = controller.bookingsByBookingId.value.first;
    final isMobile = SizeConfig.isMobile;

    return AppCard(
      title: 'Booking Status Overview',
      icon: LucideIcons.calendarDays,
      actions: [
        _buildStatusBadge(BookingsController.statusLabel(booking.status)),
      ],
      footer: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: _showRateHistoryDialog,
            icon: const Icon(LucideIcons.history, size: 18),
            label: const Text('Rate History'),
          ),
          Obx(() {
            if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
            final bk = controller.bookingsByBookingId.value.first;
            if (bk.holdTicketOpen == 0) return const SizedBox.shrink();
            return OutlinedButton.icon(
              onPressed: () => Get.to(() => const CreateSupportTicket(), arguments: {
                'bookingId': widget.bookingId,
                'userId': bk.userId,
                'typeId': 4, // Hold Request
              }),
              icon: const Icon(LucideIcons.circlePause, size: 18),
              label: Text(isMobile ? 'Hold' : 'Hold Booking'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.warning,
                side: BorderSide(color: AppColor.warning.withValues(alpha: 0.45)),
              ),
            );
          }),
          Obx(() {
            if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
            final bk = controller.bookingsByBookingId.value.first;
            if (bk.cancellationTicketOpen == 0) return const SizedBox.shrink();
            return OutlinedButton.icon(
              onPressed: () => Get.to(() => const CreateSupportTicket(), arguments: {
                'bookingId': widget.bookingId,
                'userId': bk.userId,
                'typeId': 5, // Cancellation
              }),
              icon: const Icon(LucideIcons.circleX, size: 18),
              label: Text(isMobile ? 'Cancel' : 'Cancel Booking'),
              style: AppButtonStyles.dangerOutlined,
            );
          }),
          Obx(() {
            if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
            final bk = controller.bookingsByBookingId.value.first;
            if (bk.extensionStatus == 0) return const SizedBox.shrink();
            final show = bk.serviceEndDate != null && !DateTime.now().isBefore(bk.serviceEndDate!);
            if (!show) return const SizedBox.shrink();
            return ElevatedButton.icon(
              onPressed: _showExtendServiceDialog,
              icon: const Icon(LucideIcons.calendarDays, size: 18),
              label: Text(isMobile ? 'Extend' : 'Extend Service'),
            );
          }),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _responsiveFieldRow([
            CommonTextField(label: 'Service City', hint: 'Service City', controller: controller.serviceCityController, enabled: false),
            CommonTextField(label: 'Base Rate', hint: 'Base Rate', controller: controller.finalRateController, keyboardType: TextInputType.number, enabled: false),
          ]),
          const SizedBox(height: 16),
          _responsiveFieldRow(
            [
              Obx(() => CommonDatePicker(label: 'Start Date', hint: 'Select Date', selectedDate: controller.startDate.value, onDateSelected: (_) {}, enabled: false)),
              Obx(() => CommonDatePicker(label: 'End Date', hint: 'Select Date', selectedDate: controller.endDate.value, onDateSelected: (_) {}, enabled: false)),
              CommonTextField(label: 'Start Time', hint: '09:00 AM', prefixIcon: LucideIcons.clock, controller: controller.startTimeController, enabled: false),
              CommonTextField(label: 'End Time', hint: '06:00 PM', prefixIcon: LucideIcons.clock, controller: controller.endTimeController, enabled: false),
              Obx(() => CommonDatePicker(label: 'Hold Start Date', hint: 'Select Date', selectedDate: controller.holdStartDate.value, onDateSelected: (_) {}, enabled: false)),
              Obx(() => CommonDatePicker(label: 'Hold End Date', hint: 'Select Date', selectedDate: controller.holdEndDate.value, onDateSelected: (_) {}, enabled: false)),
            ],
            maxColumns: 4,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Assigned HP Status
  // ─────────────────────────────────────────────
  Widget _buildAssignedHPStatus() {
    final isMobile = SizeConfig.isMobile;
    return AppCard(
      title: 'Assigned HP Status',
      icon: LucideIcons.stethoscope,
      padding: EdgeInsets.zero,
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            // Pre-load globally active HPs so the dialog
            // can filter them out of the available list.
            controller.loadGlobalActiveHpIds();
            Get.dialog(
              AssignCgDialog(bookingId: widget.bookingId),
              barrierDismissible: false,
            );
          },
          icon: const Icon(LucideIcons.plus, size: 18),
          label: Text(isMobile ? 'Assign HP' : 'Assign New HP'),
        ),
      ],
      footer: _buildHPPagination(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => _buildTabBar()),
          Divider(height: 1, color: AppColor.borderSubtle),
          Obx(() => _buildHPTable()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isMobile = SizeConfig.isMobile;
    final tabs = [
      _buildTab('Shortlisted HP (${controller.shortlistedHPs.length})', 0),
      _buildTab('Interview Stage (${controller.interviewStageHPs.length})', 1),
      _buildTab('Finalized (${controller.finalizedHPs.length})', 2),
      _buildTab('Active HP (${controller.activeHPs.length})', 3),
      _buildTab('Released HP (${controller.releasedHPs.length})', 4),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
      child: Row(children: tabs),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = controller.selectedHPTab.value == index;
    return InkWell(
      onTap: () => controller.selectedHPTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColor.cAppPrimaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColor.cAppPrimaryColor : AppColor.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildHPTable() {
    final hpList = controller.currentTabHPs;
    final isMobile = SizeConfig.isMobile;

    if (controller.getAllHPLoading.value) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (hpList.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.userSearch,
        title: 'No data found',
        message: 'No health professionals in this stage yet.',
        compact: true,
      );
    }

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(hpList.length, (index) => _buildMobileHPCard(index)),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth < _hpTableMinWidth
          ? _hpTableMinWidth
          : constraints.maxWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
                ),
                child: Row(
                  children: [
                    _buildTableHeader('HP ID', flex: 1),
                    _buildTableHeader('HP Name', flex: 2),
                    _buildTableHeader('Planned Start Date', flex: 2),
                    _buildTableHeader('Planned End Date', flex: 2),
                    _buildTableHeader('Actual Start Date', flex: 2),
                    _buildTableHeader('HP Status', flex: 2),
                    _buildTableHeader('Actions', flex: 1, alignEnd: true),
                  ],
                ),
              ),
              ...List.generate(hpList.length, (index) => _buildHPRow(index)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMobileHPCard(int index) {
    final hp = controller.currentTabHPs[index];
    String formatDate(DateTime? date) =>
        date != null ? DateFormat('dd MMM yyyy').format(date) : '-';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: _hpFullName(hp), size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hpFullName(hp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    Text(
                      'HP-${hp.hpUniqueId}',
                      style: TextStyle(fontSize: 12.5, color: AppColor.cAppPrimaryColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Actions',
                icon: Icon(LucideIcons.ellipsis, color: AppColor.textTertiary, size: 20),
                onSelected: (value) {
                  if (value == 'view') {
                    Get.to(() => CgReviewDetailScreen(bookingId: widget.bookingId, hp: hp));
                  } else if (value == 'release') {
                    _confirmReleaseHp(hp.hpUniqueId);
                  }
                },
                itemBuilder: (_) => [
                  _popupItem('view', LucideIcons.eye, 'View', AppColor.textPrimary),
                  _popupItem('release', LucideIcons.logOut, 'Release HP', AppColor.warning),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatusBadge(_mapStatus(hp.status)),
          const SizedBox(height: 10),
          _mobileHPField('Planned Start', formatDate(hp.reportingDatePlanned)),
          const SizedBox(height: 4),
          _mobileHPField('Planned End', formatDate(hp.endDatePlanned)),
          const SizedBox(height: 4),
          _mobileHPField('Actual Start', formatDate(hp.reportingDateActual)),
        ],
      ),
    );
  }

  Widget _mobileHPField(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: TextStyle(fontSize: 13, color: AppColor.textTertiary)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, color: AppColor.textPrimary)),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String title, {int flex = 1, bool alignEnd = false}) {
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
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColor.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildHPRow(int index) {
    final hp = controller.currentTabHPs[index];

    String formatDate(DateTime? date) =>
        date != null ? DateFormat('dd MMM yyyy').format(date) : '-';

    final cellStyle = TextStyle(fontSize: 14, color: AppColor.textSecondary);
    Widget cell(Widget child, int flex) => Expanded(
          flex: flex,
          child: Padding(padding: const EdgeInsets.only(right: 12), child: child),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          cell(
            Text(
              'HP-${hp.hpUniqueId}',           // HP ID
              style: TextStyle(
                fontSize: 14,
                color: AppColor.cAppPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            1,
          ),
          cell(
            Row(
              children: [
                AppAvatar(name: _hpFullName(hp), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hpFullName(hp),                 // HP Name
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            2,
          ),
          cell(Text(formatDate(hp.reportingDatePlanned), style: cellStyle), 2), // Planned Start Date
          cell(Text(formatDate(hp.endDatePlanned), style: cellStyle), 2),       // Planned End Date
          cell(Text(formatDate(hp.reportingDateActual), style: cellStyle), 2),  // Actual Start Date
          cell(
            Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(_mapStatus(hp.status)), // HP Status
            ),
            2,
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                tooltip: 'Actions',
                icon: Icon(
                  LucideIcons.ellipsis,
                  color: AppColor.textTertiary,
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'view') {
                    Get.to(() => CgReviewDetailScreen(
                      bookingId: widget.bookingId,
                      hp: hp,
                    ));
                  } else if (value == 'release') {
                    _confirmReleaseHp(hp.hpUniqueId);
                  }
                },
                itemBuilder: (_) => [
                  _popupItem('view', LucideIcons.eye, 'View', AppColor.textPrimary),
                  _popupItem('release', LucideIcons.logOut, 'Release HP', AppColor.warning),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _popupItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Release HP confirmation dialog
  // ─────────────────────────────────────────────
  void _confirmReleaseHp(int hpUniqueId) {
    showDialog<void>(
      context: context,
      builder: (_) => AppDialog(
        title: 'Release Health Professional',
        icon: LucideIcons.logOut,
        tone: AppTone.warning,
        maxWidth: 460,
        onClose: () => Navigator.of(context).pop(),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.warning,
              foregroundColor: AppColor.pureWhite,
            ),
            onPressed: controller.isUpdateHPBookingLoading.value
                ? null
                : () {
                    Navigator.of(context).pop();
                    controller.releaseHpFromBooking(
                      bookingId: widget.bookingId,
                      hpUniqueId: hpUniqueId,
                    );
                  },
            child: controller.isUpdateHPBookingLoading.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.buttonTextWhite,
                    ),
                  )
                : const Text('Release HP'),
          )),
        ],
        child: Text(
          'Are you sure you want to release this Health Professional from the booking? '
          'This action will move them to "Released" status.',
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColor.textSecondary),
        ),
      ),
    );
  }

  Widget _buildHPPagination() {
    return Obx(() {
      final count = controller.currentTabHPs.length;
      return Text(
        'Showing $count health professional${count == 1 ? '' : 's'}',
        style: TextStyle(
          fontSize: 13,
          color: AppColor.textTertiary,
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // Rate History
  // ─────────────────────────────────────────────
  Future<void> _showRateHistoryDialog() async {
    final rows = await controller.fetchRateHistory(widget.bookingId);
    if (rows == null || !mounted) return;
    String fmtDate(dynamic v) {
      final d = DateTime.tryParse('${v ?? ''}');
      return d == null ? '-' : DateFormat('dd MMM yyyy').format(d);
    }

    Get.dialog(
      AppDialog(
        title: 'Rate History',
        subtitle: 'BK-${widget.bookingId}',
        icon: LucideIcons.history,
        tone: AppTone.neutral,
        maxWidth: 600,
        onClose: () => Get.back(),
        bodyPadding: rows.isEmpty ? null : const EdgeInsets.symmetric(vertical: 4),
        child: rows.isEmpty
            ? const AppEmptyState(
                icon: LucideIcons.history,
                title: 'No rate changes recorded for this booking',
                compact: true,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: AppColor.borderSubtle),
                    Builder(builder: (_) {
                      final r = rows[i];
                      final by = '${r['changed_by_name'] ?? ''}'.trim();
                      final reason = '${r['reason'] ?? ''}'.trim();
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        title: Text('${r['old_rate'] ?? '-'}  →  ${r['new_rate'] ?? '-'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            )),
                        subtitle: Text(
                          [
                            'Effective ${fmtDate(r['effective_date'])}',
                            if (by.isNotEmpty) 'by $by',
                            if (reason.isNotEmpty && reason != 'NA') reason,
                          ].join(' · '),
                          style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                        ),
                        trailing: Text(fmtDate(r['changed_on']),
                            style: TextStyle(fontSize: 12, color: AppColor.textTertiary)),
                      );
                    }),
                  ],
                ],
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Price Details
  // ─────────────────────────────────────────────
  Widget _buildCouponAndPriceDetails() {
    Widget couponDropdown(CouponModel? selected, List<CouponModel> coupons) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Coupon'),
          AppDropdown<CouponModel>(
            hint: 'Select Coupon',
            value: selected,
            items: coupons
                .map((c) => DropdownMenuItem<CouponModel>(value: c, child: Text(c.couponName)))
                .toList(),
            onChanged: (coupon) => controller.applyCoupon(coupon),
          ),
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextButton.icon(
                onPressed: () => controller.applyCoupon(null),
                icon: const Icon(LucideIcons.x, size: 16),
                label: const Text('Clear'),
                style: AppButtonStyles.compact,
              ),
            ),
        ],
      );
    }

    return AppCard(
      title: 'Price Details',
      icon: LucideIcons.banknote,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _responsiveFieldRow([
            CommonTextField(label: 'Base Rate (Per Day)', hint: 'Base Rate', controller: controller.finalRateController, keyboardType: TextInputType.number, enabled: false),
            CommonTextField(label: 'Final Rate', hint: 'Final Rate', controller: controller.finalRateDisplayController, keyboardType: TextInputType.number, enabled: false),
          ]),

          const SizedBox(height: 16),

          Obx(() {
            final coupons = controller.settingsController.getAllCuponsData.value;
            final selected = controller.selectedCoupon.value;

            return _responsiveFieldRow(
              [
                couponDropdown(selected, coupons),
                CommonTextField(label: 'Applied Coupon Discount %', hint: '0.00', controller: controller.discountPercentDisplayController, keyboardType: TextInputType.number, enabled: false),
                CommonTextField(label: 'Applied Coupon Discount Value', hint: '0.00', controller: controller.discountValueDisplayController, keyboardType: TextInputType.number, enabled: false),
              ],
              maxColumns: 3,
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Status Badge
  // ─────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    // HP lifecycle stages get distinct tones; booking statuses use the shared
    // mapping.
    const hpTones = <String, AppTone>{
      'shortlisted': AppTone.info,
      'interview stage': AppTone.warning,
      'finalized': AppTone.violet,
      'active': AppTone.success,
      'released': AppTone.neutral,
      'unknown': AppTone.neutral,
    };
    final tone = hpTones[status.toLowerCase()] ?? toneForStatus(status);
    return AppStatusBadge(label: status, tone: tone);
  }

  // ─────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────
  void _showExtendServiceDialog() {
    final Rx<DateTime?> newStartDate = Rx<DateTime?>(null);
    final Rx<DateTime?> newEndDate = Rx<DateTime?>(null);
    final extendNotesController = TextEditingController();

    Get.dialog(
      AppDialog(
        title: 'Extend Service',
        subtitle: 'Extend the service period by providing new dates',
        icon: LucideIcons.calendarDays,
        tone: AppTone.success,
        maxWidth: 520,
        onClose: () => Get.back(),
        actions: [
          _cancelButton(),
          ElevatedButton(
            onPressed: () {
              if (newStartDate.value == null) {
                _showError('Please select new service start date');
                return;
              }
              if (newEndDate.value == null) {
                _showError('Please select new service end date');
                return;
              }
              if (newEndDate.value!.isBefore(newStartDate.value!)) {
                _showError('New end date cannot be before the new start date');
                return;
              }
              final bk = controller.bookingsByBookingId.value.firstOrNull;
              if (bk != null && bk.serviceEndDate != null &&
                  newEndDate.value!.isBefore(bk.serviceEndDate!)) {
                _showError(
                  'New end date must be after current end date',
                );
                return;
              }
              Get.back();
              controller.extendService(
                widget.bookingId,
                newStartDate.value!,
                newEndDate.value!,
                extendNotesController.text.trim(),
              );
            },
            child: const Text('Confirm Extension'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => CommonDatePicker(
                label: 'New Service Start Date',
                hint: 'Select New Start Date',
                selectedDate: newStartDate.value,
                onDateSelected: (date) => newStartDate.value = date,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CommonDatePicker(
                label: 'New Service End Date',
                hint: 'Select New End Date',
                selectedDate: newEndDate.value,
                onDateSelected: (date) => newEndDate.value = date,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextArea(
              'Extension Notes (Optional)',
              extendNotesController,
              'Add any notes about the extension',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Shared Dialog Helpers
  // ─────────────────────────────────────────────
  Widget _buildTextArea(
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 4,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
        ),
      ],
    );
  }

  Widget _cancelButton() {
    return OutlinedButton(
      onPressed: () => Get.back(),
      child: const Text('Cancel'),
    );
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor.danger,
      colorText: AppColor.pureWhite,
    );
  }

  Widget _sectionLabel(String label, IconData icon, AppTone tone) {
    return Row(
      children: [
        AppIconTile(icon: icon, tone: tone, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadDetails() {
    return AppCard(
      title: 'Lead Details',
      icon: LucideIcons.trendingUp,
      footer: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            controller.updateBookingsTotal(widget.bookingId);
          },
          child: const Text("Update"),
        ),
      ),
      child: _responsiveFieldRow([
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Lead Type'),
            Obx(
              () => AppDropdown<String>(
                hint: 'Select Lead Type',
                value: ["Warm", "Hot", "Cold"]
                        .contains(controller.selectedLeadType.value)
                    ? controller.selectedLeadType.value
                    : null,
                items: ["Warm", "Hot", "Cold"]
                    .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  controller.selectedLeadType.value = value ?? '';
                },
              ),
            ),
          ],
        ),
        Obx(
          () => CommonDatePicker(
            label: 'Next Followup Date',
            hint: 'Select Date',
            selectedDate: controller.selectedFollowupDate.value,
            onDateSelected: (date) {
              controller.selectedFollowupDate.value = date;
            },
            enabled: true,
          ),
        ),
      ]),
    );
  }

  Widget _buildAssignCareManager() {
    return AppCard(
      title: 'Assign Care Manager',
      icon: LucideIcons.headset,
      footer: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            controller.updateBookingsTotal(widget.bookingId);
          },
          child: const Text("Update"),
        ),
      ),
      child: Obx(() {
        final managers = controller.careManagers;

        if (managers.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.borderSubtle),
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: AppColor.surfaceMuted,
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 18, color: AppColor.textTertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No care managers available',
                    style: TextStyle(
                      color: AppColor.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final validIds = managers.map((u) => u.id).toSet();
        final currentId = controller.selectedCareManagerIdForBooking.value;
        final safeValue = (currentId != 0 && validIds.contains(currentId))
            ? currentId
            : null;

        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AppDropdown<int>(
              hint: 'Select Care Manager',
              value: safeValue,
              items: managers
                  .map((user) => DropdownMenuItem<int>(
                        value: user.id,
                        child: Text(user.userName),
                      ))
                  .toList(),
              onChanged: (value) {
                controller.selectedCareManagerIdForBooking.value = value ?? 0;
              },
            ),
          ),
        );
      }),
    );
  }

  String _hpFullName(dynamic hp) {
    final first = (hp.hpRegFirstName ?? '').toString().trim();
    final last = (hp.hpRegLastName ?? '').toString().trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    return full.isEmpty ? 'HP-${hp.hpUniqueId}' : full;
  }

  String _mapStatus(int status) {
    switch (status) {
      case 1: return 'Shortlisted';
      case 2: return 'Interview Stage';
      case 3: return 'Finalized';
      case 4: return 'Active';
      case 5: return 'Released';
      default: return 'Unknown';
    }
  }
}
