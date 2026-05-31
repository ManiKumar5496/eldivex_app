import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_bookings_model.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import 'package:eldivex_app/app/widgets/shimmer_loader.dart';
import '../controllers/bookings_controller.dart';
import 'manage_bookings.dart';

class BookingsExtensionView extends StatefulWidget {
  const BookingsExtensionView({super.key});

  @override
  State<BookingsExtensionView> createState() => _BookingsExtensionViewState();
}

class _BookingsExtensionViewState extends State<BookingsExtensionView> {
  late final BookingsController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController());
    }
    controller = Get.find<BookingsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getBookingsFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.isMobile;

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
                  padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
                  child: Column(
                    children: [
                      _buildTabsAndFilter(),
                      SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 2),
                      _buildExtensionSummary(),
                      SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 2),
                      _buildExtensionList(),
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

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final isMobile = SizeConfig.isMobile;
    return Container(
      color: Colors.white,
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
              color: Colors.black87,
            ),
          ),
          SizedBox(width: isMobile ? 4 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking Extensions', style: AppTextStyles.heading),
                SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                Text(
                  'View and manage booking extension requests',
                  style: AppTextStyles.regular16W400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tabs + Date Filter
  // ─────────────────────────────────────────────
  Widget _buildTabsAndFilter() {
    final isMobile = SizeConfig.isMobile;

    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        children: [
          if (isMobile) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                children: [
                  _buildTab('Today', 0, controller.todayExtensions.length),
                  const SizedBox(width: 8),
                  _buildTab('Tomorrow', 1, controller.tomorrowExtensions.length),
                  const SizedBox(width: 8),
                  _buildTab('Next Day', 2, controller.nextDayExtensions.length),
                ],
              )),
            ),
            const SizedBox(height: 12),
            _buildDateFilter(),
          ] else
            Row(
              children: [
                Obx(() => Row(
                  children: [
                    _buildTab('Today', 0, controller.todayExtensions.length),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                    _buildTab('Tomorrow', 1, controller.tomorrowExtensions.length),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                    _buildTab('Next Day', 2, controller.nextDayExtensions.length),
                  ],
                )),
                const Spacer(),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 20,
                  child: _buildDateFilter(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final isSelected = controller.selectedExtensionTab.value == index;
    final isMobile = SizeConfig.isMobile;

    Color tabColor;
    switch (index) {
      case 0:
        tabColor = Colors.orange.shade600;
        break;
      case 1:
        tabColor = Colors.blue.shade600;
        break;
      case 2:
        tabColor = Colors.purple.shade600;
        break;
      default:
        tabColor = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: () => controller.selectedExtensionTab.value = index,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.5,
          vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1,
        ),
        decoration: BoxDecoration(
          color: isSelected ? tabColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? tabColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? tabColor : Colors.grey.shade600,
              ),
            ),
            SizedBox(width: isMobile ? 6 : SizeConfig.blockSizeHorizontal * 0.5),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.6,
                vertical: isMobile ? 2 : SizeConfig.blockSizeVertical * 0.2,
              ),
              decoration: BoxDecoration(
                color: isSelected ? tabColor : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: isMobile ? 11 : SizeConfig.blockSizeHorizontal * 0.9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    final isMobile = SizeConfig.isMobile;
    return Row(
      children: [
        Expanded(
          child: Obx(() => CommonDatePicker(
            label: 'Filter by Date',
            hint: 'Select Date',
            selectedDate: controller.extensionFilterDate.value,
            onDateSelected: (date) => controller.extensionFilterDate.value = date,
          )),
        ),
        Obx(() {
          if (controller.extensionFilterDate.value == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(left: isMobile ? 4 : 8, top: 18),
            child: IconButton(
              onPressed: () => controller.clearExtensionFilter(),
              icon: Icon(Icons.clear, size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.5),
              tooltip: 'Clear filter',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade600,
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Summary Cards
  // ─────────────────────────────────────────────
  Widget _buildExtensionSummary() {
    final isMobile = SizeConfig.isMobile;

    return Obx(() {
      final summaryItems = [
        _SummaryData('Total Extensions', controller.extensionBookings.length, Icons.extension, Colors.indigo),
        _SummaryData('Today', controller.todayExtensions.length, Icons.today, Colors.orange),
        _SummaryData('Tomorrow', controller.tomorrowExtensions.length, Icons.upcoming, Colors.blue),
        _SummaryData('Next Day', controller.nextDayExtensions.length, Icons.calendar_month, Colors.purple),
      ];

      if (isMobile) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: summaryItems.map((s) => _buildSummaryCard(s)).toList(),
        );
      }

      return Row(
        children: summaryItems
            .expand((s) => [
                  Expanded(child: _buildSummaryCard(s)),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                ])
            .toList()
          ..removeLast(),
      );
    });
  }

  Widget _buildSummaryCard(_SummaryData data) {
    final isMobile = SizeConfig.isMobile;
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              data.icon,
              size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.8,
              color: data.color,
            ),
          ),
          SizedBox(width: isMobile ? 10 : SizeConfig.blockSizeHorizontal * 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${data.count}',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.8,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : SizeConfig.blockSizeHorizontal * 0.9,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Extension List
  // ─────────────────────────────────────────────
  Widget _buildExtensionList() {
    final isMobile = SizeConfig.isMobile;

    return Obx(() {
      final bookings = controller.currentExtensionTabBookings;

      if (bookings.isEmpty) {
        return Container(
          decoration: _cardDecoration(),
          padding: EdgeInsets.all(isMobile ? 40 : SizeConfig.blockSizeVertical * 5),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.extension_off,
                  size: isMobile ? 48 : SizeConfig.blockSizeHorizontal * 5,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                Text(
                  'No extension bookings found',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 8 : SizeConfig.blockSizeVertical * 1),
            child: Text(
              'Showing ${bookings.length} extension bookings',
              style: AppTextStyles.regular16Gre,
            ),
          ),
          if (!isMobile) _buildTableHeader(),
          ...bookings.map((b) => isMobile ? _buildMobileCard(b) : _buildDesktopRow(b)),
        ],
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 1.5,
        vertical: SizeConfig.blockSizeVertical * 1.2,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _headerCell('Booking ID', flex: 1),
          _headerCell('Patient', flex: 2),
          _headerCell('Service', flex: 2),
          _headerCell('Service End Date', flex: 2),
          _headerCell('City', flex: 1),
          _headerCell('Status', flex: 2),
          _headerCell('Care Manager', flex: 2),
          _headerCell('Actions', flex: 1),
        ],
      ),
    );
  }

  Widget _headerCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal * 1.1,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildDesktopRow(GetBookingsModel booking) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 1.5,
        vertical: SizeConfig.blockSizeVertical * 1.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 0.8,
                vertical: SizeConfig.blockSizeVertical * 0.4,
              ),
              decoration: BoxDecoration(
                color: AppColor.cPrimaryButtonColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'BK-${booking.id}',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 0.95,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.patientName ?? '-',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Age: ${booking.patientAge ?? '-'}',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 0.9,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName ?? '-',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                    color: Colors.black87,
                  ),
                ),
                _buildServiceTypeBadge(booking.serviceTypeName),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(booking.serviceEndDate),
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              booking.city ?? '-',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(booking.status ?? 'Unknown'),
          ),
          Expanded(
            flex: 2,
            child: Text(
              booking.careManagerName ?? '-',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 1.1,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.to(() => ManageBookingView(bookingId: booking.id)),
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: SizeConfig.blockSizeHorizontal * 1.5,
                    color: Colors.blue.shade600,
                  ),
                  tooltip: 'View Booking',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(GetBookingsModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status ?? 'Unknown'),
              ],
            ),
            const SizedBox(height: 10),
            _mobileField(Icons.person_outline, 'Patient', booking.patientName ?? '-'),
            const SizedBox(height: 6),
            _mobileField(Icons.medical_services_outlined, 'Service', booking.serviceName ?? '-'),
            const SizedBox(height: 6),
            _mobileField(Icons.calendar_today, 'Service End', _formatDate(booking.serviceEndDate)),
            const SizedBox(height: 6),
            _mobileField(Icons.location_on_outlined, 'City', booking.city ?? '-'),
            const SizedBox(height: 6),
            _mobileField(Icons.support_agent, 'Care Manager', booking.careManagerName ?? '-'),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildServiceTypeBadge(booking.serviceTypeName),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Get.to(() => ManageBookingView(bookingId: booking.id)),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileField(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Shared Helpers
  // ─────────────────────────────────────────────
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    final isMobile = SizeConfig.isMobile;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'hp assigned':
        bgColor = Colors.teal.shade50;
        textColor = Colors.teal.shade700;
        break;
      case 'booking submitted':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'cancelled':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case 'completed':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
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
          fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 0.95,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildServiceTypeBadge(String? serviceType) {
    final isMobile = SizeConfig.isMobile;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8,
        vertical: isMobile ? 2 : SizeConfig.blockSizeVertical * 0.3,
      ),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        serviceType ?? '-',
        style: TextStyle(
          fontSize: isMobile ? 11 : SizeConfig.blockSizeHorizontal * 0.85,
          fontWeight: FontWeight.w500,
          color: Colors.pink.shade700,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
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
  );
}

class _SummaryData {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  _SummaryData(this.label, this.count, this.icon, this.color);
}