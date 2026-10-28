import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_bookings_model.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import 'package:eldivex_app/app/widgets/shimmer_loader.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../routes/app_pages.dart';
import '../controllers/bookings_controller.dart';
import 'manage_bookings.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class BookingsExtensionView extends StatefulWidget {
  const BookingsExtensionView({super.key});

  @override
  State<BookingsExtensionView> createState() => _BookingsExtensionViewState();
}

class _BookingsExtensionViewState extends State<BookingsExtensionView> {
  late final BookingsController controller;

  /// Below this width the desktop table scrolls horizontally.
  static const double _tableMinWidth = 960;

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
    final pad = SizeConfig.pagePadding;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 20),
            child: _buildHeader(context),
          ),
          Expanded(
            child: Obx(() {
              if (controller.getAllBookingsLoading.value) {
                return const ShimmerLoader.table();
              }
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad.left, 0, pad.right, pad.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildExtensionSummary(),
                    const SizedBox(height: 20),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTabsAndFilter(),
                          Divider(height: 1, color: AppColor.borderSubtle),
                          _buildExtensionList(),
                        ],
                      ),
                    ),
                  ],
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
    // In the main shell the sidebar handles navigation, so the back button is
    // only shown if this page is ever opened as a standalone route.
    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    final inShell = routeName.startsWith(Routes.MAIN);
    return AppPageHeader(
      title: 'Booking Extensions',
      subtitle: 'View and manage booking extension requests',
      onBack: inShell ? null : () => Get.back(),
    );
  }

  // ─────────────────────────────────────────────
  // Tabs + Date Filter
  // ─────────────────────────────────────────────
  Widget _buildTabsAndFilter() {
    final isMobile = SizeConfig.isMobile;

    final tabs = Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTab('Overdue', 3, controller.overdueExtensions.length),
            _buildTab('Today', 0, controller.todayExtensions.length),
            _buildTab('Tomorrow', 1, controller.tomorrowExtensions.length),
            _buildTab('Next Day', 2, controller.nextDayExtensions.length),
          ],
        ));

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tabs,
                const SizedBox(height: 16),
                _buildDateFilter(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Align(alignment: Alignment.bottomLeft, child: tabs)),
                const SizedBox(width: 16),
                SizedBox(width: 300, child: _buildDateFilter()),
              ],
            ),
    );
  }

  AppTone _tabTone(int index) {
    switch (index) {
      case 0:
        return AppTone.warning;
      case 1:
        return AppTone.info;
      case 2:
        return AppTone.violet;
      case 3:
        return AppTone.danger;
      default:
        return AppTone.neutral;
    }
  }

  Widget _buildTab(String label, int index, int count) {
    final isSelected = controller.selectedExtensionTab.value == index;
    final tone = _tabTone(index);
    final radius = BorderRadius.circular(AppRadius.md);

    return Material(
      color: isSelected ? tone.soft : AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isSelected ? tone.color.withValues(alpha: 0.55) : AppColor.divColor,
        ),
      ),
      child: InkWell(
        onTap: () => controller.selectedExtensionTab.value = index,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? tone.color : AppColor.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? tone.color : AppColor.neutralSoft,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColor.pureWhite : AppColor.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
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
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: () => controller.clearExtensionFilter(),
              icon: const Icon(LucideIcons.x, size: 18),
              tooltip: 'Clear filter',
              style: IconButton.styleFrom(
                backgroundColor: AppColor.dangerSoft,
                foregroundColor: AppColor.danger,
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
    return Obx(() {
      final summaryItems = [
        _SummaryData('Total Extensions', controller.extensionBookings.length,
            LucideIcons.calendarPlus, AppTone.primary),
        _SummaryData('Overdue', controller.overdueExtensions.length,
            LucideIcons.calendarX, AppTone.danger),
        _SummaryData('Today', controller.todayExtensions.length,
            LucideIcons.calendarCheck2, AppTone.warning),
        _SummaryData('Tomorrow', controller.tomorrowExtensions.length,
            LucideIcons.calendarClock, AppTone.info),
        _SummaryData('Next Day', controller.nextDayExtensions.length,
            LucideIcons.calendarDays, AppTone.violet),
      ];

      return AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 5,
        children: summaryItems.map((s) => _buildSummaryCard(s)).toList(),
      );
    });
  }

  Widget _buildSummaryCard(_SummaryData data) {
    return AppStatCard(
      label: data.label,
      value: '${data.count}',
      icon: data.icon,
      tone: data.tone,
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
        return const AppEmptyState(
          icon: LucideIcons.calendarX2,
          title: 'No extension bookings found',
          message: 'Try another day or clear the date filter.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMobile)
            for (var i = 0; i < bookings.length; i++) ...[
              _buildMobileCard(bookings[i]),
              if (i < bookings.length - 1)
                Divider(height: 1, color: AppColor.borderSubtle),
            ]
          else
            LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth < _tableMinWidth
                  ? _tableMinWidth
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTableHeader(),
                      for (var i = 0; i < bookings.length; i++)
                        _buildDesktopRow(bookings[i],
                            showDivider: i < bookings.length - 1),
                    ],
                  ),
                ),
              );
            }),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColor.borderSubtle)),
            ),
            child: Text(
              'Showing ${bookings.length} extension bookings',
              style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
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
          _headerCell('Actions', flex: 1, alignEnd: true),
        ],
      ),
    );
  }

  Widget _headerCell(String title, {int flex = 1, bool alignEnd = false}) {
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

  Widget _cell(Widget child, {int flex = 1}) => Expanded(
        flex: flex,
        child: Padding(padding: const EdgeInsets.only(right: 12), child: child),
      );

  Widget _buildDesktopRow(GetBookingsModel booking, {bool showDivider = true}) {
    final primary = TextStyle(fontSize: 14, color: AppColor.textPrimary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppColor.borderSubtle))
            : null,
      ),
      child: Row(
        children: [
          _cell(
            Text(
              'BK-${booking.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            flex: 1,
          ),
          _cell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.patientName ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: primary.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Age: ${booking.patientAge ?? '-'}',
                  style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                ),
              ],
            ),
            flex: 2,
          ),
          _cell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: primary,
                ),
                const SizedBox(height: 4),
                _buildServiceTypeBadge(booking.serviceTypeName),
              ],
            ),
            flex: 2,
          ),
          _cell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(booking.serviceEndDate), style: primary),
                if (_overdueLabel(booking) != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _overdueLabel(booking)!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.danger,
                    ),
                  ),
                ],
              ],
            ),
            flex: 2,
          ),
          _cell(
            Text(
              booking.city ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
            ),
            flex: 1,
          ),
          _cell(
            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildStatusBadge(booking.status ?? 'Unknown'),
              ),
            ),
            flex: 2,
          ),
          _cell(
            Text(
              booking.careManagerName ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: primary,
            ),
            flex: 2,
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Get.to(() => ManageBookingView(bookingId: booking.id)),
                icon: const Icon(LucideIcons.eye, size: 18),
                tooltip: 'View Booking',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(GetBookingsModel booking) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'BK-${booking.id}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              _buildStatusBadge(booking.status ?? 'Unknown'),
            ],
          ),
          const SizedBox(height: 12),
          _mobileField(LucideIcons.user, 'Patient', booking.patientName ?? '-'),
          const SizedBox(height: 6),
          _mobileField(LucideIcons.stethoscope, 'Service', booking.serviceName ?? '-'),
          const SizedBox(height: 6),
          _mobileField(LucideIcons.calendar, 'Service End', _formatDate(booking.serviceEndDate)),
          if (_overdueLabel(booking) != null)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Text(
                _overdueLabel(booking)!,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColor.danger,
                ),
              ),
            ),
          const SizedBox(height: 6),
          _mobileField(LucideIcons.mapPin, 'City', booking.city ?? '-'),
          const SizedBox(height: 6),
          _mobileField(LucideIcons.headset, 'Care Manager', booking.careManagerName ?? '-'),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(child: _buildServiceTypeBadge(booking.serviceTypeName)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Get.to(() => ManageBookingView(bookingId: booking.id)),
                icon: const Icon(LucideIcons.eye, size: 18),
                label: const Text('View'),
                style: AppButtonStyles.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileField(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: AppColor.textPrimary, fontWeight: FontWeight.w600),
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

  String? _overdueLabel(GetBookingsModel booking) {
    final days = booking.overdueDays ?? 0;
    if (booking.extensionStatus != 4 || days <= 0) return null;
    return days == 1 ? '1 day overdue' : '$days days overdue';
  }

  Widget _buildStatusBadge(String status) {
    return AppStatusBadge(label: status, tone: toneForStatus(status));
  }

  Widget _buildServiceTypeBadge(String? serviceType) {
    const tone = AppTone.violet;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        serviceType ?? '-',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tone.color,
        ),
      ),
    );
  }
}

class _SummaryData {
  final String label;
  final int count;
  final IconData icon;
  final AppTone tone;

  _SummaryData(this.label, this.count, this.icon, this.tone);
}
