import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';

class WriteOffView extends GetView<AccountsController> {
  const WriteOffView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(AccountsController());
    return Column(
      children: [
        _buildWriteOffSearchBar(),
        Expanded(
          child: SizeConfig.adaptiveLayout(
            mobile: _buildMobileLayout(context),
            tablet: _buildDesktopLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWriteOffFormSheet(context),
        backgroundColor: Colors.orange.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Write-Off',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _buildMobileWriteOffList(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildWriteOffList()),
        Expanded(flex: 2, child: _buildWriteOffForm()),
      ],
    );
  }

  void _showWriteOffFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(SizeConfig.pagePadding.left,
                  SizeConfig.spacingMD, SizeConfig.spacingXS, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.money_off,
                        color: Colors.orange.shade700, size: SizeConfig.iconMD),
                    SizedBox(width: SizeConfig.spacingXS),
                    Text('Create Write-Off',
                        style: TextStyle(
                            fontSize: SizeConfig.fontH2,
                            fontWeight: FontWeight.w600,
                            color: AppColor.cPrimaryHeadingColor)),
                  ]),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                    SizeConfig.pagePadding.left,
                    SizeConfig.spacingSM,
                    SizeConfig.pagePadding.right,
                    SizeConfig.spacingLG),
                child: _buildWriteOffFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteOffSearchBar() {
    return Padding(
      padding: SizeConfig.pagePadding,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.textFieldBorderColor),
        ),
        child: TextField(
          controller: controller.searchWriteOffController,
          onChanged: controller.searchWriteOffs,
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
    );
  }

  Widget _buildMobileWriteOffList() {
    return Obx(() {
      if (controller.isLoadingWriteOffs.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredWriteOffs.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.money_off_outlined,
                  size: 64, color: Colors.grey.shade300),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No write-offs found', style: AppTextStyles.regular16Gre),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
            SizeConfig.pagePadding.left,
            SizeConfig.spacingXS,
            SizeConfig.pagePadding.right,
            80), // 80 for FAB clearance
        itemCount: controller.filteredWriteOffs.length,
        itemBuilder: (_, i) =>
            _buildMobileWriteOffCard(controller.filteredWriteOffs[i]),
      );
    });
  }

  Widget _buildMobileWriteOffCard(dynamic wo) {
    final statusColor = controller.getStatusColor(wo.status);
    final isPending = wo.status == 'Pending';
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  fontSize: SizeConfig.fontBody,
                  color: AppColor.cPrimaryButtonColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM,
                    vertical: SizeConfig.spacingXS),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(wo.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: SizeConfig.fontCaption,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          Divider(height: SizeConfig.spacingLG, color: Colors.grey.shade100),

          // Row 2: Client / Service
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wo.clientName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: SizeConfig.fontBody),
                        overflow: TextOverflow.ellipsis),
                    Text(wo.patientName,
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                  ],
                ),
              ),
              SizedBox(width: SizeConfig.spacingSM),
              Text(wo.serviceName,
                  style: TextStyle(
                      fontSize: SizeConfig.fontBodySmall,
                      color: AppColor.fontColorGrey),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
          SizedBox(height: SizeConfig.spacingSM),

          // Row 3: Amount + Date
          Row(
            children: [
              Text(
                controller.formatCurrency(wo.writeOffAmount),
                style: TextStyle(
                  fontSize: SizeConfig.fontH3,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              Text(
                controller.formatDate(wo.writeOffDate),
                style: TextStyle(
                    fontSize: SizeConfig.fontCaption,
                    color: AppColor.fontColorGrey),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.spacingXS),

          // Row 4: Reason
          Text(
            wo.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.fontColorGrey),
          ),

          // Bottom: Action buttons for Pending
          if (isPending) ...[
            Divider(height: SizeConfig.spacingLG, color: Colors.grey.shade100),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.rejectWriteOff(wo.id),
                      icon: Icon(Icons.close,
                          size: SizeConfig.iconSM, color: Colors.red),
                      label: Text('Reject',
                          style: TextStyle(
                              color: Colors.red, fontSize: SizeConfig.fontBody)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radiusSM)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.spacingSM),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.approveWriteOff(wo.id),
                      icon: Icon(Icons.check,
                          size: SizeConfig.iconSM, color: Colors.white),
                      label: Text('Approve',
                          style: TextStyle(
                              color: Colors.white, fontSize: SizeConfig.fontBody)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radiusSM)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWriteOffList() {
    return Obx(() {
      if (controller.isLoadingWriteOffs.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredWriteOffs.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.money_off_outlined,
                  size: 64, color: Colors.grey.shade300),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No write-offs found', style: AppTextStyles.regular16Gre),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        padding: EdgeInsets.only(
            left: SizeConfig.pagePadding.left,
            bottom: SizeConfig.spacingLG),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.cPrimaryHeadingColor,
              ),
              dataTextStyle: TextStyle(fontSize: SizeConfig.fontBodySmall),
              columnSpacing: SizeConfig.spacingMD,
              horizontalMargin: SizeConfig.spacingSM,
              columns: const [
                DataColumn(label: Text('Booking ID')),
                DataColumn(label: Text('Client')),
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Reason')),
                DataColumn(label: Text('Approver')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.filteredWriteOffs.map((wo) {
                final statusColor = controller.getStatusColor(wo.status);
                final isPending = wo.status == 'Pending';
                return DataRow(cells: [
                  DataCell(Text('#${wo.bookingId}',
                      style: AppTextStyles.regular14black)),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(wo.clientName,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: SizeConfig.fontBodySmall)),
                      Text(wo.patientName,
                          style: TextStyle(
                              fontSize: SizeConfig.fontCaption,
                              color: AppColor.fontColorGrey)),
                    ],
                  )),
                  DataCell(Text(wo.serviceName,
                      style:
                          TextStyle(fontSize: SizeConfig.fontBodySmall))),
                  DataCell(Text(
                    controller.formatCurrency(wo.writeOffAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.red),
                  )),
                  DataCell(SizedBox(
                    width: 150,
                    child: Tooltip(
                      message: wo.reason,
                      child: Text(wo.reason,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: SizeConfig.fontBodySmall)),
                    ),
                  )),
                  DataCell(Text(wo.approvedBy,
                      style:
                          TextStyle(fontSize: SizeConfig.fontBodySmall))),
                  DataCell(Text(controller.formatDate(wo.writeOffDate),
                      style:
                          TextStyle(fontSize: SizeConfig.fontBodySmall))),
                  DataCell(Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.spacingSM, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(wo.status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: SizeConfig.fontCaption,
                            fontWeight: FontWeight.w500)),
                  )),
                  DataCell(isPending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Approve Write-Off',
                              child: InkWell(
                                onTap: () =>
                                    controller.approveWriteOff(wo.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding:
                                      EdgeInsets.all(SizeConfig.spacingSM),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.check,
                                      size: SizeConfig.iconSM,
                                      color: Colors.green),
                                ),
                              ),
                            ),
                            SizedBox(width: SizeConfig.spacingXS),
                            Tooltip(
                              message: 'Reject Write-Off',
                              child: InkWell(
                                onTap: () =>
                                    controller.rejectWriteOff(wo.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding:
                                      EdgeInsets.all(SizeConfig.spacingSM),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.close,
                                      size: SizeConfig.iconSM,
                                      color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Icon(Icons.check_circle_outline,
                          size: SizeConfig.iconSM, color: Colors.grey.shade400)),
                ]);
              }).toList(),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWriteOffForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(SizeConfig.spacingSM, 0,
          SizeConfig.pagePadding.right, SizeConfig.spacingLG),
      child: Container(
        padding: SizeConfig.cardPadding,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: _buildWriteOffFormContent(),
      ),
    );
  }

  Widget _buildWriteOffFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.money_off,
                color: Colors.orange.shade700, size: SizeConfig.iconMD),
            SizedBox(width: SizeConfig.spacingXS),
            Text('Create Write-Off',
                style: TextStyle(
                    fontSize: SizeConfig.fontH3,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryHeadingColor)),
          ],
        ),
        SizedBox(height: SizeConfig.spacingXS),
        Text('Select a client from Active Clients tab or choose below',
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.fontColorGrey)),
        Divider(height: SizeConfig.spacingLG),

        // Selected Client Info / Dropdown
        Obx(() {
          final client = controller.selectedClientForWriteOff.value;
          if (client != null) {
            return Container(
              padding: SizeConfig.cardPadding,
              margin: EdgeInsets.only(bottom: SizeConfig.spacingMD),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.clientName,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: SizeConfig.fontBody)),
                        SizedBox(height: SizeConfig.spacingXS),
                        Text(
                            'Booking #${client.bookingId} | ${client.patientName} | ${client.serviceName}',
                            style: TextStyle(
                                fontSize: SizeConfig.fontBodySmall,
                                color: AppColor.fontColorGrey)),
                        Text(
                            'Outstanding: ${controller.formatCurrency(client.outstandingAmount)}',
                            style: TextStyle(
                                fontSize: SizeConfig.fontBodySmall,
                                color: Colors.red,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: SizeConfig.iconSM),
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
              Text('Select Client',
                  style: TextStyle(
                      fontSize: SizeConfig.fontBody,
                      fontWeight: FontWeight.w500,
                      color: AppColor.cPrimarySubHeadingColorGrey)),
              SizedBox(height: SizeConfig.spacingXS),
              Container(
                height: 44,
                padding:
                    EdgeInsets.symmetric(horizontal: SizeConfig.spacingSM),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: Text('Choose active client',
                        style: TextStyle(
                            color: AppColor.fontColorGrey,
                            fontSize: SizeConfig.fontBody)),
                    items: controller.activeClients.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.clientName} - #${c.bookingId}',
                            style:
                                TextStyle(fontSize: SizeConfig.fontBody)),
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
              ),
              SizedBox(height: SizeConfig.spacingMD),
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
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Reason',
          hint: 'Enter reason for write-off',
          controller: controller.writeOffReasonController,
          maxLines: 2,
          isMandatory: true,
        ),
        SizedBox(height: SizeConfig.spacingMD),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Approved By',
                    style: TextStyle(
                        fontSize: SizeConfig.fontBody,
                        fontWeight: FontWeight.w500,
                        color: AppColor.cPrimarySubHeadingColorGrey)),
                Text(' *',
                    style: TextStyle(
                        color: Colors.red, fontSize: SizeConfig.fontBody)),
              ],
            ),
            SizedBox(height: SizeConfig.spacingXS),
            Obx(() => Container(
                  height: 44,
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius:
                        BorderRadius.circular(SizeConfig.radiusMD),
                    border: Border.all(color: AppColor.textFieldBorderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.writeOffApprover.value.isEmpty
                          ? null
                          : controller.writeOffApprover.value,
                      hint: Text('Select approver',
                          style: TextStyle(
                              color: AppColor.fontColorGrey,
                              fontSize: SizeConfig.fontBody)),
                      items: controller.approverList
                          .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text(a,
                                  style: TextStyle(
                                      fontSize: SizeConfig.fontBody))))
                          .toList(),
                      onChanged: (v) =>
                          controller.writeOffApprover.value = v ?? '',
                    ),
                  ),
                )),
          ],
        ),
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Remarks',
          hint: 'Additional remarks (optional)',
          controller: controller.writeOffRemarksController,
          maxLines: 3,
        ),
        SizedBox(height: SizeConfig.spacingLG),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.createWriteOff,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.radiusSM)),
            ),
            child: Text('Submit Write-Off',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.fontBody,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
