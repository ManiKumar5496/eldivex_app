import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/client_statement_model.dart';

class ClientStatementView extends GetView<AccountsController> {
  const ClientStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountsController());
    return Column(
      children: [
        _buildStatementSearchBar(),
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
    );
  }

  Widget _buildStatementSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: TextField(
                controller: controller.searchStatementController,
                onChanged: controller.searchStatements,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by client name, mobile, booking ID...',
                  hintStyle:
                      TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.fontColorGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.selectedStatement.value != null) {
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: OutlinedButton.icon(
                  onPressed: controller.closeStatementDetail,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to List'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildStatementsList() {
    return Obx(() {
      if (controller.isLoadingStatements.value) {
        return const ShimmerLoader.cardList();
      }
      final groups = controller.groupedFilteredStatements;
      if (groups.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No statements found', style: AppTextStyles.regular16Gre),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: groups.length,
        itemBuilder: (context, index) => _buildGroupedStatementCard(groups[index]),
      );
    });
  }

  Widget _buildGroupedStatementCard(GroupedClient group) {
    final hasMultiple = group.bookings.length > 1;
    return InkWell(
      onTap: () => controller.viewStatementForUser(group),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  group.clientName.isNotEmpty
                      ? group.clientName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: AppColor.cPrimaryButtonColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(group.clientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      if (hasMultiple) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.cPrimaryButtonColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${group.bookings.length} bookings',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColor.cPrimaryButtonColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (hasMultiple)
                    ...group.bookings.map((b) => Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Bkg #${b.bookingId} · ${b.patientName} · ${b.serviceName}',
                            style: TextStyle(
                                fontSize: 12, color: AppColor.fontColorGrey),
                          ),
                        ))
                  else
                    Text(
                      'Booking #${group.bookings.first.bookingId} | ${group.bookings.first.patientName} | ${group.bookings.first.serviceName}',
                      style: TextStyle(
                          fontSize: 13, color: AppColor.fontColorGrey),
                    ),
                ],
              ),
            ),
            _buildStatSummaryItem(
                'Billed',
                controller.formatCurrency(group.totalBilled),
                AppColor.cPrimaryHeadingColor),
            const SizedBox(width: 24),
            _buildStatSummaryItem(
                'Received',
                controller.formatCurrency(group.totalReceived),
                Colors.green),
            const SizedBox(width: 24),
            _buildStatSummaryItem(
                'Balance',
                controller.formatCurrency(group.closingBalance),
                group.closingBalance > 0 ? Colors.red : Colors.green),
            const SizedBox(width: 16),
            Icon(Icons.chevron_right, color: AppColor.fontColorGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColor.fontColorGrey)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Statement Detail View
  // ─────────────────────────────────────────────
  Widget _buildStatementDetail(ClientStatement statement) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Info Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statement of Account',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.cPrimaryHeadingColor)),
                      const SizedBox(height: 8),
                      Text(statement.clientName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                          statement.bookingId == 0
                              ? '${statement.clientMobile} | All Bookings (${statement.serviceName})'
                              : '${statement.clientMobile} | Booking #${statement.bookingId}',
                          style: TextStyle(
                              fontSize: 13, color: AppColor.fontColorGrey)),
                      if (statement.bookingId != 0)
                        Text(
                            'Patient: ${statement.patientName} | Service: ${statement.serviceName}',
                            style: TextStyle(
                                fontSize: 13, color: AppColor.fontColorGrey)),
                    ],
                  ),
                ),
                _buildSummaryBox(
                    'Total Billed', statement.totalBilled, Colors.blue),
                const SizedBox(width: 12),
                _buildSummaryBox(
                    'Total Received', statement.totalReceived, Colors.green),
                const SizedBox(width: 12),
                _buildSummaryBox(
                    'Write-Off', statement.totalWriteOff, Colors.orange),
                const SizedBox(width: 12),
                _buildSummaryBox(
                    'Closing Balance', statement.closingBalance, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColor.cPrimaryHeadingColor,
                ),
                dataTextStyle: const TextStyle(fontSize: 13),
                columnSpacing: 24,
                horizontalMargin: 16,
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
                            fontSize: 12,
                            color: AppColor.cPrimaryButtonColor,
                            fontWeight: FontWeight.w500),
                      )),
                    DataCell(Text(controller.formatDate(txn.date))),
                    DataCell(Text(txn.description,
                        style: const TextStyle(fontSize: 13))),
                    DataCell(Text(txn.referenceNumber ?? '-',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColor.cPrimaryButtonColor))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPayment
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(txn.type,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isPayment ? Colors.green : Colors.blue)),
                    )),
                    DataCell(Text(
                      txn.debit > 0
                          ? controller.formatCurrency(txn.debit)
                          : '-',
                      style: const TextStyle(color: Colors.red),
                    )),
                    DataCell(Text(
                      txn.credit > 0
                          ? controller.formatCurrency(txn.credit)
                          : '-',
                      style: const TextStyle(color: Colors.green),
                    )),
                    DataCell(Text(
                      controller.formatCurrency(txn.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: txn.balance > 0 ? Colors.red : Colors.green,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(controller.formatCurrency(amount),
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
