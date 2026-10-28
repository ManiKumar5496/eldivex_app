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

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  late final BookingsController controller;
  Map<String, dynamic>? data;
  int? _clientUserId;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BookingsController>()
        ? Get.find<BookingsController>()
        : Get.put(BookingsController());
    final args = Get.arguments;
    data = args is Map ? Map<String, dynamic>.from(args) : null;
    final raw = data?['userId'];
    _clientUserId = raw is int ? raw : int.tryParse('${raw ?? ''}');
    // Fetch once per mount; the controller skips the call when this scope is
    // already loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureBookingsLoaded(clientUserId: _clientUserId);
    });
  }

  @override
  void dispose() {
    // The list was narrowed to one client; restore the org-wide list for the
    // shell's Manage Bookings page that shares this controller.
    if (_clientUserId != null && !controller.isClosed) {
      controller.ensureBookingsLoaded();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.fieldColorGrey,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.getAllBookingsLoading.value) {
                return const ShimmerLoader.table();
              }
              final showFilters = controller.isFilterVisible.value;
              final isEmpty = controller.filteredBookings.isEmpty;
              final page = controller.pagedBookings;
              final leading = <Widget Function()>[
                if (showFilters)
                  () => Column(
                        children: [
                          _buildFiltersCard(),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        ],
                      ),
                _buildListSummary,
              ];
              final bodyCount = isEmpty ? 1 : page.length;
              // Lazy list: only the visible booking cards are built.
              return ListView.builder(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                itemCount: leading.length + bodyCount + 1,
                itemBuilder: (context, index) {
                  if (index < leading.length) return leading[index]();
                  final i = index - leading.length;
                  if (i < bodyCount) {
                    return isEmpty ? _buildEmptyState() : _buildBookingCard(page[i]);
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                    child: _buildPagination(),
                  );
                },
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
      color: AppColor.whiteColor,
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
              : AppColor.fontColorGrey,
          side: BorderSide(
            color: controller.isFilterVisible.value
                ? Colors.blue.shade300
                : AppColor.divColor,
          ),
          backgroundColor: controller.isFilterVisible.value
              ? Colors.blue.shade50
              : AppColor.whiteColor,
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
      onPressed: controller.exportBookingsCsv,
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
        foregroundColor: AppColor.fontColorGrey,
        side: BorderSide(color: AppColor.divColor),
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
        color: AppColor.buttonTextWhite,
      ),
      label: Text(
        'New Booking',
        style: TextStyle(
          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 0.9,
          color: AppColor.buttonTextWhite,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.cPrimaryButtonColor,
        foregroundColor: AppColor.buttonTextWhite,
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
                    color: AppColor.fontColorGrey,
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
                label: 'Care Manager',
                hint: 'Select Care Manager',
                value: controller.careManagers
                        .any((m) => m.id == controller.selectedCareManagerId.value)
                    ? controller.selectedCareManagerId.value
                    : null,
                items: [
                  const DropdownMenuItem<int>(value: 0, child: Text('All Care Managers')),
                  ...controller.careManagers.map(
                    (manager) => DropdownMenuItem<int>(
                      value: manager.id,
                      child: Text(manager.userName),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    controller.selectedCareManagerId.value = value ?? 0,
              ),
            ),
            Obx(
              () => AppDropdown<int>(
                label: 'Service',
                hint: 'Select Service',
                value: controller.filterServices
                        .any((s) => s['id'] == controller.selectedServiceFilterId.value)
                    ? controller.selectedServiceFilterId.value
                    : null,
                items: [
                  const DropdownMenuItem<int>(value: 0, child: Text('All Services')),
                  ...controller.filterServices.map(
                    (s) => DropdownMenuItem<int>(
                      value: s['id'] as int,
                      child: Text(s['name'] as String, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    controller.selectedServiceFilterId.value = value ?? 0,
              ),
            ),
            Obx(
              () {
                final branches = controller.dashboardController.getAllBranches;
                return AppDropdown<int>(
                  label: 'Branch',
                  hint: 'Select Branch',
                  value: branches
                          .any((b) => b.brId == controller.selectedBranchFilterId.value)
                      ? controller.selectedBranchFilterId.value
                      : null,
                  items: [
                    const DropdownMenuItem<int>(value: 0, child: Text('All Branches')),
                    ...branches.map(
                      (b) => DropdownMenuItem<int>(
                        value: b.brId,
                        child: Text(b.brName, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      controller.selectedBranchFilterId.value = value ?? 0,
                );
              },
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
                              foregroundColor: AppColor.fontColorGrey,
                              side: BorderSide(color: AppColor.divColor),
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
                              controller.searchBookings();
                            },
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.cPrimaryButtonColor,
                              foregroundColor: AppColor.buttonTextWhite,
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
                            foregroundColor: AppColor.fontColorGrey,
                            side: BorderSide(color: AppColor.divColor),
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
                            controller.searchBookings();
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
                            foregroundColor: AppColor.buttonTextWhite,
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

  Widget _buildListSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical * 1,
      ),
      child: Text(
        'Showing ${controller.filteredBookings.length} of ${controller.allBookings.value.length} bookings',
        style: AppTextStyles.regular16Gre,
      ),
    );
  }

  Widget _buildEmptyState() {
    final isMobile = SizeConfig.isMobile;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 40 : SizeConfig.blockSizeVertical * 5),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: isMobile ? 48 : SizeConfig.blockSizeHorizontal * 5,
              color: AppColor.lightGrey,
            ),
            SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.5,
                color: AppColor.fontColorGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
    final isMobile = SizeConfig.isMobile;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
      decoration: BoxDecoration(
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
                    color: AppColor.buttonTextWhite,
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
                  BookingsController.statusLabel(booking.status),
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
                    color: AppColor.fontColorGrey,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
                  Expanded(
                    child: Text(
                      booking.userName ?? '-',
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
                    color: AppColor.fontColorGrey,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.3),
                  Text(
                    booking.userMobile ?? '-',
                    style: AppTextStyles.regular16Gre,
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.8),
              Text(
                'Patient: ${booking.patientName ?? '-'}',
                style: AppTextStyles.regular16,
              ),
              Text(
                'Age: ${booking.patientAge ?? '-'}',
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
                booking.serviceTypeName ?? '-',
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
                  booking.serviceName ?? '-',
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
                color: AppColor.fontColorGrey,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
              Expanded(
                child: Text(
                  booking.landmark ?? '-',
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColor.buttonTextWhite,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              Text(
                'Total: ${(booking.finalRate ?? (double.tryParse(booking.baseRate) ?? 0) * days).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 1,
                  fontWeight: FontWeight.w500,
                  color: AppColor.fontColorGrey,
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
                booking.careManagerName ?? '-',
                style: AppTextStyles.regular16,
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: SizeConfig.blockSizeHorizontal * 1.1,
                    color: AppColor.fontColorGrey,
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 0.5),
                  Flexible(
                    child: Text(
                      booking.careManagerMobile ?? '-',
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.buttonTextWhite,
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
                    BookingsController.statusLabel(booking.status),
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
            Icon(Icons.person_outline, size: 16, color: AppColor.fontColorGrey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(booking.userName ?? '-', style: AppTextStyles.regular16),
            ),
            Icon(Icons.phone_outlined, size: 14, color: AppColor.fontColorGrey),
            const SizedBox(width: 4),
            Text(booking.userMobile ?? '-', style: AppTextStyles.regular16Gre),
          ],
        ),
        const SizedBox(height: 4),
        Text('Patient: ${booking.patientName ?? '-'}  |  Age: ${booking.patientAge ?? '-'}',
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
                  Text(booking.serviceTypeName ?? '-', style: AppTextStyles.regular16),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      booking.serviceName ?? '-',
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
                  Icon(Icons.location_on_outlined, size: 16, color: AppColor.fontColorGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.landmark ?? '-',
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.buttonTextWhite),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${(booking.finalRate ?? (double.tryParse(booking.baseRate) ?? 0) * days).toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.fontColorGrey),
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
              Text('Care Manager: ', style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
              Expanded(child: Text(booking.careManagerName ?? '-', style: AppTextStyles.regular16)),
              if (booking.careManagerMobile != null) ...[
                Icon(Icons.phone_outlined, size: 14, color: AppColor.fontColorGrey),
                const SizedBox(width: 4),
                Text(booking.careManagerMobile ?? '-', style: AppTextStyles.regular16Gre),
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
        color: AppColor.fontColorGrey,
        size: isMobile ? 22 : SizeConfig.blockSizeHorizontal * 1.5,
      ),
      onSelected: (value) {
        if (value == 'view') {
          Get.to(() => ManageBookingView(bookingId: booking.id));
        } else if (value == 'edit') {
          Get.to(() => EditBookingView(bookingId: booking.id));
        }
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
    final total = controller.filteredBookings.length;
    final pages = controller.bookingsPageCount;
    final current = controller.bookingsPage.value;
    final from = total == 0 ? 0 : current * BookingsController.bookingsPageSize + 1;
    final to = ((current + 1) * BookingsController.bookingsPageSize).clamp(0, total);

    // Window of up to 5 page numbers around the current page.
    var first = (current - 2).clamp(0, pages - 1);
    final last = (first + 4).clamp(0, pages - 1);
    first = (last - 4).clamp(0, pages - 1);

    final fontSize = isMobile ? 13.0 : SizeConfig.blockSizeHorizontal * 1.1;
    Widget navButton(String label, VoidCallback? onPressed) => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.fontColorGrey,
            side: BorderSide(color: AppColor.divColor),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
              vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: TextStyle(fontSize: fontSize)),
        );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        navButton('Previous',
            current > 0 ? () => controller.goToBookingsPage(current - 1) : null),
        const SizedBox(width: 6),
        for (var p = first; p <= last; p++) ...[
          InkWell(
            onTap: () => controller.goToBookingsPage(p),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: p == current ? Colors.blue.shade600 : AppColor.whiteColor,
                border: p != current ? Border.all(color: AppColor.divColor) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${p + 1}',
                style: TextStyle(
                  fontSize: fontSize,
                  color: p == current ? AppColor.buttonTextWhite : AppColor.fontColorGrey,
                  fontWeight: p == current ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        navButton('Next',
            current < pages - 1 ? () => controller.goToBookingsPage(current + 1) : null),
      ],
    );

    final summary = Text(
      'Showing $from–$to of $total bookings',
      style: TextStyle(fontSize: fontSize, color: AppColor.fontColorGrey),
    );

    if (isMobile) {
      return Column(
        children: [
          summary,
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: controls),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [summary, controls],
    );
  }
}
