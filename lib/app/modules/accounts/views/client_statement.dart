import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/client_statement_model.dart';
import 'accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ClientStatementView extends GetView<AccountsController> {
  const ClientStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) Get.put(AccountsController());
    final embedded = accountsIsEmbeddedInTabs(context);
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: accountsPagePadding(context, bottom: false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!embedded) ...[
              const AppPageHeader(
                title: 'Client statements',
                subtitle: 'Billed, received and balance for every client',
              ),
              SizedBox(height: SizeConfig.isMobile ? 16 : 20),
            ],
            _buildStatementSearchBar(context),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final selected = controller.selectedStatement.value;
                if (selected != null) {
                  return _buildStatementDetail(selected);
                }
                return _buildStatementsList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppSearchField(
            controller: controller.searchStatementController,
            onChanged: controller.searchStatements,
            hint: 'Search by client name, mobile, booking ID…',
          ),
        ),
        Obx(() {
          if (controller.selectedStatement.value != null) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizeConfig.isMobile
                  ? accountsToolbarIconButton(
                      onPressed: controller.closeStatementDetail,
                      icon: LucideIcons.arrowLeft,
                      tooltip: 'Back to List',
                    )
                  : OutlinedButton.icon(
                      onPressed: controller.closeStatementDetail,
                      icon: const Icon(LucideIcons.arrowLeft, size: 18),
                      label: const Text('Back to list'),
                    ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildStatementsList() {
    return Obx(() {
      if (controller.isLoadingStatements.value) {
        return const ShimmerLoader.cardList();
      }
      final groups = controller.groupedFilteredStatements;
      if (groups.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.wallet,
          title: 'No statements found',
          message: 'Try a different client name, mobile number or booking ID.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: groups.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildGroupedStatementCard(groups[index]),
        ),
      );
    });
  }

  Widget _buildGroupedStatementCard(GroupedClient group) {
    final hasMultiple = group.bookings.length > 1;

    Widget avatar = AppAvatar(name: group.clientName, size: 40);

    Widget clientInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(group.clientName,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: AppColor.textPrimary),
                overflow: TextOverflow.ellipsis),
            if (hasMultiple)
              AppStatusBadge(
                label: '${group.bookings.length} bookings',
                tone: AppTone.primary,
                showDot: false,
                dense: true,
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (hasMultiple)
          ...group.bookings.map((b) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Bkg #${b.bookingId} · ${b.patientName} · ${b.serviceName}',
                  style:
                      TextStyle(fontSize: 13, color: AppColor.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
        else
          Text(
            'Booking #${group.bookings.first.bookingId} | ${group.bookings.first.patientName}',
            style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    Widget summaryRow = Row(
      children: [
        Expanded(
          child: _buildStatSummaryItem(
              'Billed',
              controller.formatCurrency(group.totalBilled),
              AppColor.textPrimary,
              alignEnd: false),
        ),
        Expanded(
          child: _buildStatSummaryItem(
              'Received',
              controller.formatCurrency(group.totalReceived),
              AppColor.success,
              alignEnd: false),
        ),
        Expanded(
          child: _buildStatSummaryItem(
              'Balance',
              controller.formatCurrency(group.closingBalance),
              group.closingBalance > 0 ? AppColor.danger : AppColor.success,
              alignEnd: false),
        ),
      ],
    );

    return AppCard(
      onTap: () => controller.viewStatementForUser(group),
      padding: EdgeInsets.all(SizeConfig.isMobile ? 16 : 18),
      // Stack the amounts under the client on narrow cards (phones, and
      // tablets where the sidebar leaves little room).
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 640
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(child: clientInfo),
                Icon(LucideIcons.chevronRight,
                    size: 20, color: AppColor.textTertiary),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: summaryRow,
            ),
          ],
        )
            : Row(
          children: [
            avatar,
            const SizedBox(width: 14),
            Expanded(flex: 3, child: clientInfo),
            const SizedBox(width: 16),
            SizedBox(
              width: 128,
              child: _buildStatSummaryItem(
                  'Billed',
                  controller.formatCurrency(group.totalBilled),
                  AppColor.textPrimary),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 128,
              child: _buildStatSummaryItem(
                  'Received',
                  controller.formatCurrency(group.totalReceived),
                  AppColor.success),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 128,
              child: _buildStatSummaryItem(
                  'Balance',
                  controller.formatCurrency(group.closingBalance),
                  group.closingBalance > 0
                      ? AppColor.danger
                      : AppColor.success),
            ),
            const SizedBox(width: 12),
            Icon(LucideIcons.chevronRight,
                size: 20, color: AppColor.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummaryItem(String label, String value, Color color,
      {bool alignEnd = true}) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColor.textTertiary)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment:
              alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(value,
              maxLines: 1, style: accountsAmountStyle(color: color, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStatementDetail(ClientStatement statement) {
    final summaryBoxes = [
      _buildSummaryBox('Total billed', statement.totalBilled, AppTone.info,
          LucideIcons.receiptText),
      _buildSummaryBox('Total received', statement.totalReceived,
          AppTone.success, LucideIcons.banknote),
      _buildSummaryBox('Write-off', statement.totalWriteOff, AppTone.warning,
          LucideIcons.banknoteX),
      _buildSummaryBox('Closing balance', statement.closingBalance,
          AppTone.danger, LucideIcons.wallet),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!SizeConfig.isMobile) ...[
                  AppAvatar(name: statement.clientName, size: 44),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statement of account',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textTertiary)),
                      const SizedBox(height: 4),
                      Text(statement.clientName,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: AppColor.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                          statement.bookingId == 0
                              ? '${statement.clientMobile} | All Bookings (${statement.serviceName})'
                              : '${statement.clientMobile} | Booking #${statement.bookingId}',
                          style: TextStyle(
                              fontSize: 13, color: AppColor.textTertiary)),
                      if (statement.bookingId != 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                              'Patient: ${statement.patientName} | Service: ${statement.serviceName}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColor.textTertiary)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppResponsiveGrid(
            minItemWidth: SizeConfig.isMobile ? 150 : 190,
            maxColumns: 4,
            spacing: SizeConfig.isMobile ? 12 : 16,
            children: summaryBoxes,
          ),
          const SizedBox(height: 16),

          // Transactions Table
          AppCard(
            padding: EdgeInsets.zero,
            title: 'Transactions',
            child: horizontalTable(
              DataTable(
                columns: [
                  if (statement.bookingId == 0)
                    const DataColumn(label: Text('Booking')),
                  const DataColumn(label: Text('Date')),
                  const DataColumn(label: Text('Description')),
                  const DataColumn(label: Text('Reference')),
                  const DataColumn(label: Text('Type')),
                  const DataColumn(label: Text('Debit'), numeric: true),
                  const DataColumn(label: Text('Credit'), numeric: true),
                  const DataColumn(label: Text('Balance'), numeric: true),
                ],
                rows: statement.transactions.map((txn) {
                  final isPayment = txn.type == 'Payment';
                  return DataRow(cells: [
                    if (statement.bookingId == 0)
                      DataCell(Text(
                        'Bkg #${txn.bookingId}',
                        style: TextStyle(
                            color: AppColor.cPrimaryButtonColor,
                            fontWeight: FontWeight.w600),
                      )),
                    DataCell(Text(controller.formatDate(txn.date),
                        style: TextStyle(
                            color: AppColor.textSecondary,
                            fontFeatures: accountsTabularFigures))),
                    DataCell(Text(txn.description)),
                    DataCell(Text(txn.referenceNumber ?? '-',
                        style:
                            TextStyle(color: AppColor.cPrimaryButtonColor))),
                    DataCell(AppStatusBadge(
                      label: txn.type,
                      tone: isPayment ? AppTone.success : AppTone.info,
                      dense: true,
                    )),
                    DataCell(Text(
                      txn.debit > 0
                          ? controller.formatCurrency(txn.debit)
                          : '-',
                      style: accountsAmountStyle(
                          color: txn.debit > 0
                              ? AppColor.danger
                              : AppColor.textTertiary,
                          fontWeight: FontWeight.w400),
                    )),
                    DataCell(Text(
                      txn.credit > 0
                          ? controller.formatCurrency(txn.credit)
                          : '-',
                      style: accountsAmountStyle(
                          color: txn.credit > 0
                              ? AppColor.success
                              : AppColor.textTertiary,
                          fontWeight: FontWeight.w400),
                    )),
                    DataCell(Text(
                      controller.formatCurrency(txn.balance),
                      style: accountsAmountStyle(
                        color: txn.balance > 0
                            ? AppColor.danger
                            : AppColor.success,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(
      String label, double amount, AppTone tone, IconData icon) {
    return AppStatCard(
      label: label,
      value: controller.formatCurrency(amount),
      icon: icon,
      tone: tone,
    );
  }
}
