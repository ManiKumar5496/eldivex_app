import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/insurance_claim_model.dart';

class InsuranceClaimsView extends GetView<AccountsController> {
  const InsuranceClaimsView({super.key});

  // ─────────────────────────────────────────────
  // Status colour helper
  // ─────────────────────────────────────────────
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
        return Colors.orange; // Pending
    }
  }

  // Status workflow: what transitions are allowed from each status
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
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: list ──
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildToolbar(),
              _buildStatusFilter(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
        // ── Right: create form ──
        Expanded(
          flex: 2,
          child: _buildForm(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Search toolbar
  // ─────────────────────────────────────────────
  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
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
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by client, TPA, policy number...',
                  hintStyle:
                      TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: AppColor.fontColorGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                    color: AppColor.cPrimaryButtonColor, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Status filter chips
  // ─────────────────────────────────────────────
  Widget _buildStatusFilter() {
    final statuses = ['All', 'Pending', 'Submitted', 'Approved', 'Settled', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: statuses.map((s) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Claims list
  // ─────────────────────────────────────────────
  Widget _buildList() {
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
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No insurance claims found',
                  style: AppTextStyles.regular16Gre),
              const SizedBox(height: 8),
              Text(
                'Use the form on the right to link\na TPA/insurance claim to a booking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 12, bottom: 20),
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
            columnSpacing: 14,
            horizontalMargin: 14,
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
      );
    });
  }

  DataRow _buildRow(InsuranceClaimModel claim) {
    final statusColor = _statusColor(claim.status);
    final nextList = _nextStatuses(claim.status);
    return DataRow(cells: [
      // Booking
      DataCell(Text('#${claim.bookingId}',
          style: AppTextStyles.regular14black)),

      // Client
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(claim.clientName ?? '-',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Text(claim.patientName ?? '-',
              style:
                  TextStyle(fontSize: 11, color: AppColor.fontColorGrey)),
        ],
      )),

      // TPA
      DataCell(Text(claim.tpaName ?? '-',
          style: const TextStyle(fontSize: 13))),

      // Policy #
      DataCell(Text(claim.policyNumber ?? '-',
          style: const TextStyle(fontSize: 12))),

      // Claim Amount
      DataCell(Text(
        claim.claimAmount != null
            ? controller.formatCurrency(claim.claimAmount!)
            : '-',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      )),

      // Settled Amount
      DataCell(Text(
        claim.settledAmount != null
            ? controller.formatCurrency(claim.settledAmount!)
            : '-',
        style: TextStyle(
            fontSize: 13,
            color: claim.settledAmount != null ? Colors.green : Colors.grey),
      )),

      // Status chip
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(claim.status,
            style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      )),

      // Status transition actions
      DataCell(nextList.isEmpty
          ? Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400)
          : _buildStatusActions(claim, nextList)),
    ]);
  }

  Widget _buildStatusActions(InsuranceClaimModel claim, List<String> nextList) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColor.fontColorGrey, size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              Icon(_statusIcon(s), size: 16, color: _statusColor(s)),
              const SizedBox(width: 8),
              Text(s, style: const TextStyle(fontSize: 14)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Update Claim Status',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.cPrimaryHeadingColor)),
      content: Text(
          'Mark claim for booking #${claim.bookingId} as "$newStatus"?',
          style: const TextStyle(fontSize: 14)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(newStatus,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _showSettleDialog(InsuranceClaimModel claim) {
    final amtCtrl = TextEditingController(
        text: claim.claimAmount?.toStringAsFixed(2) ?? '');
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Settle Insurance Claim',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking #${claim.bookingId} | ${claim.tpaName ?? ''}',
              style:
                  TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
          const SizedBox(height: 16),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Mark Settled',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  // ─────────────────────────────────────────────
  // Create claim form
  // ─────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 20),
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
            // Header
            Row(
              children: [
                Icon(Icons.health_and_safety,
                    color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'New Insurance Claim',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryHeadingColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Link a TPA/insurance claim to an active booking',
              style:
                  TextStyle(fontSize: 12, color: AppColor.fontColorGrey),
            ),
            const Divider(height: 24),

            // Client selector
            Obx(() {
              final client = controller.selectedClientForClaim.value;
              if (client != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
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
                                  color: AppColor.fontColorGrey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            controller.selectedClientForClaim.value = null,
                      ),
                    ],
                  ),
                );
              }
              // Dropdown when no client selected
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Booking / Client',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.cPrimarySubHeadingColorGrey)),
                      const Text(' *',
                          style:
                              TextStyle(color: Colors.red, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 44,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColor.textFieldBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: Text('Select active booking',
                            style: TextStyle(
                                color: AppColor.fontColorGrey,
                                fontSize: 14)),
                        items: controller.activeClients.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              '${c.clientName} — #${c.bookingId}',
                              style: const TextStyle(fontSize: 14),
                            ),
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
                  const SizedBox(height: 16),
                ],
              );
            }),

            // TPA Name
            CommonTextField(
              label: 'TPA / Insurance Company Name',
              hint: 'e.g. Medi Assist, Vidal Health',
              controller: controller.claimTpaNameController,
              isMandatory: true,
            ),
            const SizedBox(height: 14),

            // Policy Number
            CommonTextField(
              label: 'Policy Number',
              hint: 'Enter policy number',
              controller: controller.claimPolicyNumberController,
            ),
            const SizedBox(height: 14),

            // Pre-auth Number
            CommonTextField(
              label: 'Pre-Auth / Reference Number',
              hint: 'Enter pre-authorisation number (if any)',
              controller: controller.claimPreAuthController,
            ),
            const SizedBox(height: 14),

            // Claim Amount
            CommonTextField(
              label: 'Claim Amount',
              hint: 'Enter claim amount (₹)',
              controller: controller.claimAmountController,
              keyboardType: TextInputType.number,
              isMandatory: true,
            ),
            const SizedBox(height: 14),

            // Remarks
            CommonTextField(
              label: 'Remarks',
              hint: 'Additional notes or instructions',
              controller: controller.claimRemarksController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Submit button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: controller.isLoadingClaims.value
                        ? null
                        : controller.createInsuranceClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      disabledBackgroundColor:
                          Colors.blue.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isLoadingClaims.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Submit Insurance Claim',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
