import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../../../widgets/common_textfield.dart';
import '../../controllers/refund_controller.dart';
import '../../models/refund_model.dart';

class RefundDetailView extends GetView<RefundController> {
  const RefundDetailView({super.key});

  // ── Route argument ──────────────────────────────────────────────────────────

  int get _refundId {
    final args = Get.arguments;
    if (args is int) return args;
    return int.tryParse(args?.toString() ?? '') ?? 0;
  }

  // ── Status helpers ──────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.grey;
      case 'PENDING_APPROVAL':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Trigger load on first paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadRefundById(_refundId);
    });

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
          color: AppColor.cPrimaryHeadingColor,
        ),
        title: Text(
          'Refund Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerLoader.table();
        }

        final refund = controller.selectedRefund.value;
        if (refund == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('Refund not found', style: AppTextStyles.regular16Gre),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => controller.loadRefundById(_refundId),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ──────────────────────────────────────────────
              _buildHeaderCard(refund),
              const SizedBox(height: 16),

              // ── Channel details ──────────────────────────────────────────
              if (refund.channelDetails != null &&
                  refund.channelDetails!.isNotEmpty) ...[
                _buildChannelCard(refund),
                const SizedBox(height: 16),
              ],

              // ── Booking & Client ─────────────────────────────────────────
              _buildBookingClientCard(refund),
              const SizedBox(height: 16),

              // ── Notes ────────────────────────────────────────────────────
              if (refund.notes != null && refund.notes!.isNotEmpty) ...[
                _buildNotesCard(refund.notes!),
                const SizedBox(height: 16),
              ],

              // ── Timeline / Approval history ──────────────────────────────
              _buildTimelineCard(refund),
              const SizedBox(height: 24),

              // ── Action buttons ───────────────────────────────────────────
              _buildActionButtons(context, refund),
            ],
          ),
        );
      }),
    );
  }

  // ── Cards ───────────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(RefundModel r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Refund ID + reason
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REF-${r.id}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColor.cPrimaryHeadingColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.refundReason.replaceAll('_', ' '),
                      style: TextStyle(
                          fontSize: 13, color: AppColor.fontColorGrey),
                    ),
                  ],
                ),
              ),
              _statusBadge(r.status),
            ],
          ),
          const SizedBox(height: 16),
          // Prominent amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.currency_rupee_rounded,
                    color: Colors.red.shade700, size: 24),
                const SizedBox(width: 6),
                Text(
                  r.refundAmount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade700,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('via ${r.refundChannel.replaceAll('_', ' ')}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.red.shade600)),
                    if (r.approvalLevel != null)
                      Text('Level: ${r.approvalLevel}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.red.shade400)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Meta row
          Row(
            children: [
              _metaChip(Icons.calendar_today_outlined,
                  r.createdOn != null ? _formatDate(r.createdOn!) : '—'),
              const SizedBox(width: 10),
              if (r.requestedByName != null)
                _metaChip(
                    Icons.person_outline_rounded, 'By ${r.requestedByName}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelCard(RefundModel r) {
    final details = r.channelDetails!;
    return _infoCard(
      title: 'Channel Details',
      icon: Icons.account_balance_rounded,
      iconColor: Colors.teal,
      rows: details.entries
          .map((e) => _InfoRow(
              label: e.key.replaceAll('_', ' ').toUpperCase(),
              value: e.value?.toString() ?? '—'))
          .toList(),
    );
  }

  Widget _buildBookingClientCard(RefundModel r) {
    return _infoCard(
      title: 'Booking & Client',
      icon: Icons.person_pin_circle_outlined,
      iconColor: Colors.blue,
      rows: [
        _InfoRow(label: 'CLIENT', value: r.clientName ?? 'ID ${r.clientId}'),
        _InfoRow(
            label: 'BOOKING',
            value: r.bookingRef ?? 'BK-${r.bookingId}'),
        if (r.invoiceId != null)
          _InfoRow(label: 'INVOICE', value: 'INV-${r.invoiceId}'),
        if (r.receiptIds != null && r.receiptIds!.isNotEmpty)
          _InfoRow(
              label: 'RECEIPTS',
              value: r.receiptIds!.map((id) => 'RC-$id').join(', ')),
      ],
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_rounded, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notes',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade800)),
                const SizedBox(height: 4),
                Text(notes,
                    style: TextStyle(
                        fontSize: 13, color: Colors.amber.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(RefundModel r) {
    final steps = _buildTimelineSteps(r);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timeline_rounded,
                    size: 16, color: Colors.purple),
              ),
              const SizedBox(width: 10),
              Text('Approval History',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cPrimaryHeadingColor)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...steps,
        ],
      ),
    );
  }

  List<Widget> _buildTimelineSteps(RefundModel r) {
    final steps = <_TimelineStep>[];

    // Created
    steps.add(_TimelineStep(
      label: 'Created',
      detail: r.requestedByName != null ? 'By ${r.requestedByName}' : null,
      timestamp: r.createdOn,
      color: Colors.blue,
      isDone: true,
    ));

    // Pending Approval
    steps.add(_TimelineStep(
      label: 'Pending Approval',
      color: Colors.orange,
      isDone: r.status != 'DRAFT' && r.status != 'PENDING_APPROVAL',
      isActive: r.status == 'PENDING_APPROVAL',
    ));

    // Approved / Rejected
    if (r.status == 'REJECTED') {
      steps.add(_TimelineStep(
        label: 'Rejected',
        detail: r.approvedByName != null ? 'By ${r.approvedByName}' : null,
        timestamp: r.approvedAt,
        color: Colors.red,
        isDone: true,
      ));
    } else {
      steps.add(_TimelineStep(
        label: 'Approved',
        detail: r.approvedByName != null ? 'By ${r.approvedByName}' : null,
        timestamp: r.approvedAt,
        color: Colors.blue,
        isDone: r.approvedAt != null,
        isActive: r.status == 'APPROVED',
      ));
    }

    // Processing
    if (r.status != 'REJECTED') {
      steps.add(_TimelineStep(
        label: 'Processing',
        timestamp: r.processedAt,
        color: Colors.purple,
        isDone: r.processedAt != null,
        isActive: r.status == 'PROCESSING',
      ));

      // Completed
      steps.add(_TimelineStep(
        label: 'Completed',
        detail: () {
          final dd = r.dispatchDetails;
          if (dd == null) return null;
          final utr = dd['utr_number']?.toString();
          final date = dd['dispatch_date']?.toString();
          if (utr != null) return 'UTR: $utr';
          if (date != null) return 'Dispatch: $date';
          return null;
        }(),
        color: Colors.green,
        isDone: r.status == 'COMPLETED',
        isActive: r.status == 'COMPLETED',
      ));
    }

    return steps.asMap().entries.map((entry) {
      final idx = entry.key;
      final step = entry.value;
      final isLast = idx == steps.length - 1;
      return _buildTimelineItem(step, isLast: isLast);
    }).toList();
  }

  Widget _buildTimelineItem(_TimelineStep step, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + line
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isDone
                      ? step.color
                      : step.isActive
                          ? step.color.withValues(alpha: 0.3)
                          : Colors.grey.shade200,
                  border: step.isActive
                      ? Border.all(color: step.color, width: 2)
                      : null,
                ),
                child: step.isDone
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: step.isDone || step.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: step.isDone || step.isActive
                          ? AppColor.cPrimaryHeadingColor
                          : AppColor.fontColorGrey,
                    ),
                  ),
                  if (step.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(step.detail!,
                        style: TextStyle(
                            fontSize: 12, color: AppColor.fontColorGrey)),
                  ],
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(step.timestamp!),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ──────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, RefundModel r) {
    switch (r.status) {
      case 'PENDING_APPROVAL':
        return Row(
          children: [
            Expanded(
              child: _actionButton(
                label: 'Approve',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
                onTap: () =>
                    _showActionDialog(context, r, action: 'APPROVED'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                label: 'Reject',
                icon: Icons.cancel_outlined,
                color: Colors.red,
                onTap: () =>
                    _showActionDialog(context, r, action: 'REJECTED'),
              ),
            ),
          ],
        );

      case 'APPROVED':
        return _actionButton(
          label: 'Mark as Processing',
          icon: Icons.sync_rounded,
          color: Colors.purple,
          onTap: () async {
            await controller.updateRefundStatus(r.id, 'PROCESSING');
            controller.loadRefundById(r.id);
          },
        );

      case 'PROCESSING':
        return _actionButton(
          label: 'Mark as Completed',
          icon: Icons.task_alt_rounded,
          color: Colors.green,
          onTap: () => _showCompleteDialog(context, r),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Obx(() => SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isSubmitting.value ? null : onTap,
            icon: controller.isSubmitting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(icon, size: 18, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: color.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ));
  }

  // ── Action dialog (Approve / Reject) ────────────────────────────────────────

  void _showActionDialog(
    BuildContext context,
    RefundModel r, {
    required String action,
  }) {
    controller.actionNotesCtrl.clear();
    final isReject = action == 'REJECTED';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isReject ? Icons.cancel_outlined : Icons.check_circle_outline,
              color: isReject ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              isReject ? 'Reject Refund' : 'Approve Refund',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor),
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
                isReject
                    ? 'Please provide a reason for rejection.'
                    : 'Add optional notes before approving.',
                style: TextStyle(
                    fontSize: 13, color: AppColor.fontColorGrey),
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Notes',
                hint: isReject
                    ? 'Reason for rejection (required)'
                    : 'Optional approval notes',
                controller: controller.actionNotesCtrl,
                maxLines: 3,
                isMandatory: isReject,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isReject &&
                  controller.actionNotesCtrl.text.trim().isEmpty) {
                return;
              }
              Navigator.of(ctx).pop();
              await controller.updateRefundStatus(
                r.id,
                action,
                notes: controller.actionNotesCtrl.text.trim(),
              );
              controller.loadRefundById(r.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isReject ? Colors.red : Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isReject ? 'Reject' : 'Approve',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Complete dialog ─────────────────────────────────────────────────────────

  void _showCompleteDialog(BuildContext context, RefundModel r) {
    controller.dispatchUtrCtrl.clear();
    controller.dispatchDateCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.task_alt_rounded, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text(
              'Mark as Completed',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor),
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
                'Provide the UTR number or dispatch date to complete this refund.',
                style:
                    TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'UTR Number / Reference',
                hint: 'e.g. UTR123456789012',
                controller: controller.dispatchUtrCtrl,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                label: 'Dispatch / Settlement Date',
                hint: 'DD-MMM-YYYY',
                controller: controller.dispatchDateCtrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final dispatchDetails = <String, dynamic>{};
              final utr = controller.dispatchUtrCtrl.text.trim();
              final date = controller.dispatchDateCtrl.text.trim();
              if (utr.isNotEmpty) dispatchDetails['utr_number'] = utr;
              if (date.isNotEmpty) dispatchDetails['dispatch_date'] = date;

              await controller.updateRefundStatus(
                r.id,
                'COMPLETED',
                dispatchDetails:
                    dispatchDetails.isNotEmpty ? dispatchDetails : null,
              );
              controller.loadRefundById(r.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Complete Refund',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Reusable card builder ───────────────────────────────────────────────────

  Widget _infoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_InfoRow> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        row.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColor.fontColorGrey,
                            letterSpacing: 0.4),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColor.cPrimaryHeadingColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColor.fontColorGrey),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day.toString().padLeft(2, '0')}-${months[dt.month]}-${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Private data classes ──────────────────────────────────────────────────────

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}

class _TimelineStep {
  final String label;
  final String? detail;
  final String? timestamp;
  final Color color;
  final bool isDone;
  final bool isActive;

  const _TimelineStep({
    required this.label,
    this.detail,
    this.timestamp,
    required this.color,
    this.isDone = false,
    this.isActive = false,
  });
}
