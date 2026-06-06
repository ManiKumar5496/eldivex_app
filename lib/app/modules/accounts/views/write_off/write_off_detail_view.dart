import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../controllers/write_off_controller.dart';
import '../../models/write_off_model.dart';

class WriteOffDetailView extends StatefulWidget {
  const WriteOffDetailView({super.key});

  @override
  State<WriteOffDetailView> createState() => _WriteOffDetailViewState();
}

class _WriteOffDetailViewState extends State<WriteOffDetailView> {
  late final WriteOffController ctrl;
  late final int writeOffId;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<WriteOffController>();
    final args = Get.arguments;
    writeOffId = (args is Map) ? (args['write_off_id'] as int? ?? 0) : 0;

    // Ensure list is loaded so we can find the record
    if (ctrl.writeOffs.isEmpty) {
      ctrl.loadWriteOffs();
    }
  }

  WriteOffModel? get _writeOff {
    try {
      return ctrl.writeOffs.firstWhere((w) => w.id == writeOffId);
    } catch (_) {
      return null;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatCurrency(double amount) =>
      '₹${amount.toStringAsFixed(2)}';

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}-'
      '${_monthAbbr(dt.month)}-${dt.year}';

  String _monthAbbr(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  // ── Approve / Reject dialog ─────────────────────────────────────────────────

  void _showActionDialog(BuildContext context, String action) {
    final notesCtrl = ctrl.approvalNotesCtrl;
    notesCtrl.clear();

    final isApprove = action == 'approve';
    final actionColor = isApprove ? Colors.green : Colors.red;
    final actionLabel = isApprove ? 'Approve' : 'Reject';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: actionColor,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              '$actionLabel Write-off',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.cPrimaryHeadingColor,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isApprove
                    ? 'Add notes before approving this write-off.'
                    : 'Please provide a reason for rejection.',
                style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isApprove
                        ? 'Notes (optional)'
                        : 'Reason for rejection (required)',
                    hintStyle:
                        TextStyle(color: AppColor.fontColorGrey, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.fontColorGrey),
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: ctrl.isSubmitting.value
                    ? null
                    : () async {
                        if (!isApprove && notesCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Validation',
                            'Please provide a reason for rejection.',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        await ctrl.approveWriteOff(
                          writeOffId,
                          action,
                          notesCtrl.text.trim(),
                        );
                        Get.back();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  disabledBackgroundColor:
                      actionColor.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: ctrl.isSubmitting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        actionLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
              )),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColor.cPrimaryHeadingColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Write-off Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final wo = _writeOff;

        if (wo == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('Write-off #$writeOffId not found',
                    style: AppTextStyles.regular16Gre),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ctrl.loadWriteOffs(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final statusColor = _statusColor(wo.status);
        final isPending = wo.status == 'Pending';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ────────────────────────────────────────────────
              _card(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _idBadge('#${wo.id}'),
                              const SizedBox(width: 10),
                              _statusBadge(wo.status, statusColor),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatCurrency(wo.writeOffAmount),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _typeBadge(wo.serviceName),
                        ],
                      ),
                    ),
                    Icon(Icons.money_off,
                        size: 48, color: Colors.orange.shade100),
                  ],
                ),
              ]),
              const SizedBox(height: 16),

              // ── Details card ───────────────────────────────────────────────
              _card(
                title: 'Details',
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                children: [
                  _detailRow('Booking ID', '#${wo.bookingId}'),
                  _detailRow('Client', wo.clientName),
                  _detailRow('Patient', wo.patientName),
                  _detailRow('Mobile', wo.clientMobile),
                  _detailRow('Service', wo.serviceName),
                  _detailRow('Date', _formatDate(wo.writeOffDate)),
                  _detailRow('Reason', wo.reason),
                  if (wo.remarks != null && wo.remarks!.isNotEmpty)
                    _detailRow('Remarks', wo.remarks!),
                ],
              ),
              const SizedBox(height: 16),

              // ── Approval card (shown when Approved/Rejected) ───────────────
              if (!isPending)
                _card(
                  title: 'Approval Info',
                  icon: Icons.verified_user_outlined,
                  iconColor: statusColor,
                  children: [
                    _detailRow('Status', wo.status, valueColor: statusColor),
                    _detailRow('Approved By', wo.approvedBy),
                    _detailRow('Date', _formatDate(wo.writeOffDate)),
                  ],
                ),
              if (!isPending) const SizedBox(height: 16),

              // ── Action buttons (Pending only) ──────────────────────────────
              if (isPending)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showActionDialog(context, 'approve'),
                        icon: const Icon(Icons.check_circle_outline,
                            size: 18, color: Colors.white),
                        label: const Text(
                          'Approve',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showActionDialog(context, 'reject'),
                        icon: Icon(Icons.cancel_outlined,
                            size: 18, color: Colors.red.shade600),
                        label: Text(
                          'Reject',
                          style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Card helpers ────────────────────────────────────────────────────────────

  Widget _card({
    String? title,
    IconData? icon,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor ?? AppColor.cPrimaryButtonColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryHeadingColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColor.fontColorGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColor.cPrimaryHeadingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColor.cPrimarySubHeadingColorGrey,
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          color: AppColor.cPrimarySubHeadingColorGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
