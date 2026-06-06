import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../controllers/internal_transfer_controller.dart';
import '../../models/internal_transfer_model.dart';

class TransferDetailView extends StatefulWidget {
  const TransferDetailView({super.key});

  @override
  State<TransferDetailView> createState() => _TransferDetailViewState();
}

class _TransferDetailViewState extends State<TransferDetailView> {
  late final InternalTransferController ctrl;
  InternalTransferModel? _transfer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<InternalTransferController>()) {
      ctrl = Get.find<InternalTransferController>();
    } else {
      ctrl = Get.put(InternalTransferController());
    }
    _resolveTransfer();
  }

  void _resolveTransfer() {
    final arg = Get.arguments;
    final transferId = arg is int ? arg : int.tryParse(arg?.toString() ?? '');

    if (transferId == null) {
      setState(() => _loading = false);
      return;
    }

    // Check if already in list
    final existing = ctrl.transfers.firstWhereOrNull((t) => t.id == transferId);
    if (existing != null) {
      setState(() {
        _transfer = existing;
        _loading = false;
      });
    } else {
      // Load and wait
      ctrl.loadTransfers().then((_) {
        final found = ctrl.transfers.firstWhereOrNull((t) => t.id == transferId);
        if (mounted) {
          setState(() {
            _transfer = found;
            _loading = false;
          });
        }
      });
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'REVERSED':
        return Colors.purple;
      case 'PENDING_APPROVAL':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatType(String type) => type.replaceAll('_', ' ');

  String _formatDate(String? s) {
    if (s == null || s.isEmpty) return '-';
    try {
      final dt = DateTime.parse(s);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return s;
    }
  }

  String _formatCurrency(double? v) {
    if (v == null) return '₹0.00';
    return '₹${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

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
          _transfer != null ? 'Transfer #IT-${_transfer!.id}' : 'Transfer Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transfer == null
              ? _buildNotFound()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(_transfer!),
                          const SizedBox(height: 20),
                          _buildTransferVisualization(_transfer!),
                          const SizedBox(height: 20),
                          _buildInfoCard(_transfer!),
                          const SizedBox(height: 20),
                          _buildTimeline(_transfer!),
                          // Action buttons for pending transfers
                          if (_transfer!.status.toUpperCase() == 'PENDING_APPROVAL') ...[
                            const SizedBox(height: 20),
                            _buildActionButtons(_transfer!),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // ─────────────────────────────────────────────
  // Not found
  // ─────────────────────────────────────────────

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Transfer not found', style: AppTextStyles.regular16Gre),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header card
  // ─────────────────────────────────────────────

  Widget _buildHeaderCard(InternalTransferModel t) {
    final statusColor = _statusColor(t.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // ID row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'IT-${t.id}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatType(t.status),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(t.createdOn),
                style:
                    TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amount (prominent, center)
          Text(
            _formatCurrency(t.transferAmount),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColor.cPrimaryHeadingColor,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'transferred from ${t.sourceBookingRef ?? '#${t.sourceBookingId}'} to ${t.targetBookingRef ?? '#${t.targetBookingId}'}',
            style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Client chip
          if (t.clientName != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: AppColor.fontColorGrey),
                const SizedBox(width: 6),
                Text(
                  t.clientName!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.cPrimarySubHeadingColorGrey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Transfer visualization
  // ─────────────────────────────────────────────

  Widget _buildTransferVisualization(InternalTransferModel t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined,
                  size: 18, color: AppColor.cPrimaryButtonColor),
              const SizedBox(width: 8),
              Text(
                'Transfer Route',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _bookingCard(
                  label: 'Source Booking',
                  ref: t.sourceBookingRef ?? '#${t.sourceBookingId}',
                  client: t.clientName,
                  balanceBefore: t.sourceBookingBalance,
                  balanceAfter: t.sourceBookingBalance != null
                      ? t.sourceBookingBalance! + t.transferAmount
                      : null,
                  isSource: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.cPrimaryButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatCurrency(t.transferAmount),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.cPrimaryButtonColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _bookingCard(
                  label: 'Target Booking',
                  ref: t.targetBookingRef ?? '#${t.targetBookingId}',
                  client: t.clientName,
                  balanceBefore: t.targetBookingBalance,
                  balanceAfter: t.targetBookingBalance != null
                      ? t.targetBookingBalance! - t.transferAmount
                      : null,
                  isSource: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookingCard({
    required String label,
    required String ref,
    String? client,
    double? balanceBefore,
    double? balanceAfter,
    required bool isSource,
  }) {
    final accentColor = isSource ? Colors.orange : Colors.teal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accentColor.shade700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ref,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColor.cPrimaryHeadingColor,
            ),
          ),
          if (client != null) ...[
            const SizedBox(height: 4),
            Text(client,
                style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
          ],
          if (balanceBefore != null) ...[
            const Divider(height: 16),
            _balanceRow('Before', balanceBefore),
          ],
          if (balanceAfter != null) ...[
            const SizedBox(height: 4),
            _balanceRow('After', balanceAfter, highlight: true),
          ],
        ],
      ),
    );
  }

  Widget _balanceRow(String labelText, double amount,
      {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 11,
            color: AppColor.fontColorGrey,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
            color: highlight
                ? (amount > 0 ? Colors.red.shade700 : Colors.green.shade700)
                : AppColor.cPrimarySubHeadingColorGrey,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Info card (type + reason + notes)
  // ─────────────────────────────────────────────

  Widget _buildInfoCard(InternalTransferModel t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 18, color: AppColor.cPrimaryButtonColor),
              const SizedBox(width: 8),
              Text(
                'Transfer Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow('Transfer Type', _formatType(t.transferType)),
          const SizedBox(height: 12),
          _infoRow('Reason', t.reason, multiline: true),
          if (t.notes != null && t.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoRow('Notes', t.notes!, multiline: true),
          ],
          if (t.requestedByName != null) ...[
            const SizedBox(height: 12),
            _infoRow('Requested By', t.requestedByName!),
          ],
          if (t.approvedByName != null) ...[
            const SizedBox(height: 12),
            _infoRow('Actioned By', t.approvedByName!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool multiline = false}) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.fontColorGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColor.cPrimarySubHeadingColorGrey,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Timeline
  // ─────────────────────────────────────────────

  Widget _buildTimeline(InternalTransferModel t) {
    final steps = <_TimelineStep>[];

    steps.add(_TimelineStep(
      icon: Icons.add_circle_outline,
      color: Colors.blue,
      title: 'Transfer Requested',
      subtitle: t.requestedByName != null
          ? 'By ${t.requestedByName}'
          : 'Transfer submitted for review',
      date: _formatDate(t.createdOn),
      done: true,
    ));

    final status = t.status.toUpperCase();

    if (status == 'PENDING_APPROVAL') {
      steps.add(_TimelineStep(
        icon: Icons.hourglass_top_outlined,
        color: Colors.orange,
        title: 'Awaiting Finance Head Approval',
        subtitle: 'Transfer is pending review',
        date: '',
        done: false,
      ));
    } else if (status == 'APPROVED') {
      steps.add(_TimelineStep(
        icon: Icons.check_circle_outline,
        color: Colors.green,
        title: 'Approved',
        subtitle: t.approvedByName != null
            ? 'Approved by ${t.approvedByName}'
            : 'Transfer approved',
        date: _formatDate(t.approvedAt),
        done: true,
      ));
      steps.add(_TimelineStep(
        icon: Icons.swap_horiz_rounded,
        color: Colors.teal,
        title: 'Transfer Applied',
        subtitle: 'Balances updated on both bookings',
        date: _formatDate(t.approvedAt),
        done: true,
      ));
    } else if (status == 'REJECTED') {
      steps.add(_TimelineStep(
        icon: Icons.cancel_outlined,
        color: Colors.red,
        title: 'Rejected',
        subtitle: t.approvedByName != null
            ? 'Rejected by ${t.approvedByName}'
            : 'Transfer rejected',
        date: _formatDate(t.updatedOn),
        done: true,
      ));
    } else if (status == 'REVERSED') {
      steps.add(_TimelineStep(
        icon: Icons.check_circle_outline,
        color: Colors.green,
        title: 'Approved',
        subtitle: t.approvedByName != null
            ? 'Approved by ${t.approvedByName}'
            : 'Transfer approved',
        date: _formatDate(t.approvedAt),
        done: true,
      ));
      steps.add(_TimelineStep(
        icon: Icons.undo_rounded,
        color: Colors.purple,
        title: 'Reversed',
        subtitle: t.reversalReason != null
            ? 'Reason: ${t.reversalReason}'
            : 'Transfer reversed',
        date: _formatDate(t.reversedAt),
        done: true,
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_outlined,
                  size: 18, color: AppColor.cPrimaryButtonColor),
              const SizedBox(width: 8),
              Text(
                'Approval History',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isLast = idx == steps.length - 1;
            return _buildTimelineStep(step, isLast: isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(_TimelineStep step, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + connector
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: step.done
                    ? step.color.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.done ? step.color : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Icon(
                step.icon,
                size: 18,
                color: step.done ? step.color : Colors.grey.shade400,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: step.done
                              ? AppColor.cPrimaryHeadingColor
                              : AppColor.fontColorGrey,
                        ),
                      ),
                    ),
                    if (step.date.isNotEmpty)
                      Text(
                        step.date,
                        style: TextStyle(
                            fontSize: 12, color: AppColor.fontColorGrey),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColor.fontColorGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Action buttons (PENDING_APPROVAL only)
  // ─────────────────────────────────────────────

  Widget _buildActionButtons(InternalTransferModel t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions_outlined,
                  size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Action Required',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This transfer is awaiting Finance Head approval.',
            style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
          ),
          const SizedBox(height: 20),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: ctrl.isSubmitting.value
                          ? null
                          : () => _showActionDialog(
                                transfer: t,
                                action: 'REJECT',
                              ),
                      icon: const Icon(Icons.close, size: 18,
                          color: Colors.red),
                      label: const Text('Reject',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: ctrl.isSubmitting.value
                          ? null
                          : () => _showActionDialog(
                                transfer: t,
                                action: 'APPROVE',
                              ),
                      icon: ctrl.isSubmitting.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check, size: 18,
                              color: Colors.white),
                      label: Text(
                        ctrl.isSubmitting.value ? 'Processing...' : 'Approve',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void _showActionDialog({
    required InternalTransferModel transfer,
    required String action,
  }) {
    final notesCtrl = TextEditingController();
    final isApprove = action == 'APPROVE';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApprove ? Colors.green : Colors.red,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              isApprove ? 'Approve Transfer' : 'Reject Transfer',
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
                    ? 'Approve IT-${transfer.id} of ${_formatCurrency(transfer.transferAmount)}?'
                    : 'Reject IT-${transfer.id} of ${_formatCurrency(transfer.transferAmount)}?',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                isApprove ? 'Approval Notes (optional)' : 'Rejection Reason *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColor.cPrimarySubHeadingColorGrey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: isApprove
                      ? 'Add any notes...'
                      : 'Explain why this transfer is rejected...',
                  hintStyle: TextStyle(
                      color: AppColor.fontColorGrey, fontSize: 13),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppColor.textFieldBorderColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: AppColor.fontColorGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!isApprove && notesCtrl.text.trim().isEmpty) {
                return;
              }
              Get.back();
              ctrl
                  .approveTransfer(transfer.id, action, notesCtrl.text.trim())
                  .then((_) => _resolveTransfer());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isApprove ? 'Approve' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Timeline step data class
// ─────────────────────────────────────────────

class _TimelineStep {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String date;
  final bool done;

  const _TimelineStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.done,
  });
}
