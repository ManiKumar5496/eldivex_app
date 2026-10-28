import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../controllers/internal_transfer_controller.dart';
import '../../models/internal_transfer_model.dart';
import '../../models/parse_utils.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
    // Arguments are lost on a browser refresh; the ?id= query survives.
    final transferId =
        toIntOrNull(Get.arguments) ?? toIntOrNull(Get.parameters['id']);

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

  String _formatType(String type) => humanizeLabel(type);

  String _formatDate(String? s) => formatAccDate(s, empty: '-');

  String _formatCurrency(double? v) => formatInr(v ?? 0);

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    final t = _transfer;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: t != null ? 'Transfer #IT-${t.id}' : 'Transfer Detail',
                  subtitle: t == null
                      ? null
                      : '${t.clientName ?? 'Client ${t.clientId}'} · ${_formatDate(t.createdOn)}',
                  breadcrumbs: const ['Accounts', 'Internal Transfers'],
                  onBack: () => HelperUi.safeBack(Routes.MAIN),
                  titleTrailing:
                      t == null ? null : AppStatusBadge.status(t.status),
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (t == null)
                  _buildNotFound()
                else
                  _responsiveColumns(
                    main: [
                      _buildHeaderCard(t),
                      _buildTransferVisualization(t),
                      _buildInfoCard(t),
                    ],
                    side: [
                      // Action buttons for pending transfers
                      if (t.status.toUpperCase() == 'PENDING_APPROVAL')
                        _buildActionButtons(t),
                      _buildTimeline(t),
                    ],
                  ),
              ],
            ),
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

  // ─────────────────────────────────────────────
  // Not found
  // ─────────────────────────────────────────────

  Widget _buildNotFound() {
    return recordNotFound(
        title: 'Transfer', onBack: () => HelperUi.safeBack(Routes.MAIN));
  }

  // ─────────────────────────────────────────────
  // Header card
  // ─────────────────────────────────────────────

  Widget _buildHeaderCard(InternalTransferModel t) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer amount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                // Amount (prominent)
                Text(
                  _formatCurrency(t.transferAmount),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.6,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'transferred from ${t.sourceBookingRef ?? '#${t.sourceBookingId}'} to ${t.targetBookingRef ?? '#${t.targetBookingId}'}',
                  style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _metaItem(LucideIcons.hash, 'IT-${t.id}'),
                    _metaItem(LucideIcons.calendar,
                        _formatDate(t.createdOn)),
                    // Client chip
                    if (t.clientName != null)
                      _metaItem(LucideIcons.user, t.clientName!),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const AppIconTile(icon: LucideIcons.arrowLeftRight, size: 44),
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String label) {
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

  // ─────────────────────────────────────────────
  // Transfer visualization
  // ─────────────────────────────────────────────

  Widget _buildTransferVisualization(InternalTransferModel t) {
    final source = _bookingCard(
      label: 'Source Booking',
      ref: t.sourceBookingRef ?? '#${t.sourceBookingId}',
      client: t.clientName,
      balanceBefore: t.sourceBookingBalance,
      balanceAfter: t.sourceBookingBalance != null
          ? t.sourceBookingBalance! + t.transferAmount
          : null,
      isSource: true,
    );
    final target = _bookingCard(
      label: 'Target Booking',
      ref: t.targetBookingRef ?? '#${t.targetBookingId}',
      client: t.clientName,
      balanceBefore: t.targetBookingBalance,
      balanceAfter: t.targetBookingBalance != null
          ? t.targetBookingBalance! - t.transferAmount
          : null,
      isSource: false,
    );

    return AppCard(
      title: 'Transfer Route',
      icon: LucideIcons.route,
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              source,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _arrow(t, LucideIcons.arrowDown),
              ),
              target,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: source),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _arrow(t, LucideIcons.arrowRight),
            ),
            Expanded(child: target),
          ],
        );
      }),
    );
  }

  Widget _arrow(InternalTransferModel t, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColor.cAppPrimaryColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          _formatCurrency(t.transferAmount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.cAppPrimaryColor,
          ),
        ),
      ],
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
    final tone = isSource ? AppTone.warning : AppTone.success;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusBadge(label: label, tone: tone, dense: true),
          const SizedBox(height: 10),
          Text(
            ref,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
          if (client != null) ...[
            const SizedBox(height: 2),
            Text(client,
                style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary)),
          ],
          if (balanceBefore != null) ...[
            Divider(height: 20, color: AppColor.borderSubtle),
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
          style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            color: highlight
                ? (amount > 0 ? AppColor.danger : AppColor.success)
                : AppColor.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Info card (type + reason + notes)
  // ─────────────────────────────────────────────

  Widget _buildInfoCard(InternalTransferModel t) {
    return AppCard(
      title: 'Transfer Information',
      icon: LucideIcons.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _infoGrid([
            AppInfoRow(label: 'Transfer Type', value: _formatType(t.transferType)),
            if (t.requestedByName != null)
              AppInfoRow(label: 'Requested By', value: t.requestedByName!),
            if (t.approvedByName != null)
              AppInfoRow(label: 'Actioned By', value: t.approvedByName!),
          ]),
          const SizedBox(height: 18),
          AppInfoRow(label: 'Reason', value: t.reason),
          if (t.notes != null && t.notes!.isNotEmpty) ...[
            const SizedBox(height: 18),
            AppInfoRow(label: 'Notes', value: t.notes!),
          ],
        ],
      ),
    );
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

  // ─────────────────────────────────────────────
  // Timeline
  // ─────────────────────────────────────────────

  Widget _buildTimeline(InternalTransferModel t) {
    final steps = <_TimelineStep>[];

    steps.add(_TimelineStep(
      icon: LucideIcons.circlePlus,
      tone: AppTone.info,
      title: 'Transfer Requested',
      subtitle: t.requestedByName != null
          ? 'By ${t.requestedByName}'
          : 'Transfer submitted for review',
      date: _formatDate(t.createdOn),
      done: true,
    ));

    final status = t.status.toUpperCase();

    if (status == 'PENDING_APPROVAL') {
      steps.add(const _TimelineStep(
        icon: LucideIcons.hourglass,
        tone: AppTone.warning,
        title: 'Awaiting Finance Head Approval',
        subtitle: 'Transfer is pending review',
        date: '',
        done: false,
      ));
    } else if (status == 'APPROVED' || status == 'COMPLETED') {
      steps.add(_TimelineStep(
        icon: LucideIcons.circleCheck,
        tone: AppTone.success,
        title: 'Approved',
        subtitle: t.approvedByName != null
            ? 'Approved by ${t.approvedByName}'
            : 'Transfer approved',
        date: _formatDate(t.approvedAt),
        done: true,
      ));
      steps.add(_TimelineStep(
        icon: LucideIcons.arrowLeftRight,
        tone: AppTone.success,
        title: 'Transfer Applied',
        subtitle: 'Balances updated on both bookings',
        date: _formatDate(t.approvedAt),
        done: true,
      ));
    } else if (status == 'REJECTED') {
      steps.add(_TimelineStep(
        icon: LucideIcons.circleX,
        tone: AppTone.danger,
        title: 'Rejected',
        subtitle: t.approvedByName != null
            ? 'Rejected by ${t.approvedByName}'
            : 'Transfer rejected',
        date: _formatDate(t.updatedOn),
        done: true,
      ));
    } else if (status == 'REVERSED') {
      steps.add(_TimelineStep(
        icon: LucideIcons.circleCheck,
        tone: AppTone.success,
        title: 'Approved',
        subtitle: t.approvedByName != null
            ? 'Approved by ${t.approvedByName}'
            : 'Transfer approved',
        date: _formatDate(t.approvedAt),
        done: true,
      ));
      steps.add(_TimelineStep(
        icon: LucideIcons.undo2,
        tone: AppTone.violet,
        title: 'Reversed',
        subtitle: t.reversalReason != null
            ? 'Reason: ${t.reversalReason}'
            : 'Transfer reversed',
        date: _formatDate(t.reversedAt),
        done: true,
      ));
    }

    return AppCard(
      title: 'Approval History',
      icon: LucideIcons.activity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final step = entry.value;
          final isLast = idx == steps.length - 1;
          return _buildTimelineStep(step, isLast: isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineStep(_TimelineStep step, {required bool isLast}) {
    final c = step.tone.color;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + connector
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: step.done ? step.tone.soft : AppColor.whiteColor,
                  shape: BoxShape.circle,
                  border: step.done
                      ? null
                      : Border.all(color: c.withValues(alpha: 0.6), width: 1.5),
                ),
                child: Icon(step.icon, size: 16, color: c),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColor.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: step.done
                          ? AppColor.textPrimary
                          : AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style:
                        TextStyle(fontSize: 13, color: AppColor.textTertiary),
                  ),
                  if (step.date.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.date,
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

  // ─────────────────────────────────────────────
  // Action buttons (PENDING_APPROVAL only)
  // ─────────────────────────────────────────────

  Widget _buildActionButtons(InternalTransferModel t) {
    return AppCard(
      title: 'Action Required',
      subtitle: 'This transfer is awaiting Finance Head approval.',
      icon: LucideIcons.clipboardClock,
      iconTone: AppTone.warning,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: ctrl.isSubmitting.value
                    ? null
                    : () => _showActionDialog(
                          transfer: t,
                          action: 'Approved',
                        ),
                icon: ctrl.isSubmitting.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: AppColor.cAppPrimaryColor, strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.check, size: 18),
                label: Text(
                    ctrl.isSubmitting.value ? 'Processing...' : 'Approve'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: ctrl.isSubmitting.value
                    ? null
                    : () => _showActionDialog(
                          transfer: t,
                          action: 'Rejected',
                        ),
                icon: const Icon(LucideIcons.x, size: 18),
                label: const Text('Reject'),
                style: AppButtonStyles.dangerOutlined,
              ),
            ],
          )),
    );
  }

  void _showActionDialog({
    required InternalTransferModel transfer,
    required String action,
  }) {
    final notesCtrl = TextEditingController();
    final isApprove = action == 'Approved';

    Get.dialog(
      AppDialog(
        title: isApprove ? 'Approve Transfer' : 'Reject Transfer',
        icon: isApprove ? LucideIcons.circleCheck : LucideIcons.circleX,
        tone: isApprove ? AppTone.success : AppTone.danger,
        maxWidth: 460,
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!isApprove && notesCtrl.text.trim().isEmpty) {
                HelperUi.showToast(
                    message: 'Please enter a reason for rejecting this transfer.',
                    backgroundColor: AppColor.danger);
                return;
              }
              Get.back();
              ctrl
                  .approveTransfer(transfer.id, action, notesCtrl.text.trim())
                  .then((_) => _resolveTransfer());
            },
            style: isApprove ? null : AppButtonStyles.danger,
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApprove
                  ? 'Approve IT-${transfer.id} of ${_formatCurrency(transfer.transferAmount)}?'
                  : 'Reject IT-${transfer.id} of ${_formatCurrency(transfer.transferAmount)}?',
              style: TextStyle(
                  fontSize: 14, height: 1.5, color: AppColor.textSecondary),
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: isApprove ? 'Approval Notes (optional)' : 'Rejection Reason',
                children: [
                  if (!isApprove)
                    TextSpan(
                        text: ' *', style: TextStyle(color: AppColor.danger)),
                ],
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
              decoration: InputDecoration(
                hintText: isApprove
                    ? 'Add any notes...'
                    : 'Explain why this transfer is rejected...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Timeline step data class
// ─────────────────────────────────────────────

class _TimelineStep {
  final IconData icon;
  final AppTone tone;
  final String title;
  final String subtitle;
  final String date;
  final bool done;

  const _TimelineStep({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.done,
  });
}
