import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/insurance_claim_model.dart';

class InsuranceClaimsView extends GetView<AccountsController> {
  const InsuranceClaimsView({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'settled':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  List<String> _nextStatuses(String current) {
    switch (current.toLowerCase()) {
      case 'pending':
        return ['Submitted', 'Rejected'];
      case 'submitted':
        return ['Approved', 'Rejected'];
      case 'approved':
        return ['Settled'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    return SizeConfig.adaptiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildDesktopLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClaimFormSheet(context),
        backgroundColor: Colors.blue.shade700,
        icon: Icon(Icons.add, color: AppColor.buttonTextWhite),
        label: Text('New Claim',
            style: TextStyle(color: AppColor.buttonTextWhite, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          _buildToolbar(),
          _buildStatusFilter(),
          Expanded(child: _buildMobileClaimList()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildToolbar(),
              _buildStatusFilter(),
              Expanded(child: _buildDesktopClaimList()),
            ],
          ),
        ),
        Expanded(flex: 2, child: _buildForm()),
      ],
    );
  }

  void _showClaimFormSheet(BuildContext context) {
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
                color: AppColor.divColor,
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
                    Icon(Icons.health_and_safety,
                        color: Colors.blue.shade700, size: SizeConfig.iconMD),
                    SizedBox(width: SizeConfig.spacingXS),
                    Text('New Insurance Claim',
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
                child: _buildFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(SizeConfig.pagePadding.left,
          SizeConfig.spacingMD, SizeConfig.spacingSM, 0),
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
                onChanged: (q) {
                  final lq = q.toLowerCase();
                  if (q.isEmpty) {
                    controller.filteredClaims.value =
                        List.from(controller.claims);
                  } else {
                    controller.filteredClaims.value =
                        controller.claims.where((c) {
                      return (c.clientName ?? '').toLowerCase().contains(lq) ||
                          (c.clientMobile ?? '').contains(q) ||
                          (c.patientName ?? '').toLowerCase().contains(lq) ||
                          c.bookingId.toString().contains(q) ||
                          (c.tpaName ?? '').toLowerCase().contains(lq) ||
                          (c.policyNumber ?? '').contains(q);
                    }).toList();
                  }
                },
                style: TextStyle(fontSize: SizeConfig.fontBody),
                decoration: InputDecoration(
                  hintText: 'Search by client, TPA, policy number...',
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
          SizedBox(width: SizeConfig.spacingXS),
          Tooltip(
            message: 'Refresh',
            child: InkWell(
              onTap: () => controller.fetchInsuranceClaims(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: Icon(Icons.refresh,
                    color: AppColor.cPrimaryButtonColor, size: SizeConfig.iconMD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      'All', 'Pending', 'Submitted', 'Approved', 'Settled', 'Rejected'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.pagePadding.left, vertical: SizeConfig.spacingSM),
      child: Row(
        children: statuses.map((s) {
          return Padding(
            padding: EdgeInsets.only(right: SizeConfig.spacingSM),
            child: FilterChip(
              label: Text(s,
                  style: TextStyle(fontSize: SizeConfig.fontBody)),
              selected: false,
              onSelected: (_) {
                if (s == 'All') {
                  controller.filteredClaims.value =
                      List.from(controller.claims);
                } else {
                  controller.filteredClaims.value =
                      controller.claims.where((c) => c.status == s).toList();
                }
              },
              backgroundColor: AppColor.whiteColor,
              labelStyle: TextStyle(color: AppColor.fontColorGrey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColor.textFieldBorderColor),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spacingXS, vertical: SizeConfig.spacingXS / 2),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileClaimList() {
    return Obx(() {
      if (controller.isLoadingClaims.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredClaims.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 64, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No insurance claims found',
                  style: AppTextStyles.regular16Gre),
              SizedBox(height: SizeConfig.spacingXS),
              Text(
                'Tap the button below to add\na new insurance claim.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: SizeConfig.fontBody, color: AppColor.fontColorGrey),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
            SizeConfig.pagePadding.left,
            SizeConfig.spacingXS,
            SizeConfig.pagePadding.right,
            80),
        itemCount: controller.filteredClaims.length,
        itemBuilder: (_, i) =>
            _buildMobileClaimCard(controller.filteredClaims[i]),
      );
    });
  }

  Widget _buildMobileClaimCard(InsuranceClaimModel claim) {
    final statusColor = _statusColor(claim.status);
    final nextList = _nextStatuses(claim.status);
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
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
              Text('Booking #${claim.bookingId}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: SizeConfig.fontBody,
                      color: AppColor.cPrimaryButtonColor)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM,
                    vertical: SizeConfig.spacingXS),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(claim.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: SizeConfig.fontCaption,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          Divider(height: SizeConfig.spacingLG, color: AppColor.fieldColorGrey),

          // Row 2: Client / Patient
          Text(claim.clientName ?? '-',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: SizeConfig.fontBody)),
          Text(claim.patientName ?? '-',
              style: TextStyle(
                  fontSize: SizeConfig.fontCaption,
                  color: AppColor.fontColorGrey)),
          SizedBox(height: SizeConfig.spacingSM),

          // Row 3: TPA + Policy #
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TPA',
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                    Text(claim.tpaName ?? '-',
                        style:
                            TextStyle(fontSize: SizeConfig.fontBody, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: SizeConfig.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Policy #',
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                    Text(claim.policyNumber ?? '-',
                        style: TextStyle(fontSize: SizeConfig.fontBody),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.spacingSM),

          // Row 4: Claim Amount + Settled Amount
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Claim Amount',
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                    Text(
                      claim.claimAmount != null
                          ? controller.formatCurrency(claim.claimAmount!)
                          : '-',
                      style: TextStyle(
                          fontSize: SizeConfig.fontH3,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settled',
                        style: TextStyle(
                            fontSize: SizeConfig.fontCaption,
                            color: AppColor.fontColorGrey)),
                    Text(
                      claim.settledAmount != null
                          ? controller.formatCurrency(claim.settledAmount!)
                          : '-',
                      style: TextStyle(
                          fontSize: SizeConfig.fontBody,
                          fontWeight: FontWeight.w600,
                          color: claim.settledAmount != null
                              ? Colors.green
                              : AppColor.fontColorGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom: Status action button
          if (nextList.isNotEmpty) ...[
            Divider(height: SizeConfig.spacingLG, color: AppColor.fieldColorGrey),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _showStatusActionsSheet(claim, nextList),
                icon: Icon(Icons.update, size: SizeConfig.iconSM),
                label: Text('Update Status',
                    style: TextStyle(fontSize: SizeConfig.fontBody)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SizeConfig.radiusSM)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showStatusActionsSheet(
      InsuranceClaimModel claim, List<String> nextList) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppColor.divColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.pagePadding.left,
                vertical: SizeConfig.spacingSM),
            child: Text('Update Claim Status',
                style: TextStyle(
                    fontSize: SizeConfig.fontH3,
                    fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 1),
          ...nextList.map((s) => ListTile(
                leading: Icon(_statusIcon(s),
                    color: _statusColor(s), size: SizeConfig.iconMD),
                title: Text(s,
                    style: TextStyle(
                        fontSize: SizeConfig.fontBody,
                        fontWeight: FontWeight.w500,
                        color: _statusColor(s))),
                minLeadingWidth: 32,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.pagePadding.left,
                    vertical: SizeConfig.spacingXS),
                onTap: () {
                  Navigator.pop(ctx);
                  if (s == 'Settled') {
                    _showSettleDialog(claim);
                  } else {
                    _confirmStatusUpdate(claim, s);
                  }
                },
              )),
          SizedBox(height: SizeConfig.spacingMD),
        ],
      ),
    );
  }

  Widget _buildDesktopClaimList() {
    return Obx(() {
      if (controller.isLoadingClaims.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredClaims.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 64, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No insurance claims found',
                  style: AppTextStyles.regular16Gre),
              SizedBox(height: SizeConfig.spacingXS),
              Text(
                'Use the form on the right to link\na TPA/insurance claim to a booking.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: SizeConfig.fontBody, color: AppColor.fontColorGrey),
              ),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        padding: EdgeInsets.only(
            left: SizeConfig.pagePadding.left,
            right: SizeConfig.spacingSM,
            bottom: SizeConfig.spacingLG),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.divColor),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColor.fieldColorGrey),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.cPrimaryHeadingColor,
              ),
              dataTextStyle: TextStyle(fontSize: SizeConfig.fontBodySmall),
              columnSpacing: SizeConfig.spacingMD,
              horizontalMargin: SizeConfig.spacingMD,
              columns: const [
                DataColumn(label: Text('Booking')),
                DataColumn(label: Text('Client / Patient')),
                DataColumn(label: Text('TPA')),
                DataColumn(label: Text('Policy #')),
                DataColumn(label: Text('Claim Amt')),
                DataColumn(label: Text('Settled')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: controller.filteredClaims
                  .map((claim) => _buildRow(claim))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  DataRow _buildRow(InsuranceClaimModel claim) {
    final statusColor = _statusColor(claim.status);
    final nextList = _nextStatuses(claim.status);
    return DataRow(cells: [
      DataCell(Text('#${claim.bookingId}',
          style: AppTextStyles.regular14black)),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(claim.clientName ?? '-',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: SizeConfig.fontBodySmall)),
          Text(claim.patientName ?? '-',
              style: TextStyle(
                  fontSize: SizeConfig.fontCaption,
                  color: AppColor.fontColorGrey)),
        ],
      )),
      DataCell(Text(claim.tpaName ?? '-',
          style: TextStyle(fontSize: SizeConfig.fontBodySmall))),
      DataCell(Text(claim.policyNumber ?? '-',
          style: TextStyle(fontSize: SizeConfig.fontBodySmall))),
      DataCell(Text(
        claim.claimAmount != null
            ? controller.formatCurrency(claim.claimAmount!)
            : '-',
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: SizeConfig.fontBodySmall),
      )),
      DataCell(Text(
        claim.settledAmount != null
            ? controller.formatCurrency(claim.settledAmount!)
            : '-',
        style: TextStyle(
            fontSize: SizeConfig.fontBodySmall,
            color: claim.settledAmount != null ? Colors.green : AppColor.fontColorGrey),
      )),
      DataCell(Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.spacingSM, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(claim.status,
            style: TextStyle(
                color: statusColor,
                fontSize: SizeConfig.fontCaption,
                fontWeight: FontWeight.w500)),
      )),
      DataCell(nextList.isEmpty
          ? Icon(Icons.lock_outline,
              size: SizeConfig.iconSM, color: AppColor.lightGrey)
          : _buildStatusActions(claim, nextList)),
    ]);
  }

  Widget _buildStatusActions(InsuranceClaimModel claim, List<String> nextList) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert,
          color: AppColor.fontColorGrey, size: SizeConfig.iconMD),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusSM)),
      onSelected: (newStatus) {
        if (newStatus == 'Settled') {
          _showSettleDialog(claim);
        } else {
          _confirmStatusUpdate(claim, newStatus);
        }
      },
      itemBuilder: (_) => nextList.map((s) {
        return PopupMenuItem<String>(
          value: s,
          child: Row(
            children: [
              Icon(_statusIcon(s), size: SizeConfig.iconSM, color: _statusColor(s)),
              SizedBox(width: SizeConfig.spacingXS),
              Text(s, style: TextStyle(fontSize: SizeConfig.fontBody)),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.upload_file;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      case 'settled':
        return Icons.paid;
      default:
        return Icons.circle;
    }
  }

  void _confirmStatusUpdate(InsuranceClaimModel claim, String newStatus) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD)),
      title: Text('Update Claim Status',
          style: TextStyle(
              fontSize: SizeConfig.fontH3,
              fontWeight: FontWeight.w600,
              color: AppColor.cPrimaryHeadingColor)),
      content: Text(
          'Mark claim for booking #${claim.bookingId} as "$newStatus"?',
          style: TextStyle(fontSize: SizeConfig.fontBody)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel',
              style: TextStyle(color: AppColor.fontColorGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.updateClaimStatus(claim.id, newStatus);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _statusColor(newStatus),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(SizeConfig.radiusSM)),
          ),
          child: Text(newStatus,
              style: TextStyle(color: AppColor.buttonTextWhite)),
        ),
      ],
    ));
  }

  void _showSettleDialog(InsuranceClaimModel claim) {
    final amtCtrl = TextEditingController(
        text: claim.claimAmount?.toStringAsFixed(2) ?? '');
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD)),
      title: Text('Settle Insurance Claim',
          style: TextStyle(
              fontSize: SizeConfig.fontH3, fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking #${claim.bookingId} | ${claim.tpaName ?? ''}',
              style: TextStyle(
                  fontSize: SizeConfig.fontBodySmall,
                  color: AppColor.fontColorGrey)),
          SizedBox(height: SizeConfig.spacingMD),
          CommonTextField(
            label: 'Settled Amount',
            hint: 'Enter final settled amount',
            controller: amtCtrl,
            keyboardType: TextInputType.number,
            isMandatory: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amtCtrl.text);
            Get.back();
            controller.updateClaimStatus(claim.id, 'Settled',
                settledAmount: amount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM)),
          ),
          child: Text('Mark Settled',
              style: TextStyle(color: AppColor.buttonTextWhite)),
        ),
      ],
    ));
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(SizeConfig.spacingXS, SizeConfig.spacingMD,
          SizeConfig.pagePadding.right, SizeConfig.spacingLG),
      child: Container(
        padding: SizeConfig.cardPadding,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          border: Border.all(color: AppColor.divColor),
        ),
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.health_and_safety,
                color: Colors.blue.shade700, size: SizeConfig.iconMD),
            SizedBox(width: SizeConfig.spacingXS),
            Text('New Insurance Claim',
                style: TextStyle(
                    fontSize: SizeConfig.fontH3,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryHeadingColor)),
          ],
        ),
        SizedBox(height: SizeConfig.spacingXS),
        Text('Link a TPA/insurance claim to an active booking',
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.fontColorGrey)),
        Divider(height: SizeConfig.spacingLG),

        // Client selector
        Obx(() {
          final client = controller.selectedClientForClaim.value;
          if (client != null) {
            return Container(
              padding: SizeConfig.cardPadding,
              margin: EdgeInsets.only(bottom: SizeConfig.spacingMD),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                border: Border.all(color: Colors.blue.shade100),
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
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: SizeConfig.iconSM),
                    onPressed: () =>
                        controller.selectedClientForClaim.value = null,
                  ),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Booking / Client',
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
              Container(
                height: 44,
                padding:
                    EdgeInsets.symmetric(horizontal: SizeConfig.spacingSM),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: Text('Select active booking',
                        style: TextStyle(
                            color: AppColor.fontColorGrey,
                            fontSize: SizeConfig.fontBody)),
                    items: controller.activeClients.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.clientName} — #${c.bookingId}',
                            style: TextStyle(fontSize: SizeConfig.fontBody)),
                      );
                    }).toList(),
                    onChanged: (id) {
                      final c = controller.activeClients
                          .firstWhereOrNull((cl) => cl.id == id);
                      if (c != null) {
                        controller.selectedClientForClaim.value = c;
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
          label: 'TPA / Insurance Company Name',
          hint: 'e.g. Medi Assist, Vidal Health',
          controller: controller.claimTpaNameController,
          isMandatory: true,
        ),
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Policy Number',
          hint: 'Enter policy number',
          controller: controller.claimPolicyNumberController,
        ),
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Pre-Auth / Reference Number',
          hint: 'Enter pre-authorisation number (if any)',
          controller: controller.claimPreAuthController,
        ),
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Claim Amount',
          hint: 'Enter claim amount (₹)',
          controller: controller.claimAmountController,
          keyboardType: TextInputType.number,
          isMandatory: true,
        ),
        SizedBox(height: SizeConfig.spacingMD),

        CommonTextField(
          label: 'Remarks',
          hint: 'Additional notes or instructions',
          controller: controller.claimRemarksController,
          maxLines: 3,
        ),
        SizedBox(height: SizeConfig.spacingLG),

        Obx(() => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoadingClaims.value
                    ? null
                    : controller.createInsuranceClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  disabledBackgroundColor:
                      Colors.blue.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SizeConfig.radiusSM)),
                ),
                child: controller.isLoadingClaims.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: AppColor.buttonTextWhite, strokeWidth: 2),
                      )
                    : Text('Submit Insurance Claim',
                        style: TextStyle(
                            color: AppColor.buttonTextWhite,
                            fontSize: SizeConfig.fontBody,
                            fontWeight: FontWeight.w600)),
              ),
            )),
      ],
    );
  }
}
