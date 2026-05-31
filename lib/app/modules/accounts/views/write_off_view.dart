import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';

class WriteOffView extends GetView<AccountsController> {
  const WriteOffView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountsController());
    return Column(
      children: [
        _buildWriteOffSearchBar(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildWriteOffList()),
              Expanded(flex: 2, child: _buildWriteOffForm()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWriteOffSearchBar() {
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
                controller: controller.searchWriteOffController,
                onChanged: controller.searchWriteOffs,
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
              const SizedBox(height: 12),
              Text('No write-offs found', style: AppTextStyles.regular16Gre),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, bottom: 20),
        child: Container(
          width: double.infinity,
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
            columnSpacing: 16,
            horizontalMargin: 12,
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
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(wo.patientName,
                        style: TextStyle(
                            fontSize: 11, color: AppColor.fontColorGrey)),
                  ],
                )),
                DataCell(Text(wo.serviceName)),
                DataCell(Text(
                  controller.formatCurrency(wo.writeOffAmount),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.red),
                )),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Tooltip(
                      message: wo.reason,
                      child: Text(wo.reason,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                DataCell(Text(wo.approvedBy)),
                DataCell(Text(controller.formatDate(wo.writeOffDate))),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(wo.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                )),
                DataCell(
                  isPending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Approve Write-Off',
                              child: InkWell(
                                onTap: () => controller.approveWriteOff(wo.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.check,
                                      size: 16, color: Colors.green),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'Reject Write-Off',
                              child: InkWell(
                                onTap: () => controller.rejectWriteOff(wo.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Icon(Icons.check_circle_outline,
                          size: 18, color: Colors.grey.shade400),
                ),
              ]);
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildWriteOffForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.money_off,
                    color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text('Create Write-Off',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.cPrimaryHeadingColor)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
                'Select a client from Active Clients tab or choose below',
                style:
                    TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
            const Divider(height: 24),

            // Selected Client Info
            Obx(() {
              final client = controller.selectedClientForWriteOff.value;
              if (client != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client.clientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                                'Booking #${client.bookingId} | ${client.patientName} | ${client.serviceName}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColor.fontColorGrey)),
                            Text(
                                'Outstanding: ${controller.formatCurrency(client.outstandingAmount)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            controller.selectedClientForWriteOff.value = null,
                      ),
                    ],
                  ),
                );
              }
              // Client Dropdown
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Client',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.cPrimarySubHeadingColorGrey)),
                  const SizedBox(height: 8),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColor.textFieldBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: Text('Choose active client',
                            style: TextStyle(
                                color: AppColor.fontColorGrey, fontSize: 14)),
                        items: controller.activeClients.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(
                                '${c.clientName} - #${c.bookingId}',
                                style: const TextStyle(fontSize: 14)),
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
            const SizedBox(height: 14),

            CommonTextField(
              label: 'Reason',
              hint: 'Enter reason for write-off',
              controller: controller.writeOffReasonController,
              maxLines: 2,
              isMandatory: true,
            ),
            const SizedBox(height: 14),

            // Approver Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Approved By',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.cPrimarySubHeadingColorGrey)),
                    const Text(' *',
                        style: TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColor.textFieldBorderColor),
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
                                  fontSize: 14)),
                          items: controller.approverList
                              .map((a) => DropdownMenuItem(
                                  value: a, child: Text(a)))
                              .toList(),
                          onChanged: (v) =>
                              controller.writeOffApprover.value = v ?? '',
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 14),

            CommonTextField(
              label: 'Remarks',
              hint: 'Additional remarks (optional)',
              controller: controller.writeOffRemarksController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: controller.createWriteOff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Submit Write-Off',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
