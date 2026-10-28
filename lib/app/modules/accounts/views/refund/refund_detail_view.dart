import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/refund_controller.dart';
import '../../models/parse_utils.dart';
import '../../models/refund_model.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class RefundDetailView extends GetView<RefundController> {
  const RefundDetailView({super.key});

  // ── Route argument ──────────────────────────────────────────────────────────

  int get _refundId {
    // Arguments are lost on a browser refresh; the ?id= query survives.
    return toIntOrNull(Get.arguments) ?? toInt(Get.parameters['id']);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Trigger load on first paint
    final refundId = _refundId;
    if (refundId > 0 && controller.lastRequestedRefundId != refundId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadRefundById(refundId);
      });
    }

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Obx(() {
        // Read an observable on every path so Obx always subscribes.
        final loading = controller.isLoading.value;
        if (refundId <= 0) {
          return _page(context,
              child: recordNotFound(
                  title: 'Refund',
                  onBack: () => HelperUi.safeBack(Routes.MAIN)));
        }
        if (loading) {
          return _page(context,
              child: const SizedBox(height: 380, child: ShimmerLoader.table()));
        }

        final loaded = controller.selectedRefund.value;
        final refund = loaded?.id == refundId ? loaded : null;
        if (refund == null) {
          return _page(
            context,
            child: AppCard(
              child: AppEmptyState(
                icon: LucideIcons.receiptText,
                title: 'Refund not found',
                actionLabel: 'Retry',
                actionIcon: LucideIcons.refreshCw,
                onAction: () => controller.loadRefundById(_refundId),
              ),
            ),
          );
        }

        final actions = _buildActionButtons(context, refund);
        return _page(
          context,
          refund: refund,
          child: _responsiveColumns(
            main: [
              // ── Header card ──────────────────────────────────────────────
              _buildHeaderCard(refund),

              // ── Channel details ──────────────────────────────────────────
              if (refund.channelDetails != null &&
                  refund.channelDetails!.isNotEmpty)
                _buildChannelCard(refund),

              // ── Booking & Client ─────────────────────────────────────────
              _buildBookingClientCard(refund),

              // ── Notes ────────────────────────────────────────────────────
              if (refund.notes != null && refund.notes!.isNotEmpty)
                _buildNotesCard(refund.notes!),
            ],
            side: [
              // ── Action buttons ───────────────────────────────────────────
              if (actions != null) actions,

              // ── Timeline / Approval history ──────────────────────────────
              _buildTimelineCard(refund),
            ],
          ),
        );
      }),
    );
  }

  // ── Page frame ──────────────────────────────────────────────────────────────

  Widget _page(BuildContext context, {RefundModel? refund, required Widget child}) {
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: refund != null ? 'Refund REF-${refund.id}' : 'Refund Detail',
                subtitle: refund == null
                    ? null
                    : '${refund.clientName ?? 'ID ${refund.clientId}'} · ${refund.bookingRef ?? 'BK-${refund.bookingId}'}',
                breadcrumbs: const ['Accounts', 'Refunds'],
                onBack: () => HelperUi.safeBack(Routes.MAIN),
                titleTrailing:
                    refund == null ? null : AppStatusBadge.status(refund.status),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// Main + side columns on desktop, a single column below 900px.
  Widget _responsiveColumns({
    required List<Widget> main,
    required List<Widget> side,
  }) {
    List<Widget> gap(List<Widget> items) => [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            items[i],
          ],
        ];
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 900) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: gap([main.first, ...side, ...main.skip(1)]),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: gap(main),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: gap(side),
            ),
          ),
        ],
      );
    });
  }

  Widget _infoGrid(List<Widget> items) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 520 ? 2 : 1;
      final w = (c.maxWidth - 24 * (cols - 1)) / cols;
      return Wrap(
        spacing: 24,
        runSpacing: 18,
        children: [for (final i in items) SizedBox(width: w, child: i)],
      );
    });
  }

  // ── Cards ───────────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(RefundModel r) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount + reason
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund amount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Prominent amount
                    Text(
                      formatInr(r.refundAmount),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: AppColor.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      humanizeLabel(r.refundReason),
                      style: TextStyle(
                          fontSize: 13, color: AppColor.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const AppIconTile(
                  icon: LucideIcons.arrowLeftRight,
                  tone: AppTone.danger,
                  size: 44),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 14),
          // Meta row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _metaChip(LucideIcons.landmark,
                  'via ${r.refundChannel.replaceAll('_', ' ')}'),
              if (r.approvalLevel != null)
                _metaChip(LucideIcons.shield, 'Level: ${r.approvalLevel}'),
              _metaChip(LucideIcons.calendar,
                  r.createdOn != null ? _formatDate(r.createdOn!) : '—'),
              if (r.requestedByName != null)
                _metaChip(
                    LucideIcons.user, 'By ${r.requestedByName}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelCard(RefundModel r) {
    final details = r.channelDetails!;
    return AppCard(
      title: 'Channel Details',
      icon: LucideIcons.landmark,
      iconTone: AppTone.info,
      child: _infoGrid(details.entries
          .map((e) => AppInfoRow(
              label: humanizeLabel(e.key),
              value: e.value?.toString() ?? '—'))
          .toList()),
    );
  }

  Widget _buildBookingClientCard(RefundModel r) {
    return AppCard(
      title: 'Booking & Client',
      icon: LucideIcons.mapPinned,
      child: _infoGrid([
        AppInfoRow(label: 'Client', value: r.clientName ?? 'ID ${r.clientId}'),
        AppInfoRow(label: 'Booking', value: r.bookingRef ?? 'BK-${r.bookingId}'),
        if (r.invoiceId != null)
          AppInfoRow(label: 'Invoice', value: 'INV-${r.invoiceId}'),
        if (r.receiptIds != null && r.receiptIds!.isNotEmpty)
          AppInfoRow(
              label: 'Receipts',
              value: r.receiptIds!.map((id) => 'Receipt #$id').join(', ')),
      ]),
    );
  }

  Widget _buildNotesCard(String notes) {
    return AppCard(
      title: 'Notes',
      icon: LucideIcons.notepadText,
      iconTone: AppTone.warning,
      child: Text(notes,
          style: TextStyle(
              fontSize: 14, height: 1.5, color: AppColor.textSecondary)),
    );
  }

  Widget _buildTimelineCard(RefundModel r) {
    final steps = _buildTimelineSteps(r);
    return AppCard(
      title: 'Approval History',
      icon: LucideIcons.activity,
      iconTone: AppTone.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: steps,
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
      tone: AppTone.info,
      isDone: true,
    ));

    // Pending Approval
    steps.add(_TimelineStep(
      label: 'Pending Approval',
      tone: AppTone.warning,
      isDone: r.status != 'DRAFT' && r.status != 'PENDING_APPROVAL',
      isActive: r.status == 'PENDING_APPROVAL',
    ));

    // Approved / Rejected
    if (r.status == 'REJECTED') {
      steps.add(_TimelineStep(
        label: 'Rejected',
        detail: r.approvedByName != null ? 'By ${r.approvedByName}' : null,
        timestamp: r.approvedAt,
        tone: AppTone.danger,
        isDone: true,
      ));
    } else {
      steps.add(_TimelineStep(
        label: 'Approved',
        detail: r.approvedByName != null ? 'By ${r.approvedByName}' : null,
        timestamp: r.approvedAt,
        tone: AppTone.info,
        isDone: r.approvedAt != null,
        isActive: r.status == 'APPROVED',
      ));
    }

    // Processing
    if (r.status != 'REJECTED') {
      steps.add(_TimelineStep(
        label: 'Processing',
        timestamp: r.processedAt,
        tone: AppTone.violet,
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
        tone: AppTone.success,
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
    final c = step.tone.color;
    final reached = step.isDone || step.isActive;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + line
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isDone ? step.tone.soft : AppColor.whiteColor,
                  border: step.isDone
                      ? null
                      : Border.all(
                          color: step.isActive ? c : AppColor.borderStrong,
                          width: step.isActive ? 2 : 1.5),
                ),
                child: step.isDone
                    ? Icon(LucideIcons.check, size: 14, color: c)
                    : step.isActive
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: c, shape: BoxShape.circle),
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.isDone
                        ? c.withValues(alpha: 0.35)
                        : AppColor.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
                      color: reached
                          ? AppColor.textPrimary
                          : AppColor.textTertiary,
                    ),
                  ),
                  if (step.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(step.detail!,
                        style: TextStyle(
                            fontSize: 13, color: AppColor.textSecondary)),
                  ],
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(step.timestamp!),
                      style: TextStyle(
                          fontSize: 12.5, color: AppColor.textTertiary),
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

  Widget? _buildActionButtons(BuildContext context, RefundModel r) {
    switch (r.status) {
      case 'PENDING_APPROVAL':
        return AppCard(
          title: 'Approval',
          subtitle: 'This refund is awaiting a decision.',
          icon: LucideIcons.clipboardClock,
          iconTone: AppTone.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _actionButton(
                label: 'Approve',
                icon: LucideIcons.circleCheck,
                onTap: () =>
                    _showActionDialog(context, r, action: 'Approved'),
              ),
              const SizedBox(height: 8),
              _actionButton(
                label: 'Reject',
                icon: LucideIcons.circleX,
                destructive: true,
                onTap: () =>
                    _showActionDialog(context, r, action: 'Rejected'),
              ),
            ],
          ),
        );

      case 'APPROVED':
        return AppCard(
          title: 'Next step',
          subtitle: 'Approved. Start the payout when ready.',
          icon: LucideIcons.refreshCw,
          iconTone: AppTone.violet,
          child: _actionButton(
            label: 'Mark as Processing',
            icon: LucideIcons.refreshCw,
            onTap: () async {
              final ok = await controller.updateRefundStatus(r.id, 'Processing');
              if (ok) controller.loadRefundById(r.id);
            },
          ),
        );

      case 'PROCESSING':
        return AppCard(
          title: 'Next step',
          subtitle: 'Record the UTR or dispatch date to close this refund.',
          icon: LucideIcons.circleCheckBig,
          iconTone: AppTone.success,
          child: _actionButton(
            label: 'Mark as Completed',
            icon: LucideIcons.circleCheckBig,
            onTap: () => _showCompleteDialog(context, r),
          ),
        );

      default:
        return null;
    }
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    bool destructive = false,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final busy = controller.isSubmitting.value;
      final iconWidget = busy
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColor.cAppPrimaryColor),
            )
          : Icon(icon, size: 18);
      if (destructive) {
        return OutlinedButton.icon(
          onPressed: busy ? null : onTap,
          icon: iconWidget,
          label: Text(label),
          style: AppButtonStyles.dangerOutlined,
        );
      }
      return ElevatedButton.icon(
        onPressed: busy ? null : onTap,
        icon: iconWidget,
        label: Text(label),
      );
    });
  }

  // ── Action dialog (Approve / Reject) ────────────────────────────────────────

  void _showActionDialog(
    BuildContext context,
    RefundModel r, {
    required String action,
  }) {
    controller.actionNotesCtrl.clear();
    final isReject = action == 'Rejected';

    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: isReject ? 'Reject Refund' : 'Approve Refund',
        subtitle: isReject
            ? 'Please provide a reason for rejection.'
            : 'Add optional notes before approving.',
        icon: isReject ? LucideIcons.circleX : LucideIcons.circleCheck,
        tone: isReject ? AppTone.danger : AppTone.success,
        maxWidth: 460,
        onClose: () => Navigator.of(ctx).pop(),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isReject &&
                  controller.actionNotesCtrl.text.trim().isEmpty) {
                HelperUi.showToast(
                    message: 'Please enter a reason for rejecting this refund.',
                    backgroundColor: AppColor.danger);
                return;
              }
              Navigator.of(ctx).pop();
              final ok = await controller.updateRefundStatus(
                r.id,
                action,
                notes: controller.actionNotesCtrl.text.trim(),
              );
              if (ok) controller.loadRefundById(r.id);
            },
            style: isReject ? AppButtonStyles.danger : null,
            child: Text(isReject ? 'Reject' : 'Approve'),
          ),
        ],
        child: _labeledField(
          label: 'Notes',
          hint: isReject
              ? 'Reason for rejection (required)'
              : 'Optional approval notes',
          controller: controller.actionNotesCtrl,
          maxLines: 3,
          isMandatory: isReject,
        ),
      ),
    );
  }

  // ── Complete dialog ─────────────────────────────────────────────────────────

  void _showCompleteDialog(BuildContext context, RefundModel r) {
    controller.dispatchUtrCtrl.clear();
    controller.dispatchDateCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: 'Mark as Completed',
        subtitle:
            'Provide the UTR number or dispatch date to complete this refund.',
        icon: LucideIcons.circleCheckBig,
        tone: AppTone.success,
        maxWidth: 460,
        onClose: () => Navigator.of(ctx).pop(),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final utr = controller.dispatchUtrCtrl.text.trim();
              final date = controller.dispatchDateCtrl.text.trim();
              if (utr.isEmpty && date.isEmpty) {
                HelperUi.showToast(
                    message: 'Enter the UTR number or the dispatch date to complete the refund.',
                    backgroundColor: AppColor.danger);
                return;
              }
              Navigator.of(ctx).pop();
              final dispatchDetails = <String, dynamic>{};
              if (utr.isNotEmpty) dispatchDetails['utr_number'] = utr;
              if (date.isNotEmpty) dispatchDetails['dispatch_date'] = date;

              final ok = await controller.updateRefundStatus(
                r.id,
                'Completed',
                dispatchDetails:
                    dispatchDetails.isNotEmpty ? dispatchDetails : null,
              );
              if (ok) controller.loadRefundById(r.id);
            },
            child: const Text('Complete Refund'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _labeledField(
              label: 'UTR Number / Reference',
              hint: 'e.g. UTR123456789012',
              controller: controller.dispatchUtrCtrl,
            ),
            const SizedBox(height: 16),
            _labeledField(
              label: 'Dispatch / Settlement Date',
              hint: 'DD-MMM-YYYY',
              controller: controller.dispatchDateCtrl,
            ),
          ],
        ),
      ),
    );
  }

  // ── Small pieces ────────────────────────────────────────────────────────────

  /// Label above a theme-styled text field.
  Widget _labeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    bool isMandatory = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(text: label, children: [
            if (isMandatory)
              TextSpan(text: ' *', style: TextStyle(color: AppColor.danger)),
          ]),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColor.textTertiary),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 13, color: AppColor.textSecondary)),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatDate(String raw) =>
      formatAccDate(raw, pattern: 'dd-MMM-yyyy', empty: raw);
}

// ── Private data classes ──────────────────────────────────────────────────────

class _TimelineStep {
  final String label;
  final String? detail;
  final String? timestamp;
  final AppTone tone;
  final bool isDone;
  final bool isActive;

  const _TimelineStep({
    required this.label,
    this.detail,
    this.timestamp,
    required this.tone,
    this.isDone = false,
    this.isActive = false,
  });
}
