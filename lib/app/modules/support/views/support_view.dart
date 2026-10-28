import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/modules/support/models/get_all_support_tickets.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/support_controller.dart';

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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _leftSectionMobile(),
                  const SizedBox(height: 16),
                  _rightSection(),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _leftSection()),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _rightSection()),
                ],
              ),
            ),
    );
  }


  Widget _leftSectionMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support Center', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text(
          'Manage customer support tickets and inquiries',
          style: AppTextStyles.regular14Gre,
        ),
        const SizedBox(height: 16),
        Obx(() => controller.isStatsLoading.value ? const SizedBox() : _summaryCardsMobile()),
        const SizedBox(height: 16),
        Text('Recent Tickets', style: AppTextStyles.semiBold18),
        const SizedBox(height: 12),
        _ticketSearchBar(),
        const SizedBox(height: 12),
        _ticketsListMobile(),
      ],
    );
  }

  Widget _leftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support Center', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text(
          'Manage customer support tickets and inquiries',
          style: AppTextStyles.regular14Gre,
        ),
        const SizedBox(height: 24),
        Obx(() => controller.isStatsLoading.value ? const SizedBox() : _summaryCards()),
        const SizedBox(height: 24),
        Text('Recent Tickets', style: AppTextStyles.semiBold18),
        const SizedBox(height: 16),
        _ticketSearchBar(),
        const SizedBox(height: 12),
        Expanded(child: _ticketsList()),
      ],
    );
  }

  // ================= SUMMARY =================

  Widget _summaryCardsMobile() {
    return Column(
      children: [
        _summaryCardMobile('Open Tickets', controller.openTickets.value,
            Icons.chat_bubble_outline, Colors.blue),
        const SizedBox(height: 8),
        _summaryCardMobile('In Progress', controller.inProgressTickets.value,
            Icons.autorenew, Colors.orange),
        const SizedBox(height: 8),
        _summaryCardMobile('Resolved Today', controller.resolvedToday.value,
            Icons.check_circle, Colors.green),
        const SizedBox(height: 8),
        _summaryCardMobile('Avg Response', controller.avgResponseTime.value,
            Icons.timer_outlined, Colors.purple, isText: true),
      ],
    );
  }

  Widget _summaryCardMobile(String title, dynamic value, IconData icon, Color color,
      {bool isText = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.regular14Gre),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: AppTextStyles.bold20,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return Row(
      children: [
        _summaryCard('Open Tickets', controller.openTickets.value,
            Icons.chat_bubble_outline, Colors.blue),
        _summaryCard('In Progress', controller.inProgressTickets.value,
            Icons.autorenew, Colors.orange),
        _summaryCard('Resolved Today', controller.resolvedToday.value,
            Icons.check_circle, Colors.green),
        _summaryCard('Avg Response', controller.avgResponseTime.value,
            Icons.timer_outlined, Colors.purple, isText: true),
      ],
    );
  }

  Widget _summaryCard(String title, dynamic value, IconData icon, Color color,
      {bool isText = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.regular14Gre,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: AppTextStyles.bold20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= TICKETS =================

  Widget _ticketSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.divColor),
          ),
          child: TextField(
            onChanged: controller.searchTickets,
            decoration: const InputDecoration(
              hintText: 'Search by title, booking, user, or ticket #...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
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
        return Center(
          child: Text(
            'No tickets found',
            style: AppTextStyles.regular14Gre,
          ),
        );
      }

      return Column(
        children: controller.filteredSupportTickets.map((ticket) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ticketCard(ticket),
          );
        }).toList(),
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
        return _errorState();
      }

      if (controller.filteredSupportTickets.isEmpty) {
        return Center(
          child: Text(
            'No tickets found',
            style: AppTextStyles.regular14Gre,
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.filteredSupportTickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final GetAllSupportTickets ticket =
          controller.filteredSupportTickets[index];
          return _ticketCard(ticket);
        },
      );
    });
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: AppColor.fontColorGrey),
          const SizedBox(height: 8),
          Text(controller.loadError.value,
              textAlign: TextAlign.center, style: AppTextStyles.regular14Gre),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              controller.getAllSupportTicketsApi();
              controller.getSupportStatsApi();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) =>
      d == null ? '—' : DateFormat('dd MMM yyyy, hh:mm a').format(d.toLocal());

  bool _canChangeStatus(int status) =>
      status == SupportController.statusOpen ||
      status == SupportController.statusInProgress;

  Widget _ticketCard(GetAllSupportTickets ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(ticket.title, style: AppTextStyles.semiBold16),
              ),
              // Status can change only while the ticket is Open / In Progress
              if (_canChangeStatus(ticket.status))
                ElevatedButton.icon(
                  onPressed: () => _showCloseTicketDialog(ticket),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Update Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    foregroundColor: AppColor.buttonTextWhite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ticket #${ticket.id} · ${controller.categoryName(ticket.supportTypeId)}'
            '${ticket.bookingDetails.isNotEmpty && ticket.bookingDetails != 'NA' ? ' · Booking ${ticket.bookingDetails}' : ''}',
            style: AppTextStyles.regular14Gre,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statusChip(ticket.status),
              const SizedBox(width: 8),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 6),
              Text('User ${ticket.userId}', style: AppTextStyles.regular14Gre),
              const Spacer(),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _formatDate(ticket.createdOn),
                  style: AppTextStyles.regular14Gre,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CLOSE TICKET DIALOG =================

  void _showCloseTicketDialog(GetAllSupportTickets ticket) {
    final isMobile = SizeConfig.isMobile;
    controller.supportCommentsController.clear();
    final targets = [
      SupportController.statusInProgress,
      SupportController.statusResolved,
      SupportController.statusClosed,
    ].where((s) => s != ticket.status).toList();
    final RxInt target = SupportController.statusClosed.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: isMobile ? double.infinity : 500,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Ticket Status',
                    style: AppTextStyles.semiBold18,
                  ),
                  IconButton(
                    onPressed: () {
                      if (!controller.updateSupportStatusLoading.value) Get.back();
                    },
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ticket Details
              _detailRow('Ticket ID:', ticket.id.toString()),
              const SizedBox(height: 12),
              _detailRow('Title:', ticket.title),
              const SizedBox(height: 12),
              _detailRow('Support Type:', controller.categoryName(ticket.supportTypeId)),
              const SizedBox(height: 12),
              _detailRow('Status:', SupportController.statusLabel(ticket.status)),
              const SizedBox(height: 12),
              _detailRow('User ID:', ticket.userId.toString()),
              const SizedBox(height: 12),
              _detailRow('Created On:', _formatDate(ticket.createdOn)),
              const SizedBox(height: 12),
              _detailRow('Description:',
                  ticket.description.isEmpty ? 'N/A' : ticket.description),
              if (ticket.comments.isNotEmpty && ticket.comments != 'NA') ...[
                const SizedBox(height: 12),
                _detailRow('Comments:', ticket.comments),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              Text('New Status', style: AppTextStyles.medium16),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
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
              Text('Comments', style: AppTextStyles.medium16),
              const SizedBox(height: 8),
              TextField(
                controller: controller.supportCommentsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter comments (optional)...',
                  hintStyle: AppTextStyles.regular14Gre,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColor.fieldColorGrey,
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (!controller.updateSupportStatusLoading.value) Get.back();
                    },
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.medium16.copyWith(
                        color: AppColor.cPrimaryButtonColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => ElevatedButton(
                    onPressed: controller.updateSupportStatusLoading.value
                        ? null
                        : () async {
                      final ok = await controller.updateSupportStatus(
                          target.value, ticket.id);
                      if (ok && (Get.isDialogOpen ?? false)) Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cPrimaryButtonColor,
                      foregroundColor: AppColor.buttonTextWhite,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: controller.updateSupportStatusLoading.value
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.buttonTextWhite),
                      ),
                    )
                        : const Text('Update'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _detailRow(String label, String value) {
    final isMobile = SizeConfig.isMobile;
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.medium16),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.regular14Gre),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.medium16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.regular14Gre,
          ),
        ),
      ],
    );
  }

  // ================= RIGHT =================

  Widget _rightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _quickLinks(),
        const SizedBox(height: 24),
        _supportHours(),
      ],
    );
  }

  Widget _quickLinks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Links', style: AppTextStyles.semiBold18),
          const SizedBox(height: 16),
          _quickLinkItem(
              Icons.description, 'Knowledge Base', 'Browse help articles'),
          _quickLinkItem(Icons.email, 'Email Support', 'support@example.com'),
          _quickLinkItem(Icons.phone, 'Phone Support', '+1 (555) 123-4567'),
        ],
      ),
    );
  }

  Widget _supportHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support Hours', style: AppTextStyles.semiBold18),
          const SizedBox(height: 12),
          _hoursRow('Monday - Friday', '9:00 AM - 6:00 PM'),
          _hoursRow('Saturday', '10:00 AM - 4:00 PM'),
          _hoursRow('Sunday', 'Closed'),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColor.whiteColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.divColor),
    );
  }

  Widget _quickLinkItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColor.fieldColorGrey,
        child: Icon(icon, color: AppColor.cPrimaryButtonColor),
      ),
      title: Text(title, style: AppTextStyles.medium16),
      subtitle: Text(subtitle, style: AppTextStyles.regular14Gre),
    );
  }

  Widget _hoursRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: AppTextStyles.regular14Gre),
          Text(time, style: AppTextStyles.regular14black),
        ],
      ),
    );
  }

  Widget _statusChip(int status) {
    final color = SupportController.statusColor(status);
    return Chip(
      label: Text(SupportController.statusLabel(status)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
    );
  }
}