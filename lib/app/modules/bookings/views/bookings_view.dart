import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_bookings_model.dart';
import 'package:eldivex_app/app/modules/bookings/views/edit_booking_view.dart';
import 'package:eldivex_app/app/modules/bookings/views/manage_bookings.dart';
import 'package:eldivex_app/app/widgets/common_textfield.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import 'package:eldivex_app/app/widgets/dropdown_common.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/bookings_controller.dart';

class BookingsView extends GetView<BookingsController> {
  BookingsView({super.key});
  Map<String, dynamic>? get data => Get.arguments as Map<String, dynamic>?;
  @override
  Widget build(BuildContext context) {
    debugPrint("BookingsView Arguments: $data");
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController());
    }

    final userId = data?['userId'];
    if (userId != null) {
      controller.getBookingsFromUserCreation(clientUserId: userId);
    } else {
      // Load all bookings if no specific userId
      controller.getBookingsFromApi();
    }
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.getAllBookingsLoading.value) {
                return const ShimmerLoader.table();
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                  child: Column(
                    children: [
                      Obx(
                        () => controller.isFilterVisible.value
                            ? Column(
                                children: [
                                  _buildFiltersCard(),
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 2,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      _buildBookingsCards(),
                      SizedBox(height: SizeConfig.blockSizeVertical * 2),
                      _buildPagination(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = SizeConfig.isMobile;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2,
        vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Get.back();
                  } else {
                    Get.offAllNamed(Routes.MAIN);
                  }
                },
                icon: Icon(Icons.arrow_back_rounded),
              ),
              SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Bookings', style: AppTextStyles.heading),
                    SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                    Text(
                      'View and manage all booking reservations',
                      style: AppTextStyles.regular16W400,
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                Row(
                  children: [
                    _buildFilterButton(),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                    _buildExportButton(),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                    if (data?["userId"] != null) _buildNewBookingButton(),
                  ],
                ),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(),
                  const SizedBox(width: 8),
                  _buildExportButton(),
                  if (data?["userId"] != null) ...[
                    const SizedBox(width: 8),
                    _buildNewBookingButton(),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    final isMobile = SizeConfig.isMobile;
    return Obx(
      () => OutlinedButton.icon(
        onPressed: () {
          controller.toggleFilters();
        },
        icon: Icon(
          controller.isFilterVisible.value
              ? Icons.expand_less
              : Icons.filter_list,
          size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
        ),
        label: Text(
          controller.isFilterVisible.value ? 'Hide Filters' : 'Filters',
          style: TextStyle(
            fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: controller.isFilterVisible.value
              ? Colors.blue.shade700
              : Colors.grey.shade700,
          side: BorderSide(
            color: controller.isFilterVisible.value
                ? Colors.blue.shade300
                : Colors.grey.shade300,
          ),
          backgroundColor: controller.isFilterVisible.value
              ? Colors.blue.shade50
              : Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
            vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    final isMobile = SizeConfig.isMobile;
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(
        Icons.download,
        size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
      ),
      label: Text(
        'Export',
        style: TextStyle(
          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.2,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
          vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildNewBookingButton() {
    final isMobile = SizeConfig.isMobile;
    return ElevatedButton.icon(
      onPressed: () {
        controller.resetCreateBookingForm();
        Get.toNamed(Routes.createBookings, arguments: data);
      },
      icon: Icon(
        Icons.add,
        size: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 0.9,
        color: AppColor.whiteColor,
      ),
      label: Text(
        'New Booking',
        style: TextStyle(
          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 0.9,
          color: AppColor.whiteColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.cPrimaryButtonColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1,
          vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildFilterRow(List<Widget> children) {
    if (SizeConfig.isMobile) {
      return Column(
        children: children
            .expand((w) => [w, const SizedBox(height: 10)])
            .toList()
          ..removeLast(),
      );
    }
    return Row(
      children: children
          .expand((w) => [
                Expanded(child: w),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.2),
              ])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildFiltersCard() {
    final isMobile = SizeConfig.isMobile;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.2,
                    color: Colors.grey.shade700,
                  ),
                  SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8),
                  Text('Filters', style: AppTextStyles.catT16W400),
                ],
              ),
              IconButton(
                onPressed: () {
                  controller.toggleFilters();
                },
                icon: Icon(
                  Icons.close,
                  size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.8,
                  color: AppColor.cPrimaryHeadingColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _buildFilterRow([
            CommonTextField(
              label: 'User ID',
              hint: 'Search by ID',
              controller: controller.userIdController,
            ),
            CommonTextField(
              label: 'Name',
              hint: 'Search by Name',
              controller: controller.nameController,
            ),
            CommonTextField(
              label: 'Phone Number',
              hint: 'Search by Number',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),
          ]),
          SizedBox(height: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2),
          _buildFilterRow([
            Obx(
              () => AppDropdown<int>(
                hint: 'Select Care Manager',
                value: controller.selectedCareManagerId.value == 0
                    ? null
                    : controller.selectedCareManagerId.value,
                items: controller.careManagers
                    .map(
                      (manager) => DropdownMenuItem<int>(
                        value: manager.id,
                        child: Text(manager.userName ?? ""),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCareManagerId.value = value;
                  }
                },
              ),
            ),
            Obx(
              () => CommonDropdown(
                label: 'Service',
                hint: 'Select Service',
                value: controller.selectedService.value.isEmpty
                    ? null
                    : controller.selectedService.value,
                items: controller.services,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedService.value = value;
                  }
                },
              ),
            ),
            Obx(
              () => CommonDropdown(
                label: 'Branch',
                hint: 'Select Branch',
                value: controller.selectedBranch.value.isEmpty
                    ? null
                    : controller.selectedBranch.value,
                items: controller.branches,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedBranch.value = value;
                  }
                },
              ),
            ),
          ]),
          SizedBox(height: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2),
          _buildFilterRow([
            CommonTextField(
              label: 'Booking ID',
              hint: 'Search by ID',
              controller: controller.bookingIdController,
            ),
            Obx(
              () => CommonDatePicker(
                label: 'Service Started On/After',
                hint: 'dd/mm/yyyy',
                selectedDate: controller.serviceStartedOnAfter.value,
                onDateSelected: (date) {
                  controller.serviceStartedOnAfter.value = date;
                },
              ),
            ),
            Obx(
              () => CommonDatePicker(
                label: 'Service Started On/Before',
                hint: 'dd/mm/yyyy',
                selectedDate: controller.serviceStartedOnBefore.value,
                onDateSelected: (date) {
                  controller.serviceStartedOnBefore.value = date;
                },
              ),
            ),
          ]),
          SizedBox(height: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2),
          _buildFilterRow([
            Obx(
              () => CommonDropdown(
                label: 'Booking Status',
                hint: 'Select Status',
                value: controller.selectedBookingStatus.value.isEmpty
                    ? null
                    : controller.selectedBookingStatus.value,
                items: controller.bookingStatuses,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedBookingStatus.value = value;
                  }
                },
              ),
            ),
            Obx(
              () => CommonDatePicker(
                label: 'Booking Submitted On/After',
                hint: 'dd/mm/yyyy',
                selectedDate: controller.bookingSubmittedOnAfter.value,
                onDateSelected: (date) {
                  controller.bookingSubmittedOnAfter.value = date;
                },
              ),
            ),
            Obx(
              () => CommonDatePicker(
                label: 'Booking Submitted On/Before',
                hint: 'dd/mm/yyyy',
                selectedDate: controller.bookingSubmittedOnBefore.value,
                onDateSelected: (date) {
                  controller.bookingSubmittedOnBefore.value = date;
                },
              ),
            ),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.clearFilters();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.getBookingsFromUserCreation(
                                clientUserId: data?['userId'],
                              );
                            },
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.cPrimaryButtonColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          controller.clearFilters();
                        },
                        child: Text(
                          'Reset All Filters',
                          style: AppTextStyles.regular16blue,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.clearFilters();
                      },
                      child: Text(
                        'Reset All Filters',
                        style: AppTextStyles.regular16blue,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            controller.clearFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal * 2,
                              vertical: SizeConfig.blockSizeVertical * 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                            ),
                          ),
                        ),
                        SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.getBookingsFromUserCreation(
                              clientUserId: data?['userId'],
                            );
                          },
                          icon: Icon(
                            Icons.search,
                            size: SizeConfig.blockSizeHorizontal * 1.3,
                          ),
                          label: Text(
                            'Search',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cPrimaryButtonColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal * 1.8,
                              vertical: SizeConfig.blockSizeVertical * 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildBookingsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockSizeVertical * 1,
          ),
          child: Obx(
            () => Text(
              'Showing ${controller.allBookings.value.length} bookings',
              style: AppTextStyles.regular16Gre,
            ),
          ),
        ),
        Obx(() {
          if (controller.allBookings.value.isEmpty) {
            final isMobile = SizeConfig.isMobile;
            return Center(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 40 : SizeConfig.blockSizeVertical * 5),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: isMobile ? 48 : SizeConfig.blockSizeHorizontal * 5,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                    Text(
                      'No bookings found',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: controller.allBookings.value.map((booking) {
              return _buildBookingCard(booking);
            }).toList(),
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  int _calculateDays(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return 0;
    return endDate.difference(startDate).inDays + 1;
  }

  Widget _buildBookingCard(GetBookingsModel booking) {
    final days = _calculateDays(
      booking.serviceStartDate,
      booking.serviceEndDate,
    );
    final baseRate = double.tryParse(booking.baseRate) ?? 0;
    final totalRate = baseRate * days;
    final isMobile = SizeConfig.isMobile;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5),
        child: isMobile ? _buildMobileBookingCardContent(booking, days) : _buildDesktopBookingCardContent(booking, days),
      ),
    );
  }

  Widget _buildDesktopBookingCardContent(GetBookingsModel booking, int days) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Booking Details
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 1,
                  vertical: SizeConfig.blockSizeVertical * 0.5,
                ),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'BK-${booking.id}',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: SizeConfig.blockSizeHorizontal * 1.2,
                    color: AppColor.fontColorGrey,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
                  Text(
                    _formatDate(booking.createdOn),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 1,
                      color: AppColor.fontColorGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 0.8,
                  vertical: SizeConfig.blockSizeVertical * 0.4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${booking.status}',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 0.9,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        // User & Patient
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: SizeConfig.blockSizeHorizontal * 1.3,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
                  Expanded(
                    child: Text(
                      '${booking.userName}',
                      style: AppTextStyles.regular16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: SizeConfig.blockSizeHorizontal * 1.1,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.3),
                  Text(
                    '${booking.userMobile}',
                    style: AppTextStyles.regular16Gre,
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.8),
              Text(
                'Patient: ${booking.patientName}',
                style: AppTextStyles.regular16,
              ),
              Text(
                'Age: ${booking.patientAge}',
                style: AppTextStyles.regular16Gre,
              ),
            ],
          ),
        ),
        // Service
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${booking.serviceTypeName}',
                style: AppTextStyles.regular16,
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 0.8,
                  vertical: SizeConfig.blockSizeVertical * 0.3,
                ),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${booking.serviceName}',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 0.6,
                    fontWeight: FontWeight.w500,
                    color: Colors.pink.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Address
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: SizeConfig.blockSizeHorizontal * 1.3,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
              Expanded(
                child: Text(
                  '${booking.landmark}',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 1,
                    color: AppColor.cPrimaryHeadingColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Period
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: SizeConfig.blockSizeHorizontal * 0.9,
                    color: AppColor.verifyContinue,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
                  Text(
                    _formatDate(booking.serviceStartDate),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 0.9,
                      color: AppColor.cPrimaryHeadingColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: SizeConfig.blockSizeHorizontal * 0.9,
                    color: AppColor.calenderRed,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
                  Text(
                    _formatDate(booking.serviceEndDate),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 0.9,
                      color: AppColor.cPrimaryHeadingColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              Text('$days days', style: AppTextStyles.regular16Gre),
            ],
          ),
        ),
        // Rate
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade500,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${booking.baseRate}/day',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              Text(
                'Total: ${booking.finalRate?.toStringAsFixed(0)}' ?? "0",
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 1,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        // Health Professional
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${booking.careManagerName}',
                style: AppTextStyles.regular16,
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: SizeConfig.blockSizeHorizontal * 1.1,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
                  Flexible(
                    child: Text(
                      "${booking.careManagerMobile}",
                      style: AppTextStyles.regular16Gre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Remarks
        Expanded(
          flex: 1,
          child: Text(
            booking.splCareRequirements ?? booking.splInstructions ?? '',
            style: TextStyle(fontSize: 14, color: AppColor.fontColorGrey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Actions
        SizedBox(
          width: SizeConfig.blockSizeHorizontal * 3,
          child: _buildBookingPopupMenu(booking),
        ),
      ],
    );
  }

  Widget _buildMobileBookingCardContent(GetBookingsModel booking, int days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Booking ID, Status, Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.cPrimaryButtonColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'BK-${booking.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${booking.status}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            _buildBookingPopupMenu(booking),
          ],
        ),
        const SizedBox(height: 10),
        // Created date
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: AppColor.fontColorGrey),
            const SizedBox(width: 4),
            Text(
              _formatDate(booking.createdOn),
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
            ),
          ],
        ),
        const Divider(height: 16),
        // User & Patient info
        Row(
          children: [
            Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text('${booking.userName}', style: AppTextStyles.regular16),
            ),
            Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text('${booking.userMobile}', style: AppTextStyles.regular16Gre),
          ],
        ),
        const SizedBox(height: 4),
        Text('Patient: ${booking.patientName}  |  Age: ${booking.patientAge}',
          style: AppTextStyles.regular16Gre,
        ),
        const Divider(height: 16),
        // Service & Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${booking.serviceTypeName}', style: AppTextStyles.regular16),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${booking.serviceName}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.pink.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${booking.landmark}',
                      style: TextStyle(fontSize: 13, color: AppColor.cPrimaryHeadingColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 16),
        // Period & Rate
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 13, color: AppColor.verifyContinue),
                      const SizedBox(width: 4),
                      Text(_formatDate(booking.serviceStartDate),
                        style: TextStyle(fontSize: 13, color: AppColor.cPrimaryHeadingColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 13, color: AppColor.calenderRed),
                      const SizedBox(width: 4),
                      Text(_formatDate(booking.serviceEndDate),
                        style: TextStyle(fontSize: 13, color: AppColor.cPrimaryHeadingColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$days days', style: AppTextStyles.regular16Gre),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade500,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${booking.baseRate}/day',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${booking.finalRate?.toStringAsFixed(0) ?? "0"}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
        // Care Manager
        if (booking.careManagerName != null) ...[
          const Divider(height: 16),
          Row(
            children: [
              Text('Care Manager: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Expanded(child: Text('${booking.careManagerName}', style: AppTextStyles.regular16)),
              if (booking.careManagerMobile != null) ...[
                Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text("${booking.careManagerMobile}", style: AppTextStyles.regular16Gre),
              ],
            ],
          ),
        ],
        // Remarks
        if ((booking.splCareRequirements ?? booking.splInstructions) != null) ...[
          const SizedBox(height: 6),
          Text(
            booking.splCareRequirements ?? booking.splInstructions ?? '',
            style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildBookingPopupMenu(GetBookingsModel booking) {
    final isMobile = SizeConfig.isMobile;
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey.shade600,
        size: isMobile ? 22 : SizeConfig.blockSizeHorizontal * 1.5,
      ),
      onSelected: (value) {
        if (value == 'view') {
          Get.to(() => ManageBookingView(bookingId: booking.id));
        } else if (value == 'edit') {
          Get.to(() => EditBookingView(bookingId: booking.id));
        } else if (value == 'delete') {}
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.3),
              SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8),
              const Text('Manage Booking'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.3),
              SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8),
              const Text('Edit'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    final isMobile = SizeConfig.isMobile;
    if (isMobile) {
      return Column(
        children: [
          Obx(
            () => Text(
              'Showing ${controller.allBookings.value.length} of ${controller.allBookings.value.length} bookings',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Previous', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 6),
              for (final page in ['1', '2', '3']) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: page == '1' ? Colors.blue.shade600 : Colors.white,
                    border: page != '1' ? Border.all(color: Colors.grey.shade300) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    page,
                    style: TextStyle(
                      fontSize: 13,
                      color: page == '1' ? Colors.white : Colors.grey.shade700,
                      fontWeight: page == '1' ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Text(
            'Showing ${controller.allBookings.value.length} of ${controller.allBookings.value.length} bookings',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 1.1,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 2,
                  vertical: SizeConfig.blockSizeVertical * 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Previous',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                ),
              ),
            ),
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
                  fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 1.5,
                vertical: SizeConfig.blockSizeVertical * 1,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '2',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 1.5,
                vertical: SizeConfig.blockSizeVertical * 1,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '3',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 2,
                  vertical: SizeConfig.blockSizeVertical * 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
