import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/modules/support/models/get_all_support_tickets.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/support_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  // Registered once on first access (shell page has no route binding).
  @override
  SupportController get controller => Get.isRegistered<SupportController>()
      ? Get.find<SupportController>()
      : Get.put(SupportController());

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SizeConfig.isMobile
          ? SingleChildScrollView(
              padding: SizeConfig.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _leftSectionMobile(),
                  const SizedBox(height: 16),
                  _rightSection(),
                ],
              ),
            )
          : LayoutBuilder(builder: (context, constraints) {
              // Inbox fills the height next to a side rail on large
              // screens; otherwise everything stacks and the page scrolls.
              final roomy =
                  constraints.maxWidth >= 1100 && constraints.maxHeight >= 700;
              if (roomy) {
                return Padding(
                  padding: SizeConfig.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._topSection(),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _leftSection()),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 300,
                              child: SingleChildScrollView(
                                child: _rightSection(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: SizeConfig.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._topSection(),
                    SizedBox(height: 620, child: _leftSection()),
                    const SizedBox(height: 20),
                    AppResponsiveGrid(
                      minItemWidth: 280,
                      maxColumns: 2,
                      children: [_quickLinks(), _supportHours()],
                    ),
                  ],
                ),
              );
            }),
    );
  }

  // ================= HEADER + SUMMARY =================

  List<Widget> _topSection() {
    return [
      const AppPageHeader(
        title: 'Support Center',
        subtitle: 'Manage customer support tickets and inquiries',
      ),
      const SizedBox(height: 24),
      Obx(() => controller.isStatsLoading.value
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _summaryCards(),
            )),
    ];
  }

  Widget _leftSectionMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppPageHeader(
          title: 'Support Center',
          subtitle: 'Manage customer support tickets and inquiries',
        ),
        const SizedBox(height: 16),
        Obx(() => controller.isStatsLoading.value
            ? const SizedBox()
            : _summaryCardsMobile()),
        const SizedBox(height: 16),
        AppCard(
          title: 'Recent Tickets',
          icon: LucideIcons.inbox,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ticketSearchBar(),
              Divider(height: 1, color: AppColor.borderSubtle),
              _ticketsListMobile(),
            ],
          ),
        ),
      ],
    );
  }

  /// Ticket inbox card; fills a bounded height.
  Widget _leftSection() {
    return AppCard(
      title: 'Recent Tickets',
      icon: LucideIcons.inbox,
      padding: EdgeInsets.zero,
      expandChild: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ticketSearchBar(),
          Divider(height: 1, color: AppColor.borderSubtle),
          Expanded(child: _ticketsList()),
        ],
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryCardsMobile() {
    return AppResponsiveGrid(
      minItemWidth: 140,
      maxColumns: 2,
      spacing: 12,
      children: _summaryTiles(),
    );
  }

  Widget _summaryCards() {
    return AppResponsiveGrid(
      minItemWidth: 200,
      maxColumns: 4,
      children: _summaryTiles(),
    );
  }

  /// Read inside the caller's `Obx`.
  List<Widget> _summaryTiles() {
    return [
      _summaryCard('Open Tickets', controller.openTickets.value,
          LucideIcons.messageSquare, AppTone.info),
      _summaryCard('In Progress', controller.inProgressTickets.value,
          LucideIcons.refreshCw, AppTone.warning),
      _summaryCard('Resolved Today', controller.resolvedToday.value,
          LucideIcons.circleCheck, AppTone.success),
      _summaryCard('Avg Response', controller.avgResponseTime.value,
          LucideIcons.timer, AppTone.violet),
    ];
  }

  Widget _summaryCard(String title, dynamic value, IconData icon, AppTone tone) {
    return AppStatCard(
      label: title,
      value: value.toString(),
      icon: icon,
      tone: tone,
    );
  }

  // ================= TICKETS =================

  Widget _ticketSearchBar() {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: SizeConfig.isMobile ? double.infinity : 340,
            child: AppSearchField(
              onChanged: controller.searchTickets,
              hint: 'Search by title, booking, user, or ticket #...',
            ),
          ),
          Obx(() => Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _ticketStatusChip('All', -1),
                  for (final s in const [
                    SupportController.statusOpen,
                    SupportController.statusInProgress,
                    SupportController.statusResolved,
                    SupportController.statusClosed,
                  ])
                    _ticketStatusChip(SupportController.statusLabel(s), s),
                ],
              )),
        ],
      ),
    );
  }

  Widget _ticketStatusChip(String label, int value) {
    final selected = controller.ticketStatusFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => controller.setTicketStatusFilter(value),
    );
  }

  Widget _ticketsListMobile() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ShimmerLoader.cardList();
      }

      if (controller.loadError.value.isNotEmpty &&
          controller.getAllSupportTicketsData.isEmpty) {
        return _errorState();
      }

      if (controller.filteredSupportTickets.isEmpty) {
        return _emptyState();
      }

      final tickets = controller.filteredSupportTickets;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tickets.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColor.borderSubtle),
            _ticketCard(tickets[i]),
          ],
        ],
      );
    });
  }

  Widget _ticketsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ShimmerLoader.cardList();
      }

      if (controller.loadError.value.isNotEmpty &&
          controller.getAllSupportTicketsData.isEmpty) {
        return SingleChildScrollView(child: _errorState());
      }

      if (controller.filteredSupportTickets.isEmpty) {
        return SingleChildScrollView(child: _emptyState());
      }

      return ListView.separated(
        itemCount: controller.filteredSupportTickets.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColor.borderSubtle),
        itemBuilder: (context, index) {
          final GetAllSupportTickets ticket =
          controller.filteredSupportTickets[index];
          return _ticketCard(ticket);
        },
      );
    });
  }

  Widget _emptyState() {
    return const AppEmptyState(
      compact: true,
      icon: LucideIcons.inbox,
      title: 'No tickets found',
    );
  }

  Widget _errorState() {
    return AppEmptyState(
      compact: true,
      icon: LucideIcons.circleAlert,
      tone: AppTone.danger,
      title: 'Could not load tickets',
      message: controller.loadError.value,
      actionLabel: 'Retry',
      actionIcon: LucideIcons.refreshCw,
      onAction: () {
        controller.getAllSupportTicketsApi();
        controller.getSupportStatsApi();
      },
    );
  }

  String _formatDate(DateTime? d) =>
      d == null ? '—' : DateFormat('dd MMM yyyy, hh:mm a').format(d.toLocal());

  bool _canChangeStatus(int status) =>
      status == SupportController.statusOpen ||
      status == SupportController.statusInProgress;

  /// Inbox row: subject, ticket meta, then status / requester / created time.
  Widget _ticketCard(GetAllSupportTickets ticket) {
    final isMobile = SizeConfig.isMobile;
    // Status can change only while the ticket is Open / In Progress
    final updateButton = _canChangeStatus(ticket.status)
        ? OutlinedButton.icon(
            onPressed: () => _showCloseTicketDialog(ticket),
            style: AppButtonStyles.compact,
            icon: const Icon(LucideIcons.notebookPen, size: 18),
            label: const Text('Update Status'),
          )
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) ...[
            AppIconTile(
              icon: LucideIcons.ticket,
              tone: _statusTone(ticket.status),
              size: 36,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ticket #${ticket.id} · ${controller.categoryName(ticket.supportTypeId)}'
                  '${ticket.bookingDetails.isNotEmpty && ticket.bookingDetails != 'NA' ? ' · Booking ${ticket.bookingDetails}' : ''}',
                  style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _statusChip(ticket.status),
                    _metaItem(LucideIcons.user, 'User ${ticket.userId}'),
                    _metaItem(LucideIcons.clock, _formatDate(ticket.createdOn)),
                  ],
                ),
                if (isMobile && updateButton != null) ...[
                  const SizedBox(height: 12),
                  updateButton,
                ],
              ],
            ),
          ),
          if (!isMobile && updateButton != null) ...[
            const SizedBox(width: 12),
            updateButton,
          ],
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColor.textTertiary),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 12.5, color: AppColor.textSecondary),
        ),
      ],
    );
  }

  // ================= CLOSE TICKET DIALOG =================

  void _showCloseTicketDialog(GetAllSupportTickets ticket) {
    controller.supportCommentsController.clear();
    final targets = [
      SupportController.statusInProgress,
      SupportController.statusResolved,
      SupportController.statusClosed,
    ].where((s) => s != ticket.status).toList();
    final RxInt target = SupportController.statusClosed.obs;

    final fieldLabel = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: AppColor.textSecondary,
    );

    Get.dialog(
      AppDialog(
        title: 'Update Ticket Status',
        subtitle: 'Ticket #${ticket.id}',
        icon: LucideIcons.notebookPen,
        onClose: () {
          if (!controller.updateSupportStatusLoading.value) Get.back();
        },
        actions: [
          OutlinedButton(
            onPressed: () {
              if (!controller.updateSupportStatusLoading.value) Get.back();
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.updateSupportStatusLoading.value
                ? null
                : () async {
              final ok = await controller.updateSupportStatus(
                  target.value, ticket.id);
              if (ok && (Get.isDialogOpen ?? false)) Get.back();
            },
            child: controller.updateSupportStatusLoading.value
                ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColor.textTertiary),
              ),
            )
                : const Text('Update'),
          )),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ticket Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColor.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _detailRow('Ticket ID', ticket.id.toString()),
                  _detailRow('Title', ticket.title),
                  _detailRow('Support Type',
                      controller.categoryName(ticket.supportTypeId)),
                  _detailRow('Status', SupportController.statusLabel(ticket.status)),
                  _detailRow('User ID', ticket.userId.toString()),
                  _detailRow('Created On', _formatDate(ticket.createdOn)),
                  _detailRow('Description',
                      ticket.description.isEmpty ? 'N/A' : ticket.description),
                  if (ticket.comments.isNotEmpty && ticket.comments != 'NA')
                    _detailRow('Comments', ticket.comments),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text('New Status', style: fieldLabel),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: targets
                      .map((s) => ChoiceChip(
                            label: Text(SupportController.statusLabel(s)),
                            selected: target.value == s,
                            onSelected: (_) => target.value = s,
                          ))
                      .toList(),
                )),
            const SizedBox(height: 16),

            // Comments Field
            Text('Comments', style: fieldLabel),
            const SizedBox(height: 8),
            TextField(
              controller: controller.supportCommentsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter comments (optional)...',
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _detailRow(String label, String value) {
    return AppInfoRow(
      label: label,
      value: value,
      horizontal: !SizeConfig.isMobile,
      labelWidth: 110,
    );
  }

  // ================= RIGHT =================

  Widget _rightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _quickLinks(),
        const SizedBox(height: 20),
        _supportHours(),
      ],
    );
  }

  Widget _quickLinks() {
    return AppCard(
      title: 'Quick Links',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _quickLinkItem(LucideIcons.fileText, 'Knowledge Base',
              'Browse help articles'),
          const SizedBox(height: 14),
          _quickLinkItem(
              LucideIcons.mail, 'Email Support', 'support@example.com'),
          const SizedBox(height: 14),
          _quickLinkItem(
              LucideIcons.phone, 'Phone Support', '+1 (555) 123-4567'),
        ],
      ),
    );
  }

  Widget _supportHours() {
    return AppCard(
      title: 'Support Hours',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hoursRow('Monday - Friday', '9:00 AM - 6:00 PM'),
          _hoursRow('Saturday', '10:00 AM - 4:00 PM'),
          _hoursRow('Sunday', 'Closed'),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _quickLinkItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        AppIconTile(icon: icon, tone: AppTone.primary, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hoursRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: TextStyle(fontSize: 13.5, color: AppColor.textTertiary)),
          Text(
            time,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  AppTone _statusTone(int status) {
    switch (status) {
      case SupportController.statusOpen:
        return AppTone.info;
      case SupportController.statusInProgress:
        return AppTone.warning;
      case SupportController.statusResolved:
        return AppTone.success;
      default:
        return AppTone.neutral;
    }
  }

  Widget _statusChip(int status) {
    return AppStatusBadge(
      label: SupportController.statusLabel(status),
      tone: _statusTone(status),
    );
  }
}
