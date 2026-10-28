import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import 'accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class WriteOffView extends GetView<AccountsController> {
  const WriteOffView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) Get.put(AccountsController());
    final embedded = accountsIsEmbeddedInTabs(context);
    final isMobile = SizeConfig.isMobile;
    // Refetch whenever the page is opened: newer pages (Credit Note Mgmt,
    // Write-offs) approve the same records, so a cached list goes stale.
    return AccountsOnOpen(
      onOpen: () => Get.find<AccountsController>().fetchWriteOffs(),
      child: Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        floatingActionButton: isMobile
            ? FloatingActionButton.extended(
                onPressed: () => _showWriteOffFormSheet(context),
                icon: const Icon(LucideIcons.plus),
                label: const Text('New write-off',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              )
            : null,
        body: Padding(
          padding: accountsPagePadding(context, bottom: !isMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!embedded) ...[
                const AppPageHeader(
                  title: 'Write-offs',
                  subtitle: 'Write off unrecoverable balances with approval',
                ),
                SizedBox(height: isMobile ? 16 : 20),
              ],
              if (isMobile) ...[
                _buildWriteOffSearchBar(),
                const SizedBox(height: 12),
                Expanded(child: _buildMobileLayout(context)),
              ] else
                Expanded(child: _buildDesktopLayout()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildMobileWriteOffList();
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: AppCard(
            expandChild: true,
            padding: EdgeInsets.zero,
            title: 'Write-offs',
            actions: [_buildWriteOffSearchBar(width: 280)],
            child: _buildWriteOffList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildWriteOffForm()),
      ],
    );
  }

  void _showWriteOffFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.whiteColor,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColor.divColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  const AppIconTile(
                      icon: LucideIcons.banknoteX,
                      tone: AppTone.warning,
                      size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Create write-off',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: AppColor.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                            'Select a client from Active Clients tab or choose below',
                            style: TextStyle(
                                fontSize: 13, color: AppColor.textTertiary)),
                      ],
                    ),
                  ),
                  IconButton(
                      tooltip: 'Close',
                      icon: Icon(LucideIcons.x,
                          size: 20, color: AppColor.textTertiary),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            Divider(height: 1, color: AppColor.borderSubtle),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: _buildWriteOffFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteOffSearchBar({double? width}) {
    return AppSearchField(
      controller: controller.searchWriteOffController,
      onChanged: controller.searchWriteOffs,
      hint: 'Search by client name, mobile, booking ID…',
      width: width,
    );
  }

  Widget _buildMobileWriteOffList() {
    return Obx(() {
      if (controller.isLoadingWriteOffs.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredWriteOffs.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.banknoteX,
          title: 'No write-offs found',
          message: 'Write-offs you create will appear here.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 88), // FAB clearance
        itemCount: controller.filteredWriteOffs.length,
        itemBuilder: (_, i) =>
            _buildMobileWriteOffCard(controller.filteredWriteOffs[i]),
      );
    });
  }

  Widget _buildMobileWriteOffCard(dynamic wo) {
    final isPending = wo.status == 'Pending';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Booking # + Status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${wo.bookingId}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                ),
                accountsStatusChip(wo.status),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColor.borderSubtle),
            ),

            // Row 2: Client / Service
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: accountsCellStack(wo.clientName,
                      subtitle: wo.patientName),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(wo.serviceName,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 13, color: AppColor.textTertiary),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Amount + Date
            Row(
              children: [
                Text(
                  controller.formatCurrency(wo.writeOffAmount),
                  style: accountsAmountStyle(
                      color: AppColor.danger,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  controller.formatDate(wo.writeOffDate),
                  style:
                      TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 4: Reason
            Text(
              wo.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
            ),

            // Bottom: Action buttons for Pending
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.rejectWriteOff(wo.id),
                      style: AppButtonStyles.dangerOutlined,
                      icon: const Icon(LucideIcons.x, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.approveWriteOff(wo.id),
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWriteOffList() {
    return Obx(() {
      if (controller.isLoadingWriteOffs.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredWriteOffs.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.banknoteX,
          title: 'No write-offs found',
          message: 'Use the form on the right to write off a balance.',
        );
      }
      return SingleChildScrollView(
        child: horizontalTable(
          DataTable(
            columns: const [
              DataColumn(label: Text('Booking ID')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Service')),
              DataColumn(label: Text('Amount'), numeric: true),
              DataColumn(label: Text('Reason')),
              DataColumn(label: Text('Approver')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.filteredWriteOffs.map((wo) {
              final isPending = wo.status == 'Pending';
              return DataRow(cells: [
                DataCell(Text('#${wo.bookingId}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColor.cPrimaryButtonColor))),
                DataCell(accountsCellStack(wo.clientName,
                    subtitle: wo.patientName)),
                DataCell(Text(wo.serviceName)),
                DataCell(Text(
                  controller.formatCurrency(wo.writeOffAmount),
                  style: accountsAmountStyle(color: AppColor.danger),
                )),
                DataCell(SizedBox(
                  width: 160,
                  child: Tooltip(
                    message: wo.reason,
                    child: Text(wo.reason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: AppColor.textSecondary)),
                  ),
                )),
                DataCell(Text(wo.approvedBy)),
                DataCell(Text(controller.formatDate(wo.writeOffDate),
                    style: TextStyle(color: AppColor.textSecondary))),
                DataCell(accountsStatusChip(wo.status)),
                DataCell(isPending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          accountsIconAction(
                            icon: LucideIcons.check,
                            tooltip: 'Approve Write-Off',
                            tone: AppTone.success,
                            onPressed: () =>
                                controller.approveWriteOff(wo.id),
                          ),
                          const SizedBox(width: 8),
                          accountsIconAction(
                            icon: LucideIcons.x,
                            tooltip: 'Reject Write-Off',
                            tone: AppTone.danger,
                            onPressed: () =>
                                controller.rejectWriteOff(wo.id),
                          ),
                        ],
                      )
                    : Icon(LucideIcons.circleCheck,
                        size: 18, color: AppColor.lightGrey)),
              ]);
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildWriteOffForm() {
    return SingleChildScrollView(
      child: AppCard(
        title: 'Create write-off',
        subtitle: 'Select a client from Active Clients tab or choose below',
        icon: LucideIcons.banknoteX,
        iconTone: AppTone.warning,
        child: _buildWriteOffFormContent(),
      ),
    );
  }

  Widget _buildWriteOffFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Client Info / Dropdown
        Obx(() {
          final client = controller.selectedClientForWriteOff.value;
          if (client != null) {
            return Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColor.borderSubtle),
              ),
              child: Row(
                children: [
                  AppAvatar(name: client.clientName, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.clientName,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColor.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                            'Booking #${client.bookingId} | ${client.patientName} | ${client.serviceName}',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: AppColor.textTertiary)),
                        const SizedBox(height: 2),
                        Text(
                            'Outstanding: ${controller.formatCurrency(client.outstandingAmount)}',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: AppColor.danger,
                                fontWeight: FontWeight.w600,
                                fontFeatures: accountsTabularFigures)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Clear selection',
                    icon: Icon(LucideIcons.x,
                        size: 18, color: AppColor.textTertiary),
                    onPressed: () =>
                        controller.selectedClientForWriteOff.value = null,
                  ),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              accountsFieldLabel('Select Client'),
              accountsDropdownShell(
                child: DropdownButton<int>(
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  isExpanded: true,
                  hint: Text('Choose active client',
                      style: TextStyle(
                          color: AppColor.textTertiary, fontSize: 14)),
                  items: controller.activeClients.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.clientName} - #${c.bookingId}',
                          style: TextStyle(
                              fontSize: 14, color: AppColor.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (id) {
                    final client = controller.activeClients
                        .firstWhereOrNull((c) => c.id == id);
                    if (client != null) {
                      controller.selectClientForWriteOff(client);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),

        CommonTextField(
          label: 'Write-Off Amount',
          hint: 'Enter amount',
          controller: controller.writeOffAmountController,
          keyboardType: TextInputType.number,
          isMandatory: true,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Reason',
          hint: 'Enter reason for write-off',
          controller: controller.writeOffReasonController,
          maxLines: 2,
          isMandatory: true,
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            accountsFieldLabel('Approved By', required: true),
            Obx(() => accountsDropdownShell(
                  child: DropdownButton<String>(
                    icon: const Icon(LucideIcons.chevronDown, size: 18),
                    isExpanded: true,
                    value: controller.writeOffApprover.value.isEmpty
                        ? null
                        : controller.writeOffApprover.value,
                    hint: Text('Select approver',
                        style: TextStyle(
                            color: AppColor.textTertiary, fontSize: 14)),
                    items: controller.approverList
                        .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(a,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.textPrimary))))
                        .toList(),
                    onChanged: (v) =>
                        controller.writeOffApprover.value = v ?? '',
                  ),
                )),
          ],
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Remarks',
          hint: 'Additional remarks (optional)',
          controller: controller.writeOffRemarksController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: controller.createWriteOff,
            child: const Text('Submit write-off'),
          ),
        ),
      ],
    );
  }
}
