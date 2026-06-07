import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/widgets/common_textfield.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import '../../../widgets/dropdown_common.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/models/get_discount_models.dart';
import '../controllers/bookings_controller.dart';
import '../../support/views/create_support_ticket.dart';
import 'assign_cg_dialog.dart';
import 'cg_review_detail_screen.dart';
import 'edit_booking_view.dart';

class ManageBookingView extends StatefulWidget {
  final int bookingId;

  const ManageBookingView({super.key, required this.bookingId});

  @override
  State<ManageBookingView> createState() => _ManageBookingViewState();
}

class _ManageBookingViewState extends State<ManageBookingView> {
  late final BookingsController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController());
    }
    controller = Get.find<BookingsController>();
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
          final isMobile = SizeConfig.isMobile;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isMobile ? 48 : SizeConfig.blockSizeHorizontal * 5,
                  color: Colors.red,
                ),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                Text('Booking not found', style: AppTextStyles.heading),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserPatientDetails(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    _buildBookingStatusOverview(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    _buildAssignedHPStatus(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    _buildCouponAndPriceDetails(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    _buildLeadDetails(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    _buildAssignCareManager(),
                  ],
                ),
              ),
            ],
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

    return Container(
      color: AppColor.whiteColor,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2,
        vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 2,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              size: isMobile ? 24 : SizeConfig.blockSizeHorizontal * 2.5,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(width: isMobile ? 4 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manage Booking', style: AppTextStyles.heading),
                SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                Text(
                  'Booking ID: BK-${booking.id}',
                  style: AppTextStyles.regular16W400,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () =>
                Get.to(() => EditBookingView(bookingId: widget.bookingId)),
            icon: Icon(Icons.edit, size: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.5),
            label: Text(
              isMobile ? 'Edit' : 'Edit Booking',
              style: TextStyle(
                fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.2,
                color: AppColor.buttonTextWhite,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cPrimaryButtonColor,
              foregroundColor: AppColor.whiteColor,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2,
                vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // User & Patient Details
  // ─────────────────────────────────────────────
  Widget _buildUserPatientDetails() {
    final isMobile = SizeConfig.isMobile;

    Widget userSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('User Information', Icons.person_outline, Colors.blue.shade600),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'User ID', hint: 'User ID', controller: controller.detailUserIdController, enabled: false),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'User Name', hint: 'User Name', controller: controller.detailUserNameController, enabled: false),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'User Mobile', hint: 'Mobile Number', prefixIcon: Icons.phone, controller: controller.detailUserMobileController, keyboardType: TextInputType.phone, enabled: false),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'User Email', hint: 'Email', prefixIcon: Icons.email, controller: controller.detailUserEmailController, keyboardType: TextInputType.emailAddress, enabled: false),
      ],
    );

    Widget patientSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Patient Information', Icons.person_outline, Colors.teal.shade600),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'Patient ID', hint: 'Patient ID', controller: controller.detailPatientIdController, enabled: false),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'Patient Name', hint: 'Patient Name', controller: controller.detailPatientNameController, enabled: false),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'Patient Phone', hint: 'Phone Number', prefixIcon: Icons.phone, controller: controller.detailPatientPhoneController, keyboardType: TextInputType.phone, enabled: false),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
        CommonTextField(label: 'Patient Email', hint: 'Email', prefixIcon: Icons.email, controller: controller.detailPatientEmailController, keyboardType: TextInputType.emailAddress, enabled: false),
      ],
    );

    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User & Patient Details',
            style: TextStyle(
              fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          if (isMobile) ...[
            userSection,
            const SizedBox(height: 16),
            patientSection,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: userSection),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                Expanded(child: patientSection),
              ],
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Booking Status Overview
  // ─────────────────────────────────────────────
  /// Helper to build a responsive row of fields: Row on desktop, Column on mobile
  Widget _responsiveFieldRow(List<Widget> fields) {
    if (SizeConfig.isMobile) {
      return Column(
        children: fields
            .expand((w) => [w, const SizedBox(height: 12)])
            .toList()
          ..removeLast(),
      );
    }
    return Row(
      children: fields
          .expand((w) => [
                Expanded(child: w),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
              ])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildBookingStatusOverview() {
    final booking = controller.bookingsByBookingId.value.first;
    final isMobile = SizeConfig.isMobile;

    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Booking Status Overview',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColor.fontColorBlack,
                  ),
                ),
              ),
              _buildStatusBadge(booking.status!),
            ],
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),

          _responsiveFieldRow([
            CommonTextField(label: 'Service City', hint: 'Service City', controller: controller.serviceCityController, enabled: false),
            CommonTextField(label: 'Base Rate', hint: 'Base Rate', controller: controller.finalRateController, keyboardType: TextInputType.number, enabled: false),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),

          _responsiveFieldRow([
            Obx(() => CommonDatePicker(label: 'Start Date', hint: 'Select Date', selectedDate: controller.startDate.value, onDateSelected: (_) {}, enabled: false)),
            Obx(() => CommonDatePicker(label: 'End Date', hint: 'Select Date', selectedDate: controller.endDate.value, onDateSelected: (_) {}, enabled: false)),
            CommonTextField(label: 'Start Time', hint: '09:00 AM', prefixIcon: Icons.access_time, controller: controller.startTimeController, enabled: false),
            CommonTextField(label: 'End Time', hint: '06:00 PM', prefixIcon: Icons.access_time, controller: controller.endTimeController, enabled: false),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),

          if (isMobile)
            Column(
              children: [
                Obx(() => CommonDatePicker(label: 'Hold Start Date', hint: 'Select Date', selectedDate: controller.holdStartDate.value, onDateSelected: (_) {}, enabled: false)),
                const SizedBox(height: 12),
                Obx(() => CommonDatePicker(label: 'Hold End Date', hint: 'Select Date', selectedDate: controller.holdEndDate.value, onDateSelected: (_) {}, enabled: false)),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: Obx(() => CommonDatePicker(label: 'Hold Start Date', hint: 'Select Date', selectedDate: controller.holdStartDate.value, onDateSelected: (_) {}, enabled: false))),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                Expanded(child: Obx(() => CommonDatePicker(label: 'Hold End Date', hint: 'Select Date', selectedDate: controller.holdEndDate.value, onDateSelected: (_) {}, enabled: false))),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                const Expanded(child: SizedBox()),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                const Expanded(child: SizedBox()),
              ],
            ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),

          isMobile
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _actionButton('View History', Icons.history, null, AppColor.fontColorGrey, BorderSide(color: AppColor.divColor), () {}),
                    Obx(() {
                      if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
                      final bk = controller.bookingsByBookingId.value.first;
                      if (bk.holdTicketOpen == 0) return const SizedBox.shrink();
                      return _actionButton('Hold', Icons.pause_circle_outline, Colors.orange.shade500, AppColor.whiteColor, null, () {
                        Get.to(() => const CreateSupportTicket(), arguments: {
                          'bookingId': widget.bookingId,
                          'userId': bk.userId,
                          'typeId': 4, // Hold Request
                        });
                      });
                    }),
                    Obx(() {
                      if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
                      final bk = controller.bookingsByBookingId.value.first;
                      if (bk.cancellationTicketOpen == 0) return const SizedBox.shrink();
                      return _actionButton('Cancel', Icons.cancel, Colors.red.shade500, AppColor.whiteColor, null, () {
                        Get.to(() => const CreateSupportTicket(), arguments: {
                          'bookingId': widget.bookingId,
                          'userId': bk.userId,
                          'typeId': 5, // Cancellation
                        });
                      });
                    }),
                    Obx(() {
                      if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
                      final bk = controller.bookingsByBookingId.value.first;
                      if (bk.extensionStatus == 0) return const SizedBox.shrink();
                      final show = bk.serviceEndDate != null && !DateTime.now().isBefore(bk.serviceEndDate!);
                      if (!show) return const SizedBox.shrink();
                      return _actionButton('Extend', Icons.calendar_month, Colors.green.shade500, AppColor.whiteColor, null, _showExtendServiceDialog);
                    }),
                  ],
                )
              : Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.history, size: SizeConfig.blockSizeHorizontal * 1.4),
                      label: Text('View History', style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.1)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.fontColorGrey,
                        side: BorderSide(color: AppColor.divColor),
                        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 2, vertical: SizeConfig.blockSizeVertical * 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    Obx(() {
                      if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
                      final bk = controller.bookingsByBookingId.value.first;
                      if (bk.holdTicketOpen == 0) return const SizedBox.shrink();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                          ElevatedButton.icon(
                            onPressed: () => Get.to(() => const CreateSupportTicket(), arguments: {
                              'bookingId': widget.bookingId,
                              'userId': bk.userId,
                              'typeId': 4, // Hold Request
                            }),
                            icon: Icon(Icons.pause_circle_outline, size: SizeConfig.blockSizeHorizontal * 1.4),
                            label: Text('Hold Booking', style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.1)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade500, foregroundColor: AppColor.buttonTextWhite,
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 2, vertical: SizeConfig.blockSizeVertical * 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                            ),
                          ),
                        ],
                      );
                    }),
                    Obx(() {
                      if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
                      final bk = controller.bookingsByBookingId.value.first;
                      if (bk.cancellationTicketOpen == 0) return const SizedBox.shrink();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                          ElevatedButton.icon(
                            onPressed: () => Get.to(() => const CreateSupportTicket(), arguments: {
                              'bookingId': widget.bookingId,
                              'userId': bk.userId,
                              'typeId': 5, // Cancellation
                            }),
                            icon: Icon(Icons.cancel, size: SizeConfig.blockSizeHorizontal * 1.4),
                            label: Text('Cancel Booking', style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.1)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade500, foregroundColor: AppColor.buttonTextWhite,
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 2, vertical: SizeConfig.blockSizeVertical * 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                            ),
                          ),
                        ],
                      );
                    }),
                    Obx(() {
                      if (controller.bookingsByBookingId.value.isEmpty) return const SizedBox.shrink();
                      final bk = controller.bookingsByBookingId.value.first;
                      if (bk.extensionStatus == 0) return const SizedBox.shrink();
                      final show = bk.serviceEndDate != null && !DateTime.now().isBefore(bk.serviceEndDate!);
                      if (!show) return const SizedBox.shrink();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                          ElevatedButton.icon(
                            onPressed: _showExtendServiceDialog,
                            icon: Icon(Icons.calendar_month, size: SizeConfig.blockSizeHorizontal * 1.4),
                            label: Text('Extend Service', style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.1)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade500, foregroundColor: AppColor.buttonTextWhite,
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 2, vertical: SizeConfig.blockSizeVertical * 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color? bgColor, Color fgColor, BorderSide? side, VoidCallback onPressed) {
    if (bgColor != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor, foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: fgColor,
        side: side,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Assigned HP Status
  // ─────────────────────────────────────────────
  Widget _buildAssignedHPStatus() {
    final isMobile = SizeConfig.isMobile;
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Assigned HP Status',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColor.fontColorBlack,
                  ),
                ),
              ),
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
                icon: Icon(Icons.add, size: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.4),
                label: Text(
                  isMobile ? 'Assign HP' : 'Assign New HP',
                  style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: AppColor.buttonTextWhite,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2,
                    vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          Obx(() => _buildTabBar()),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          Obx(() => _buildHPTable()),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _buildHPPagination(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isMobile = SizeConfig.isMobile;
    final tabs = [
      _buildTab('Shortlisted HP (${controller.shortlistedHPs.length})', 0),
      SizedBox(width: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      _buildTab('Interview Stage (${controller.interviewStageHPs.length})', 1),
      SizedBox(width: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      _buildTab('Finalized (${controller.finalizedHPs.length})', 2),
      SizedBox(width: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      _buildTab('Active HP (${controller.activeHPs.length})', 3),
      SizedBox(width: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      _buildTab('Released HP (${controller.releasedHPs.length})', 4),
    ];
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: tabs),
      );
    }
    return Row(children: tabs);
  }
  Widget _buildTab(String title, int index) {
    final isSelected = controller.selectedHPTab.value == index;
    final isMobile = SizeConfig.isMobile;
    return GestureDetector(
      onTap: () => controller.selectedHPTab.value = index,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
          vertical: isMobile ? 8 : SizeConfig.blockSizeVertical * 1,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue.shade600 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.blue.shade600 : AppColor.fontColorGrey,
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
      return Padding(
        padding: EdgeInsets.all(isMobile ? 20 : SizeConfig.blockSizeHorizontal * 2),
        child: Center(
          child: Text(
            'No data found',
            style: TextStyle(
              fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
              color: AppColor.fontColorGrey,
            ),
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: List.generate(hpList.length, (index) => _buildMobileHPCard(index)),
      );
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 1.5,
            vertical: SizeConfig.blockSizeVertical * 1.2,
          ),
          decoration: BoxDecoration(
            color: AppColor.fieldColorGrey,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              _buildTableHeader('HP ID', flex: 1),
              _buildTableHeader('HP Name', flex: 2),
              _buildTableHeader('Planned Start Date', flex: 2),
              _buildTableHeader('Planned End Date', flex: 2),
              _buildTableHeader('Actual Start Date', flex: 2),
              _buildTableHeader('HP Status', flex: 2),
              _buildTableHeader('Actions', flex: 1),
            ],
          ),
        ),
        ...List.generate(hpList.length, (index) => _buildHPRow(index)),
      ],
    );
  }

  Widget _buildMobileHPCard(int index) {
    final hp = controller.currentTabHPs[index];
    String formatDate(DateTime? date) =>
        date != null ? DateFormat('dd MMM yyyy').format(date) : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.divColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'HP${hp.hpUniqueId}',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Text('HP${hp.hpRegFirstName}', style: TextStyle(fontSize: 14, color: AppColor.fontColorBlack)),
                ],
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColor.fontColorGrey, size: 22),
                onSelected: (value) {
                  if (value == 'view') {
                    Get.to(() => CgReviewDetailScreen(bookingId: widget.bookingId, hp: hp));
                  } else if (value == 'release') {
                    _confirmReleaseHp(hp.hpUniqueId);
                  }
                },
                itemBuilder: (_) => [
                  _popupItem('view', Icons.visibility_outlined, 'View', AppColor.fontColorBlack),
                  _popupItem('edit', Icons.edit_outlined, 'Edit', AppColor.fontColorBlack),
                  _popupItem('delete', Icons.delete_outline, 'Delete', Colors.red.shade400),
                  _popupItem('release', Icons.logout_outlined, 'Release HP', Colors.orange.shade700),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusBadge(_mapStatus(hp.status)),
          const Divider(height: 16),
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
        Text('$label: ', style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
        Text(value, style: TextStyle(fontSize: 13, color: AppColor.fontColorBlack)),
      ],
    );
  }
  Widget _buildTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 1.1,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorGrey,
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
          Icon(
            Icons.unfold_more,
            size: SizeConfig.blockSizeHorizontal * 1.2,
            color: AppColor.fontColorGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildHPRow(int index) {
    final hp = controller.currentTabHPs[index];

    String formatDate(DateTime? date) =>
        date != null ? DateFormat('dd MMM yyyy').format(date) : '-';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 1.5,
        vertical: SizeConfig.blockSizeVertical * 1.5,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'HP${hp.hpUniqueId}',           // HP ID
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'HP${hp.hpRegFirstName}',           // Replace with hp name if you have it from API
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: AppColor.fontColorBlack,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatDate(hp.reportingDatePlanned),  // Planned Start Date
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: AppColor.fontColorGrey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatDate(hp.endDatePlanned),        // Planned End Date
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: AppColor.fontColorGrey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatDate(hp.reportingDateActual),   // Actual Start Date
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: AppColor.fontColorGrey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(_mapStatus(hp.status)), // HP Status
          ),
          Expanded(
            flex: 1,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColor.fontColorGrey,
                size: SizeConfig.blockSizeHorizontal * 1.5,
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
                _popupItem('view', Icons.visibility_outlined, 'View', AppColor.fontColorBlack),
                _popupItem('edit', Icons.edit_outlined, 'Edit', AppColor.fontColorBlack),
                _popupItem('delete', Icons.delete_outline, 'Delete', Colors.red.shade400),
                _popupItem('release', Icons.logout_outlined, 'Release HP', Colors.orange.shade700),
              ],
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
    final isMobile = SizeConfig.isMobile;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.3, color: color),
          SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8),
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
      builder: (_) => AlertDialog(
        title: const Text('Release Health Professional'),
        content: const Text(
          'Are you sure you want to release this Health Professional from the booking? '
          'This action will move them to "Released" status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: AppColor.buttonTextWhite,
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
      ),
    );
  }

  Widget _buildHPPagination() {
    final count = controller.currentTabHPs.length;
    final isMobile = SizeConfig.isMobile;

    if (isMobile) {
      return Column(
        children: [
          Text(
            'Showing $count of $count health professionals',
            style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _paginationButton('Previous', () {}),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(8)),
                child: Text('1', style: TextStyle(fontSize: 13, color: AppColor.buttonTextWhite, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 6),
              _paginationButton('Next', () {}),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing $count of $count health professionals',
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 1.1,
            color: AppColor.fontColorGrey,
          ),
        ),
        Row(
          children: [
            _paginationButton('Previous', () {}),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 1.5,
                vertical: SizeConfig.blockSizeVertical * 1,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '1',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                  color: AppColor.buttonTextWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
            _paginationButton('Next', () {}),
          ],
        ),
      ],
    );
  }
  Widget _paginationButton(String label, VoidCallback onPressed) {
    final isMobile = SizeConfig.isMobile;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.fontColorGrey,
        side: BorderSide(color: AppColor.divColor),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.5,
          vertical: isMobile ? 8 : SizeConfig.blockSizeVertical * 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Price Details
  // ─────────────────────────────────────────────
  Widget _buildCouponAndPriceDetails() {
    final isMobile = SizeConfig.isMobile;

    Widget couponDropdown(CouponModel? selected, List<CouponModel> coupons) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coupon',
            style: TextStyle(
              fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1,
              color: AppColor.fontColorGrey,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
          AppDropdown<CouponModel>(
            hint: 'Select Coupon',
            value: selected,
            items: coupons
                .map((c) => DropdownMenuItem<CouponModel>(value: c, child: Text(c.couponName)))
                .toList(),
            onChanged: (coupon) => controller.applyCoupon(coupon),
          ),
          if (selected != null)
            TextButton(
              onPressed: () => controller.applyCoupon(null),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : SizeConfig.blockSizeHorizontal * 1, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Clear', style: TextStyle(color: AppColor.buttonTextWhite)),
            ),
        ],
      );
    }

    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),

          _responsiveFieldRow([
            CommonTextField(label: 'Base Rate (Per Day)', hint: 'Base Rate', controller: controller.finalRateController, keyboardType: TextInputType.number, enabled: false),
            CommonTextField(label: 'Final Rate', hint: 'Final Rate', controller: controller.finalRateDisplayController, keyboardType: TextInputType.number, enabled: false),
          ]),

          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 2),

          Obx(() {
            final settingsController = Get.find<SettingsController>();
            final coupons = settingsController.getAllCuponsData.value;
            final selected = controller.selectedCoupon.value;

            if (isMobile) {
              return Column(
                children: [
                  couponDropdown(selected, coupons),
                  const SizedBox(height: 12),
                  CommonTextField(label: 'Applied Coupon Discount %', hint: '0.00', controller: controller.discountPercentDisplayController, keyboardType: TextInputType.number, enabled: false),
                  const SizedBox(height: 12),
                  CommonTextField(label: 'Applied Coupon Discount Value', hint: '0.00', controller: controller.discountValueDisplayController, keyboardType: TextInputType.number, enabled: false),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: couponDropdown(selected, coupons)),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                Expanded(child: CommonTextField(label: 'Applied Coupon Discount %', hint: '0.00', controller: controller.discountPercentDisplayController, keyboardType: TextInputType.number, enabled: false)),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                Expanded(child: CommonTextField(label: 'Applied Coupon Discount Value', hint: '0.00', controller: controller.discountValueDisplayController, keyboardType: TextInputType.number, enabled: false)),
              ],
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
    Color bgColor;
    Color textColor;
    final isMobile = SizeConfig.isMobile;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'shortlisted':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'pending approval':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'released':
        bgColor = AppColor.fieldColorGrey;
        textColor = AppColor.fontColorGrey;
        break;
      case 'confirmed':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'cancelled':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case 'in progress':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'completed':
        bgColor = Colors.teal.shade50;
        textColor = Colors.teal.shade700;
        break;
      default:
        bgColor = AppColor.fieldColorGrey;
        textColor = AppColor.fontColorGrey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : SizeConfig.blockSizeHorizontal * 1,
        vertical: isMobile ? 4 : SizeConfig.blockSizeVertical * 0.5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────
  void _showExtendServiceDialog() {
    final Rx<DateTime?> newStartDate = Rx<DateTime?>(null);
    final Rx<DateTime?> newEndDate = Rx<DateTime?>(null);
    final extendNotesController = TextEditingController();
    final isMobile = SizeConfig.isMobile;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 40,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogHeader(
                'Extend Service',
                Icons.calendar_month,
                Colors.green.shade600,
              ),
              SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
              Text(
                'Extend the service period by providing new dates:',
                style: TextStyle(
                  fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                  color: AppColor.fontColorGrey,
                ),
              ),
              SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
              Obx(
                () => CommonDatePicker(
                  label: 'New Service Start Date',
                  hint: 'Select New Start Date',
                  selectedDate: newStartDate.value,
                  onDateSelected: (date) => newStartDate.value = date,
                ),
              ),
              SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
              Obx(
                () => CommonDatePicker(
                  label: 'New Service End Date',
                  hint: 'Select New End Date',
                  selectedDate: newEndDate.value,
                  onDateSelected: (date) => newEndDate.value = date,
                ),
              ),
              SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
              _buildTextArea(
                'Extension Notes (Optional)',
                extendNotesController,
                'Add any notes about the extension',
                maxLines: 3,
              ),
              SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _cancelButton(),
                  SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
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
                      final bk = controller.bookingsByBookingId.value.first;
                      if (bk.serviceEndDate != null &&
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: AppColor.buttonTextWhite,
                      padding: _buttonPadding(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Confirm Extension',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Shared Dialog Helpers
  // ─────────────────────────────────────────────
  Widget _dialogHeader(String title, IconData icon, Color color) {
    final isMobile = SizeConfig.isMobile;
    return Row(
      children: [
        Icon(icon, color: color, size: isMobile ? 24 : SizeConfig.blockSizeHorizontal * 2),
        SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          iconSize: isMobile ? 22 : SizeConfig.blockSizeHorizontal * 1.5,
        ),
      ],
    );
  }

  Widget _buildTextArea(
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 4,
  }) {
    final isMobile = SizeConfig.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
            fontWeight: FontWeight.w500,
            color: AppColor.fontColorGrey,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.all(
              isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColor.divColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColor.divColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade600),
            ),
          ),
          style: TextStyle(fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1),
        ),
      ],
    );
  }

  Widget _cancelButton() {
    final isMobile = SizeConfig.isMobile;
    return OutlinedButton(
      onPressed: () => Get.back(),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.fontColorGrey,
        side: BorderSide(color: AppColor.divColor),
        padding: _buttonPadding(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Cancel',
        style: TextStyle(fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1),
      ),
    );
  }

  EdgeInsetsGeometry _buttonPadding() => SizeConfig.isMobile
      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
      : EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2,
          vertical: SizeConfig.blockSizeVertical * 1.2,
        );

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
    );
  }

  // ─────────────────────────────────────────────
  // Card Decoration
  // ─────────────────────────────────────────────
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColor.whiteColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColor.divColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  Widget _sectionLabel(String label, IconData icon, Color color) {
    final isMobile = SizeConfig.isMobile;
    return Row(
      children: [
        Icon(icon, size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5, color: color),
        SizedBox(width: isMobile ? 6 : SizeConfig.blockSizeHorizontal * 0.5),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 15 : SizeConfig.blockSizeHorizontal * 1.2,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLeadDetails() {
    final isMobile = SizeConfig.isMobile;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lead Details',
            style: TextStyle(
              fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          _responsiveFieldRow([
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

          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                controller.updateBookingsTotal(widget.bookingId);
              },
              child: const Text("Update"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      child: child,
    );
  }

  Widget _buildAssignCareManager() {
    final isMobile = SizeConfig.isMobile;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assign Care Manager',
            style: TextStyle(
              fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),

          Obx(() {
            final managers = controller.careManagers;

            if (managers.isEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : SizeConfig.blockSizeHorizontal * 1,
                  vertical: isMobile ? 14 : SizeConfig.blockSizeVertical * 1.8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.divColor),
                  borderRadius: BorderRadius.circular(6),
                  color: AppColor.fieldColorGrey,
                ),
                child: Text(
                  'No care managers available',
                  style: TextStyle(
                    color: AppColor.fontColorGrey,
                    fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                  ),
                ),
              );
            }

            final validIds = managers.map((u) => u.id).toSet();
            final currentId = controller.selectedCareManagerIdForBooking.value;
            final safeValue = (currentId != 0 && validIds.contains(currentId))
                ? currentId
                : null;

            return AppDropdown<int>(
              hint: 'Select Care Manager',
              value: safeValue,
              items: managers
                  .map((user) => DropdownMenuItem<int>(
                        value: user.id,
                        child: Text(user.userName ?? ""),
                      ))
                  .toList(),
              onChanged: (value) {
                controller.selectedCareManagerIdForBooking.value = value ?? 0;
              },
            );
          }),

          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                controller.updateBookingsTotal(widget.bookingId);
              },
              child: const Text("Update"),
            ),
          ),
        ],
      ),
    );
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
