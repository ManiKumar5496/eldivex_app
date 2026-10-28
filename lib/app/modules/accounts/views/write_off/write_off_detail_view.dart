import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/write_off_controller.dart';
import '../../models/parse_utils.dart';
import '../../models/write_off_model.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
    // Arguments are lost on a browser refresh; the ?id= query survives.
    final args = Get.arguments;
    writeOffId = toIntOrNull(field(args, 'write_off_id')) ??
        toInt(Get.parameters['id']);

    // Ensure list is loaded so we can find the record
    if (writeOffId > 0 && ctrl.writeOffs.isEmpty) {
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

  // ── Approve / Reject dialog ─────────────────────────────────────────────────

  void _showActionDialog(BuildContext context, String action) {
    final notesCtrl = ctrl.approvalNotesCtrl;
    notesCtrl.clear();

    final isApprove = action == 'Approved';
    final actionLabel = isApprove ? 'Approve' : 'Reject';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        title: '$actionLabel Write-off',
        subtitle: isApprove
            ? 'Add notes before approving this write-off.'
            : 'Please provide a reason for rejection.',
        icon: isApprove ? LucideIcons.circleCheck : LucideIcons.circleX,
        tone: isApprove ? AppTone.success : AppTone.danger,
        maxWidth: 460,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: ctrl.isSubmitting.value
                    ? null
                    : () async {
                        if (!isApprove && notesCtrl.text.trim().isEmpty) {
                          HelperUi.showToast(
                            message: 'Please provide a reason for rejection.',
                            backgroundColor: AppColor.warning,
                          );
                          return;
                        }
                        final ok = await ctrl.approveWriteOff(
                          writeOffId,
                          action,
                          notesCtrl.text.trim(),
                        );
                        if (ok) Get.back();
                      },
                style: isApprove ? null : AppButtonStyles.danger,
                child: ctrl.isSubmitting.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.cAppPrimaryColor),
                      )
                    : Text(actionLabel),
              )),
        ],
        child: TextField(
          controller: notesCtrl,
          maxLines: 3,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: InputDecoration(
            hintText: isApprove
                ? 'Notes (optional)'
                : 'Reason for rejection (required)',
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return _page(
            context,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final wo = _writeOff;

        if (writeOffId <= 0) {
          return _page(context,
              child: recordNotFound(
                  title: 'Write-off',
                  onBack: () => HelperUi.safeBack(Routes.MAIN)));
        }

        if (wo == null) {
          return _page(
            context,
            child: AppCard(
              child: AppEmptyState(
                icon: LucideIcons.searchX,
                title: 'Write-off #$writeOffId not found',
                actionLabel: 'Retry',
                actionIcon: LucideIcons.refreshCw,
                onAction: () => ctrl.loadWriteOffs(),
              ),
            ),
          );
        }

        final isPending = wo.status == 'Pending';

        return _page(
          context,
          wo: wo,
          child: _responsiveColumns(
            main: [
              // ── Header card ────────────────────────────────────────────────
              _summaryCard(wo),

              // ── Details card ───────────────────────────────────────────────
              AppCard(
                title: 'Details',
                icon: LucideIcons.info,
                iconTone: AppTone.info,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _infoGrid([
                      AppInfoRow(label: 'Booking ID', value: '#${wo.bookingId}'),
                      AppInfoRow(label: 'Client', value: wo.clientName),
                      AppInfoRow(label: 'Patient', value: wo.patientName),
                      AppInfoRow(label: 'Mobile', value: wo.clientMobile),
                      AppInfoRow(label: 'Service', value: wo.serviceName),
                      AppInfoRow(
                          label: 'Date',
                          value: formatAccDate(wo.writeOffDate ?? wo.createdOn)),
                      if (wo.approvalLevel != null)
                        AppInfoRow(
                            label: 'Approval Level', value: wo.approvalLevel!),
                    ]),
                    const SizedBox(height: 18),
                    AppInfoRow(label: 'Reason', value: wo.reason),
                    if (wo.remarks != null && wo.remarks!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      AppInfoRow(label: 'Remarks', value: wo.remarks!),
                    ],
                  ],
                ),
              ),
            ],
            side: [
              // ── Action buttons (Pending only) ──────────────────────────────
              if (isPending)
                AppCard(
                  title: 'Approval',
                  subtitle: 'This write-off is awaiting a decision.',
                  icon: LucideIcons.clipboardClock,
                  iconTone: AppTone.warning,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showActionDialog(context, 'Approved'),
                        icon: const Icon(LucideIcons.circleCheck, size: 18),
                        label: const Text('Approve'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _showActionDialog(context, 'Rejected'),
                        icon: const Icon(LucideIcons.circleX, size: 18),
                        label: const Text('Reject'),
                        style: AppButtonStyles.dangerOutlined,
                      ),
                    ],
                  ),
                ),

              // ── Approval history (status + approver) ───────────────────────
              _approvalTimeline(wo, isPending),
            ],
          ),
        );
      }),
    );
  }

  // ── Page frame ──────────────────────────────────────────────────────────────

  Widget _page(BuildContext context, {WriteOffModel? wo, required Widget child}) {
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
                title: wo != null ? 'Write-off #${wo.id}' : 'Write-off Details',
                subtitle: wo == null
                    ? null
                    : '${wo.clientName} · Booking #${wo.bookingId}',
                breadcrumbs: const ['Accounts', 'Write-offs'],
                onBack: () => HelperUi.safeBack(Routes.MAIN),
                titleTrailing:
                    wo == null ? null : AppStatusBadge.status(wo.status),
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

  Widget _summaryCard(WriteOffModel wo) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Write-off amount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatInr(wo.writeOffAmount),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: AppColor.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _idBadge('#${wo.id}'),
                    _typeBadge(wo.writeOffType.isNotEmpty
                        ? humanizeStatus(wo.writeOffType)
                        : 'Write-off'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const AppIconTile(
              icon: LucideIcons.banknoteX, tone: AppTone.warning, size: 44),
        ],
      ),
    );
  }

  Widget _approvalTimeline(WriteOffModel wo, bool isPending) {
    final decided = !isPending;
    final tone = toneForStatus(wo.status);
    return AppCard(
      title: 'Approval History',
      icon: LucideIcons.shieldCheck,
      iconTone: decided ? tone : AppTone.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _timelineItem(
            title: 'Requested',
            detail: wo.approvalLevel != null
                ? 'Approval level ${wo.approvalLevel}'
                : null,
            date: formatAccDate(wo.writeOffDate ?? wo.createdOn),
            tone: AppTone.info,
            done: true,
            isLast: false,
          ),
          if (isPending)
            _timelineItem(
              title: 'Awaiting approval',
              tone: AppTone.warning,
              done: false,
              isLast: true,
            )
          else
            // Approval info (shown when Approved/Rejected)
            _timelineItem(
              title: humanizeStatus(wo.status),
              detail: wo.approvedBy.isNotEmpty ? 'By ${wo.approvedBy}' : null,
              tone: tone,
              done: true,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    String? detail,
    String? date,
    required AppTone tone,
    required bool done,
    required bool isLast,
  }) {
    final c = tone.color;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? tone.soft : AppColor.whiteColor,
                  border: done ? null : Border.all(color: c, width: 2),
                ),
                child: done
                    ? Icon(LucideIcons.check, size: 14, color: c)
                    : Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration:
                              BoxDecoration(color: c, shape: BoxShape.circle),
                        ),
                      ),
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(detail,
                        style: TextStyle(
                            fontSize: 13, color: AppColor.textSecondary)),
                  ],
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(date,
                        style: TextStyle(
                            fontSize: 12.5, color: AppColor.textTertiary)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idBadge(String text) {
    return AppStatusBadge(
        label: text, tone: AppTone.primary, showDot: false, dense: true);
  }

  Widget _typeBadge(String type) {
    return AppStatusBadge(label: type, showDot: false, dense: true);
  }
}
