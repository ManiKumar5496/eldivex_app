import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/client_statement_model.dart';

class ClientStatementView extends GetView<AccountsController> {
  const ClientStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(AccountsController());
    return Column(
      children: [
        _buildStatementSearchBar(context),
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

  Widget _buildStatementSearchBar(BuildContext context) {
    return Padding(
      padding: SizeConfig.pagePadding,
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
                style: TextStyle(fontSize: SizeConfig.fontBody),
                decoration: InputDecoration(
                  hintText: 'Search by client name, mobile, booking ID...',
                  hintStyle: TextStyle(
                      color: AppColor.fontColorGrey, fontSize: SizeConfig.fontBody),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.fontColorGrey, size: SizeConfig.iconMD),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.selectedStatement.value != null) {
              return Padding(
                padding: EdgeInsets.only(left: SizeConfig.spacingSM),
                child: SizeConfig.isMobile
                    ? IconButton(
                        onPressed: controller.closeStatementDetail,
                        icon: Icon(Icons.arrow_back,
                            size: SizeConfig.iconMD,
                            color: AppColor.cPrimaryButtonColor),
                        tooltip: 'Back to List',
                      )
                    : OutlinedButton.icon(
                        onPressed: controller.closeStatementDetail,
                        icon: Icon(Icons.arrow_back, size: SizeConfig.iconSM),
                        label: const Text('Back to List'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spacingLG,
                              vertical: SizeConfig.spacingSM),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.radiusSM)),
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
                  size: 64, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No statements found', style: AppTextStyles.regular16Gre),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.pagePadding.left),
        itemCount: groups.length,
        itemBuilder: (context, index) =>
            _buildGroupedStatementCard(groups[index]),
      );
    });
  }

  Widget _buildGroupedStatementCard(GroupedClient group) {
    final hasMultiple = group.bookings.length > 1;

    Widget avatar = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          group.clientName.isNotEmpty ? group.clientName[0].toUpperCase() : '?',
          style: TextStyle(
              color: AppColor.cPrimaryButtonColor,
              fontSize: SizeConfig.fontH3,
              fontWeight: FontWeight.w600),
        ),
      ),
    );

    Widget clientInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(group.clientName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: SizeConfig.fontBody),
                  overflow: TextOverflow.ellipsis),
            ),
            if (hasMultiple) ...[
              SizedBox(width: SizeConfig.spacingXS),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${group.bookings.length} bookings',
                  style: TextStyle(
                      fontSize: SizeConfig.fontCaption,
                      color: AppColor.cPrimaryButtonColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: SizeConfig.spacingXS),
        if (hasMultiple)
          ...group.bookings.map((b) => Padding(
                padding: EdgeInsets.only(top: SizeConfig.spacingXS / 2),
                child: Text(
                  'Bkg #${b.bookingId} · ${b.patientName} · ${b.serviceName}',
                  style: TextStyle(
                      fontSize: SizeConfig.fontBodySmall,
                      color: AppColor.fontColorGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
        else
          Text(
            'Booking #${group.bookings.first.bookingId} | ${group.bookings.first.patientName}',
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall, color: AppColor.fontColorGrey),
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
              AppColor.cPrimaryHeadingColor),
        ),
        Expanded(
          child: _buildStatSummaryItem(
              'Received',
              controller.formatCurrency(group.totalReceived),
              Colors.green),
        ),
        Expanded(
          child: _buildStatSummaryItem(
              'Balance',
              controller.formatCurrency(group.closingBalance),
              group.closingBalance > 0 ? Colors.red : Colors.green),
        ),
      ],
    );

    return InkWell(
      onTap: () => controller.viewStatementForUser(group),
      borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
        padding: SizeConfig.cardPadding,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          border: Border.all(color: AppColor.divColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SizeConfig.adaptiveLayout(
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  avatar,
                  SizedBox(width: SizeConfig.spacingSM),
                  Expanded(child: clientInfo),
                  Icon(Icons.chevron_right, color: AppColor.fontColorGrey),
                ],
              ),
              SizedBox(height: SizeConfig.spacingSM),
              Container(
                padding: EdgeInsets.all(SizeConfig.spacingSM),
                decoration: BoxDecoration(
                  color: AppColor.fieldColorGrey,
                  borderRadius:
                      BorderRadius.circular(SizeConfig.radiusSM),
                ),
                child: summaryRow,
              ),
            ],
          ),
          tablet: Row(
            children: [
              avatar,
              SizedBox(width: SizeConfig.spacingMD),
              Expanded(flex: 3, child: clientInfo),
              SizedBox(width: SizeConfig.spacingMD),
              _buildStatSummaryItem(
                  'Billed',
                  controller.formatCurrency(group.totalBilled),
                  AppColor.cPrimaryHeadingColor),
              SizedBox(width: SizeConfig.spacingLG),
              _buildStatSummaryItem(
                  'Received',
                  controller.formatCurrency(group.totalReceived),
                  Colors.green),
              SizedBox(width: SizeConfig.spacingLG),
              _buildStatSummaryItem(
                  'Balance',
                  controller.formatCurrency(group.closingBalance),
                  group.closingBalance > 0 ? Colors.red : Colors.green),
              SizedBox(width: SizeConfig.spacingMD),
              Icon(Icons.chevron_right, color: AppColor.fontColorGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey)),
        SizedBox(height: SizeConfig.spacingXS),
        Text(value,
            style: TextStyle(
                fontSize: SizeConfig.fontBody,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }

  Widget _buildStatementDetail(ClientStatement statement) {
    final summaryBoxes = [
      _buildSummaryBox('Total Billed', statement.totalBilled, Colors.blue),
      _buildSummaryBox('Total Received', statement.totalReceived, Colors.green),
      _buildSummaryBox('Write-Off', statement.totalWriteOff, Colors.orange),
      _buildSummaryBox('Closing Balance', statement.closingBalance, Colors.red),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.pagePadding.left),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: SizeConfig.cardPadding,
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
              border: Border.all(color: AppColor.divColor),
            ),
            child: SizeConfig.adaptiveLayout(
              mobile: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statement of Account',
                      style: TextStyle(
                          fontSize: SizeConfig.fontH2,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cPrimaryHeadingColor)),
                  SizedBox(height: SizeConfig.spacingSM),
                  Text(statement.clientName,
                      style: TextStyle(
                          fontSize: SizeConfig.fontBody,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: SizeConfig.spacingXS),
                  Text(
                      statement.bookingId == 0
                          ? '${statement.clientMobile} | All Bookings'
                          : '${statement.clientMobile} | Booking #${statement.bookingId}',
                      style: TextStyle(
                          fontSize: SizeConfig.fontBodySmall,
                          color: AppColor.fontColorGrey)),
                  SizedBox(height: SizeConfig.spacingMD),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: SizeConfig.spacingSM,
                    crossAxisSpacing: SizeConfig.spacingSM,
                    childAspectRatio: 2.2,
                    children: summaryBoxes,
                  ),
                ],
              ),
              tablet: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statement of Account',
                            style: TextStyle(
                                fontSize: SizeConfig.fontH2,
                                fontWeight: FontWeight.w700,
                                color: AppColor.cPrimaryHeadingColor)),
                        SizedBox(height: SizeConfig.spacingXS),
                        Text(statement.clientName,
                            style: TextStyle(
                                fontSize: SizeConfig.fontBodyLarge,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: SizeConfig.spacingXS),
                        Text(
                            statement.bookingId == 0
                                ? '${statement.clientMobile} | All Bookings (${statement.serviceName})'
                                : '${statement.clientMobile} | Booking #${statement.bookingId}',
                            style: TextStyle(
                                fontSize: SizeConfig.fontBodySmall,
                                color: AppColor.fontColorGrey)),
                        if (statement.bookingId != 0)
                          Text(
                              'Patient: ${statement.patientName} | Service: ${statement.serviceName}',
                              style: TextStyle(
                                  fontSize: SizeConfig.fontBodySmall,
                                  color: AppColor.fontColorGrey)),
                      ],
                    ),
                  ),
                  ...summaryBoxes.map((box) => Padding(
                        padding: EdgeInsets.only(left: SizeConfig.spacingSM),
                        child: box,
                      )),
                ],
              ),
            ),
          ),
          SizedBox(height: SizeConfig.spacingMD),

          // Transactions Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
                border: Border.all(color: AppColor.divColor),
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColor.fieldColorGrey),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.fontBodySmall,
                  color: AppColor.cPrimaryHeadingColor,
                ),
                dataTextStyle: TextStyle(fontSize: SizeConfig.fontBodySmall),
                columnSpacing: SizeConfig.spacingLG,
                horizontalMargin: SizeConfig.spacingMD,
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
                            fontSize: SizeConfig.fontBodySmall,
                            color: AppColor.cPrimaryButtonColor,
                            fontWeight: FontWeight.w500),
                      )),
                    DataCell(Text(controller.formatDate(txn.date),
                        style: TextStyle(fontSize: SizeConfig.fontBodySmall))),
                    DataCell(Text(txn.description,
                        style: TextStyle(fontSize: SizeConfig.fontBodySmall))),
                    DataCell(Text(txn.referenceNumber ?? '-',
                        style: TextStyle(
                            fontSize: SizeConfig.fontBodySmall,
                            color: AppColor.cPrimaryButtonColor))),
                    DataCell(Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spacingSM, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPayment
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radiusSM),
                      ),
                      child: Text(txn.type,
                          style: TextStyle(
                              fontSize: SizeConfig.fontCaption,
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
          SizedBox(height: SizeConfig.spacingLG),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, double amount, Color color) {
    return Container(
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.fontCaption,
                  color: AppColor.fontColorGrey)),
          SizedBox(height: SizeConfig.spacingXS),
          Text(controller.formatCurrency(amount),
              style: TextStyle(
                  fontSize: SizeConfig.fontH3,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}
