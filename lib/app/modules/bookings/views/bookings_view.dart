import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_bookings_model.dart';
import 'package:eldivex_app/app/modules/bookings/views/edit_booking_view.dart';
import 'package:eldivex_app/app/modules/bookings/views/manage_bookings.dart';
import 'package:eldivex_app/app/widgets/common_textfield.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import 'package:eldivex_app/app/widgets/dropdown_common.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/bookings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  late final BookingsController controller;
  Map<String, dynamic>? data;
  int? _clientUserId;

  /// Below this width the desktop table scrolls horizontally instead of
  /// squeezing its columns.
  static const double _tableMinWidth = 1040;

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
              final showFilters = controller.isFilterVisible.value;
              final isEmpty = controller.filteredBookings.isEmpty;
              final page = controller.pagedBookings;
              return ListView(
                padding: EdgeInsets.fromLTRB(pad.left, 0, pad.right, pad.bottom),
                children: [
                  _buildStatusFilterRow(),
                  const SizedBox(height: 16),
                  _buildBookingsCard(
                    page: page,
                    isEmpty: isEmpty,
                    showFilters: showFilters,
                  ),
                ],
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
    // Inside the main shell the sidebar handles navigation; the back button is
    // only shown when this page is opened as its own route (e.g. from a client).
    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    final inShell = routeName.startsWith(Routes.MAIN);
    return AppPageHeader(
      title: 'Manage Bookings',
      subtitle: 'View and manage all booking reservations',
      onBack: inShell
          ? null
          : () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(Routes.MAIN);
              }
            },
      actions: [
        _buildExportButton(),
        if (data?["userId"] != null) _buildNewBookingButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Obx(
      () => OutlinedButton.icon(
        onPressed: () {
          controller.toggleFilters();
        },
        icon: Icon(
          controller.isFilterVisible.value
              ? LucideIcons.chevronUp
              : LucideIcons.listFilter,
          size: 18,
        ),
        label: Text(
          controller.isFilterVisible.value ? 'Hide filters' : 'Filters',
        ),
        style: controller.isFilterVisible.value
            ? OutlinedButton.styleFrom(
                foregroundColor: AppColor.cAppPrimaryColor,
                backgroundColor: AppColor.primarySoft,
                side: BorderSide(
                  color: AppColor.cAppPrimaryColor.withValues(alpha: 0.4),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildExportButton() {
    return OutlinedButton.icon(
      onPressed: controller.exportBookingsCsv,
      icon: const Icon(LucideIcons.download, size: 18),
      label: const Text('Export'),
    );
  }

  Widget _buildNewBookingButton() {
    return ElevatedButton.icon(
      onPressed: () {
        controller.resetCreateBookingForm();
        Get.toNamed(Routes.createBookings, arguments: data);
      },
      icon: const Icon(LucideIcons.plus, size: 18),
      label: const Text('New booking'),
    );
  }

  // ─────────────────────────────────────────────
  // Status KPI / quick filter row
  // ─────────────────────────────────────────────
  /// One tile per booking status with its count in the loaded list. Tapping a
  /// tile sets the same status filter the filter panel uses and re-applies
  /// the filters, exactly like choosing it there and pressing Search.
  Widget _buildStatusFilterRow() {
    final all = controller.allBookings.value;
    final counts = <String, int>{};
    for (final b in all) {
      final label = BookingsController.statusLabel(b.status);
      counts[label] = (counts[label] ?? 0) + 1;
    }
    final selected = controller.selectedBookingStatus.value;

    final tiles = <Widget>[
      _StatusFilterTile(
        label: 'All bookings',
        count: all.length,
        tone: AppTone.primary,
        selected: selected.isEmpty,
        onTap: () {
          controller.selectedBookingStatus.value = '';
          controller.searchBookings();
        },
      ),
      for (final label in controller.bookingStatuses)
        _StatusFilterTile(
          label: label,
          count: counts[label] ?? 0,
          tone: toneForStatus(label),
          selected: selected == label,
          onTap: () {
            controller.selectedBookingStatus.value = label;
            controller.searchBookings();
          },
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tiles
            .expand((t) => [t, const SizedBox(width: 12)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // List card (toolbar + filters + table + pagination)
  // ─────────────────────────────────────────────
  Widget _buildBookingsCard({
    required List<GetBookingsModel> page,
    required bool isEmpty,
    required bool showFilters,
  }) {
    final isMobile = SizeConfig.isMobile;
    return AppCard(
      title: 'Bookings',
      subtitle: _listSummaryText(),
      padding: EdgeInsets.zero,
      actions: [
        AppSearchField(
          controller: controller.nameController,
          hint: 'Search client name…',
          width: isMobile ? null : 260,
          onChanged: (_) => controller.searchBookings(),
        ),
        _buildFilterButton(),
      ],
      footer: isEmpty ? null : _buildPagination(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showFilters) ...[
            _buildFiltersCard(),
            Divider(height: 1, color: AppColor.borderSubtle),
          ],
          if (isEmpty)
            _buildEmptyState()
          else if (isMobile)
            ..._buildMobileList(page)
          else
            _buildDesktopTable(page),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    final isMobile = SizeConfig.isMobile;
    return Container(
      color: AppColor.surfaceMuted,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.slidersHorizontal, size: 18, color: AppColor.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close filters',
                onPressed: () {
                  controller.toggleFilters();
                },
                icon: Icon(
                  LucideIcons.x,
                  size: 18,
                  color: AppColor.textTertiary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppResponsiveGrid(
            minItemWidth: 220,
            maxColumns: 3,
            spacing: 16,
            children: [
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
            ],
          ),
          const SizedBox(height: 20),
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
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.searchBookings();
                            },
                            icon: const Icon(LucideIcons.search, size: 18),
                            label: const Text('Search'),
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
                        child: const Text('Reset all filters'),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.clearFilters();
                      },
                      child: const Text('Reset all filters'),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                      },
                      child: const Text('Clear'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.searchBookings();
                      },
                      icon: const Icon(LucideIcons.search, size: 18),
                      label: const Text('Search'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  String _listSummaryText() {
    return 'Showing ${controller.filteredBookings.length} of ${controller.allBookings.value.length} bookings';
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: LucideIcons.calendarX,
      title: 'No bookings found',
      message: 'Try a different status or adjust the filters.',
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

  String _totalText(GetBookingsModel booking, int days) =>
      'Total: ${(booking.finalRate ?? (double.tryParse(booking.baseRate) ?? 0) * days).toStringAsFixed(0)}';

  Widget _statusBadge(String? status) {
    final label = BookingsController.statusLabel(status);
    return AppStatusBadge(label: label, tone: toneForStatus(label));
  }

  // ─────────────────────────────────────────────
  // Desktop / tablet table
  // ─────────────────────────────────────────────
  static const _colFlex = <int>[17, 20, 17, 14, 14, 12, 16, 12];
  static const double _actionsWidth = 44;
  static const double _cellGap = 12;

  Widget _tableRow(List<Widget> cells, {Widget? trailing}) {
    final children = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      children.add(Expanded(flex: _colFlex[i], child: cells[i]));
      children.add(const SizedBox(width: _cellGap));
    }
    children.add(SizedBox(
      width: _actionsWidth,
      child: Align(alignment: Alignment.topRight, child: trailing),
    ));
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildDesktopTable(List<GetBookingsModel> page) {
    return LayoutBuilder(builder: (context, constraints) {
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
              for (var i = 0; i < page.length; i++)
                _HoverRow(
                  showDivider: i < page.length - 1,
                  child: _buildBookingCard(page[i]),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    Widget h(String text, {bool numeric = false}) => Text(
          text,
          textAlign: numeric ? TextAlign.right : TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColor.textTertiary,
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: _tableRow([
        h('Booking'),
        h('Client & patient'),
        h('Service'),
        h('Location'),
        h('Schedule'),
        h('Rate', numeric: true),
        h('Care manager'),
        h('Remarks'),
      ]),
    );
  }

  Widget _buildBookingCard(GetBookingsModel booking) {
    final days = _calculateDays(
      booking.serviceStartDate,
      booking.serviceEndDate,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: _buildDesktopBookingCardContent(booking, days),
    );
  }

  Widget _buildDesktopBookingCardContent(GetBookingsModel booking, int days) {
    return _tableRow(
      [
        // Booking Details
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BK-${booking.id}',
              style: _strong,
            ),
            const SizedBox(height: 4),
            _IconText(
              icon: LucideIcons.calendar,
              text: _formatDate(booking.createdOn),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _statusBadge(booking.status),
            ),
          ],
        ),
        // User & Patient
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.userName ?? '-',
              style: _strong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _IconText(icon: LucideIcons.phone, text: booking.userMobile ?? '-'),
            const SizedBox(height: 8),
            Text(
              'Patient: ${booking.patientName ?? '-'}',
              style: _body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text('Age: ${booking.patientAge ?? '-'}', style: _caption),
          ],
        ),
        // Service
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.serviceTypeName ?? '-',
              style: _body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _Pill(text: booking.serviceName ?? '-', tone: AppTone.violet),
          ],
        ),
        // Address
        _IconText(
          icon: LucideIcons.mapPin,
          text: booking.landmark ?? '-',
          maxLines: 2,
          style: _body,
        ),
        // Period
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconText(
              icon: LucideIcons.calendar,
              iconColor: AppColor.success,
              text: _formatDate(booking.serviceStartDate),
              style: _body,
            ),
            const SizedBox(height: 4),
            _IconText(
              icon: LucideIcons.calendar,
              iconColor: AppColor.danger,
              text: _formatDate(booking.serviceEndDate),
              style: _body,
            ),
            const SizedBox(height: 4),
            Text('$days days', style: _caption),
          ],
        ),
        // Rate
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Pill(text: '${booking.baseRate}/day', tone: AppTone.info),
            const SizedBox(height: 6),
            Text(
              _totalText(booking, days),
              textAlign: TextAlign.right,
              style: _caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        // Health Professional
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.careManagerName ?? '-',
              style: _body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _IconText(
              icon: LucideIcons.phone,
              text: booking.careManagerMobile ?? '-',
            ),
          ],
        ),
        // Remarks
        Text(
          booking.splCareRequirements ?? booking.splInstructions ?? '',
          style: _caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      // Actions
      trailing: _buildBookingPopupMenu(booking),
    );
  }

  // ─────────────────────────────────────────────
  // Mobile list
  // ─────────────────────────────────────────────
  List<Widget> _buildMobileList(List<GetBookingsModel> page) {
    return [
      for (var i = 0; i < page.length; i++) ...[
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildMobileBookingCardContent(
            page[i],
            _calculateDays(page[i].serviceStartDate, page[i].serviceEndDate),
          ),
        ),
        if (i < page.length - 1) Divider(height: 1, color: AppColor.borderSubtle),
      ],
    ];
  }

  Widget _buildMobileBookingCardContent(GetBookingsModel booking, int days) {
    final remarks = booking.splCareRequirements ?? booking.splInstructions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Booking ID, Status, Actions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('BK-${booking.id}', style: _strong.copyWith(fontSize: 15)),
                  _statusBadge(booking.status),
                ],
              ),
            ),
            _buildBookingPopupMenu(booking),
          ],
        ),
        // Created date
        _IconText(
          icon: LucideIcons.calendar,
          text: _formatDate(booking.createdOn),
        ),
        const SizedBox(height: 12),
        // User & Patient info
        Row(
          children: [
            Icon(LucideIcons.user, size: 16, color: AppColor.textTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                booking.userName ?? '-',
                style: _strong,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(LucideIcons.phone, size: 14, color: AppColor.textTertiary),
            const SizedBox(width: 4),
            Text(booking.userMobile ?? '-', style: _caption),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Patient: ${booking.patientName ?? '-'}  |  Age: ${booking.patientAge ?? '-'}',
          style: _caption,
        ),
        const SizedBox(height: 12),
        // Service & Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.serviceTypeName ?? '-', style: _body),
                  const SizedBox(height: 4),
                  _Pill(text: booking.serviceName ?? '-', tone: AppTone.violet),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _IconText(
                icon: LucideIcons.mapPin,
                text: booking.landmark ?? '-',
                maxLines: 2,
                style: _body,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Period & Rate
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconText(
                      icon: LucideIcons.calendar,
                      iconColor: AppColor.success,
                      text: _formatDate(booking.serviceStartDate),
                      style: _body,
                    ),
                    const SizedBox(height: 4),
                    _IconText(
                      icon: LucideIcons.calendar,
                      iconColor: AppColor.danger,
                      text: _formatDate(booking.serviceEndDate),
                      style: _body,
                    ),
                    const SizedBox(height: 4),
                    Text('$days days', style: _caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Pill(text: '${booking.baseRate}/day', tone: AppTone.info),
                  const SizedBox(height: 6),
                  Text(
                    _totalText(booking, days),
                    style: _caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Care Manager
        if (booking.careManagerName != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Care Manager: ', style: _caption),
              Expanded(
                child: Text(
                  booking.careManagerName ?? '-',
                  style: _body,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (booking.careManagerMobile != null) ...[
                Icon(LucideIcons.phone, size: 14, color: AppColor.textTertiary),
                const SizedBox(width: 4),
                Text(booking.careManagerMobile ?? '-', style: _caption),
              ],
            ],
          ),
        ],
        // Remarks
        if (remarks != null) ...[
          const SizedBox(height: 8),
          Text(
            booking.splCareRequirements ?? booking.splInstructions ?? '',
            style: _caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildBookingPopupMenu(GetBookingsModel booking) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: Icon(
        LucideIcons.ellipsis,
        color: AppColor.textTertiary,
        size: 20,
      ),
      onSelected: (value) {
        if (value == 'view') {
          Get.to(() => ManageBookingView(bookingId: booking.id));
        } else if (value == 'edit') {
          Get.to(() => EditBookingView(bookingId: booking.id));
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(LucideIcons.eye, size: 18),
              SizedBox(width: 10),
              Text('Manage Booking'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.pencil, size: 18),
              SizedBox(width: 10),
              Text('Edit'),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Pagination (card footer)
  // ─────────────────────────────────────────────
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

    Widget navButton(String label, VoidCallback? onPressed) => OutlinedButton(
          onPressed: onPressed,
          style: AppButtonStyles.compact,
          child: Text(label),
        );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        navButton('Previous',
            current > 0 ? () => controller.goToBookingsPage(current - 1) : null),
        const SizedBox(width: 6),
        for (var p = first; p <= last; p++) ...[
          _PageNumber(
            number: p + 1,
            selected: p == current,
            onTap: () => controller.goToBookingsPage(p),
          ),
          const SizedBox(width: 4),
        ],
        const SizedBox(width: 2),
        navButton('Next',
            current < pages - 1 ? () => controller.goToBookingsPage(current + 1) : null),
      ],
    );

    final summary = Text(
      'Showing $from–$to of $total bookings',
      style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
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
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 10,
      children: [summary, controls],
    );
  }

  // ─────────────────────────────────────────────
  // Text styles
  // ─────────────────────────────────────────────
  TextStyle get _strong => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  TextStyle get _body => TextStyle(fontSize: 13.5, color: AppColor.textPrimary);

  TextStyle get _caption => TextStyle(fontSize: 12.5, color: AppColor.textTertiary);
}

// ─────────────────────────────────────────────
// Private presentation widgets
// ─────────────────────────────────────────────

/// Selectable KPI tile for the status quick-filter strip.
class _StatusFilterTile extends StatelessWidget {
  const _StatusFilterTile({
    required this.label,
    required this.count,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final AppTone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);
    return Material(
      color: selected ? AppColor.primarySoft : AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected
              ? AppColor.cAppPrimaryColor.withValues(alpha: 0.55)
              : AppColor.divColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minWidth: 148),
          padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: tone.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColor.cAppPrimaryColor
                          : AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppColor.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Table row with a hover tint and an optional bottom hairline.
class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.child, this.showDivider = true});

  final Widget child;
  final bool showDivider;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? AppColor.surfaceMuted : Colors.transparent,
          border: widget.showDivider
              ? Border(bottom: BorderSide(color: AppColor.borderSubtle))
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Small tinted label that ellipsizes inside narrow table cells.
class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.tone});

  final String text;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        text,
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

/// Muted leading icon + text, ellipsized.
class _IconText extends StatelessWidget {
  const _IconText({
    required this.icon,
    required this.text,
    this.iconColor,
    this.style,
    this.maxLines = 1,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 13, color: iconColor ?? AppColor.textTertiary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: style ??
                TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
          ),
        ),
      ],
    );
  }
}

/// Page number button for the pagination footer.
class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.sm);
    return Material(
      color: selected ? AppColor.cAppPrimaryColor : AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected ? BorderSide.none : BorderSide(color: AppColor.divColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColor.buttonTextWhite : AppColor.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
