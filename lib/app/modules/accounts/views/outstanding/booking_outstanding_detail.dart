import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../controllers/outstanding_controller.dart';
import '../../models/outstanding_balance_model.dart';
import '../../models/transaction_entry_model.dart';
import '../../models/parse_utils.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class BookingOutstandingDetail extends GetView<OutstandingController> {
  const BookingOutstandingDetail({super.key});

  // ─── helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) => formatInr(v);

  String _formatDate(String? raw) => formatAccDate(raw, pattern: 'dd/MM/yyyy', empty: '-');

  AppTone _typeTone(String type) {
    switch (type.toUpperCase()) {
      case 'INVOICE':
        return AppTone.info;
      case 'PAYMENT':
        return AppTone.success;
      case 'CREDIT_NOTE':
        return AppTone.primary;
      case 'WRITE_OFF':
        return AppTone.warning;
      case 'REFUND':
        return AppTone.violet;
      case 'REVERSAL':
        return AppTone.danger;
      default:
        return AppTone.neutral;
    }
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Arguments are lost on a browser refresh; ?booking_id= survives.
    final args       = Get.arguments;
    final bookingId  = toIntOrNull(field(args, 'booking_id')) ??
        toInt(Get.parameters['booking_id']);
    final bookingRef = toStrOrNull(field(args, 'booking_ref')) ?? 'Booking #$bookingId';
    final service    = toStr(field(args, 'service'));

    if (bookingId > 0 && controller.lastBookingRequested != bookingId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The ledger is booking-scoped here; client/date filters don't apply.
        controller.selectedClientId.value = null;
        controller.fromDateCtrl.clear();
        controller.toDateCtrl.clear();
        controller.selectedBookingId.value = bookingId;
        controller.loadBookingOutstanding(bookingId);
        controller.loadLedger();
      });
    }

    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
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
                  title: 'Booking Outstanding',
                  subtitle: bookingId > 0
                      ? (service.isNotEmpty ? '$bookingRef · $service' : bookingRef)
                      : null,
                  breadcrumbs: const ['Accounts', 'Receivables'],
                  onBack: () => HelperUi.safeBack(Routes.MAIN),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  // Read an observable on every path so Obx always subscribes.
                  final loading = controller.isLoading.value;
                  if (bookingId <= 0) {
                    return recordNotFound(
                        title: 'Booking',
                        onBack: () => HelperUi.safeBack(Routes.MAIN));
                  }
                  if (loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final loaded = controller.bookingOutstanding.value;
                  final obs = loaded?.bookingId == bookingId ? loaded : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBookingHeader(bookingRef, service, obs),
                      const SizedBox(height: 20),
                      if (obs != null) ...[
                        _buildBreakdownCards(obs),
                        const SizedBox(height: 20),
                      ],
                      _buildLedgerSection(bookingId),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── booking header ────────────────────────────────────────────────────────

  Widget _buildBookingHeader(
      String bookingRef, String service, OutstandingBalanceModel? obs) {
    final outstanding = obs?.outstandingAmount ?? 0.0;
    final isOwed      = outstanding > 0;

    final identity = Row(
      children: [
        const AppIconTile(icon: LucideIcons.calendarDays, size: 48),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bookingRef,
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (service.isNotEmpty)
                Text(service,
                    style: TextStyle(
                        fontSize: 13, color: AppColor.textTertiary)),
            ],
          ),
        ),
      ],
    );

    final amount = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Outstanding Amount',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary)),
        const SizedBox(height: 4),
        Text(
          _fmt(outstanding),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: isOwed ? AppColor.danger : AppColor.success,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        AppStatusBadge(
          label: isOwed ? 'Amount Owed' : 'Fully Settled',
          tone: isOwed ? AppTone.danger : AppTone.success,
        ),
      ],
    );

    return AppCard(
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [identity, const SizedBox(height: 20), amount],
          );
        }
        return Row(
          children: [
            Expanded(child: identity),
            const SizedBox(width: 16),
            amount,
          ],
        );
      }),
    );
  }

  // ─── breakdown cards ───────────────────────────────────────────────────────

  Widget _buildBreakdownCards(OutstandingBalanceModel obs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(title: 'Breakdown'),
        const SizedBox(height: 12),
        AppResponsiveGrid(
          minItemWidth: 170,
          maxColumns: 3,
          children: [
            _summaryBox('Billed', _fmt(obs.totalBilled), AppTone.info,
                LucideIcons.receiptText),
            _summaryBox('Paid', _fmt(obs.totalPaid), AppTone.success,
                LucideIcons.banknote),
            _summaryBox('Write-off', _fmt(obs.totalWriteOff), AppTone.warning,
                LucideIcons.banknoteX),
            _summaryBox('Credit Applied', _fmt(obs.totalCreditNoteApplied),
                AppTone.primary, LucideIcons.notebookPen),
            _summaryBox('Refunded', _fmt(obs.totalRefunded), AppTone.violet,
                LucideIcons.arrowLeftRight),
            _summaryBox(
                'Net Outstanding',
                _fmt(obs.outstandingAmount),
                obs.outstandingAmount > 0 ? AppTone.danger : AppTone.success,
                LucideIcons.wallet),
          ],
        ),
      ],
    );
  }

  Widget _summaryBox(String label, String value, AppTone tone, IconData icon) {
    return AppStatCard(label: label, value: value, tone: tone, icon: icon);
  }

  // ─── transaction ledger ────────────────────────────────────────────────────

  Widget _buildLedgerSection(int bookingId) {
    return AppCard(
      title: 'Transaction Ledger',
      icon: LucideIcons.receiptText,
      padding: EdgeInsets.zero,
      actions: const [
        AppStatusBadge(label: 'Last 50 entries', showDot: false, dense: true),
      ],
      child: Obx(() {
        if (controller.isLedgerLoading.value && controller.ledgerEntries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final entries = controller.ledgerEntries;

        if (entries.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.receiptText,
            title: 'No transactions recorded',
            compact: true,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            horizontalTable(DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Dir')),
                DataColumn(label: Text('Amount'),          numeric: true),
                DataColumn(label: Text('Running Balance'), numeric: true),
                DataColumn(label: Text('Reference')),
                DataColumn(label: Text('Description')),
              ],
              rows: entries.map((e) => _ledgerRow(e)).toList(),
            )),
            Divider(height: 1, color: AppColor.borderSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _buildLoadMoreButton(),
            ),
          ],
        );
      }),
    );
  }

  DataRow _ledgerRow(TransactionEntryModel e) {
    final isDebit   = e.direction.toUpperCase() == 'DEBIT';
    final amtColor  = isDebit ? AppColor.danger : AppColor.success;
    final dirLabel  = isDebit ? '↑' : '↓';
    final balance   = e.runningBalanceBooking ?? e.runningBalanceClient ?? 0.0;

    return DataRow(cells: [
      DataCell(Text(_formatDate(e.createdOn))),
      DataCell(AppStatusBadge(
        label: humanizeLabel(e.transactionType),
        tone: _typeTone(e.transactionType),
        showDot: false,
        dense: true,
      )),
      DataCell(Text(
        dirLabel,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: amtColor,
        ),
      )),
      DataCell(Text(
        _fmt(e.amount),
        style: TextStyle(fontWeight: FontWeight.w600, color: amtColor),
      )),
      DataCell(Text(
        _fmt(balance),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: balance > 0 ? AppColor.danger : AppColor.success,
        ),
      )),
      DataCell(Text(
        e.referenceType != null && e.referenceId != null
            ? '${e.referenceType} #${e.referenceId}'
            : '-',
        style: TextStyle(color: AppColor.cAppPrimaryColor),
      )),
      DataCell(SizedBox(
        width: 220,
        child: Text(
          e.description ?? '-',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColor.textSecondary),
        ),
      )),
    ]);
  }

  Widget _buildLoadMoreButton() {
    return Obx(() {
      final hasMore = controller.ledgerTotal.value >
          controller.ledgerOffset.value;

      if (!hasMore) {
        return Center(
          child: Text(
            'All entries loaded',
            style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
          ),
        );
      }

      return Center(
        child: OutlinedButton.icon(
          onPressed: controller.isLedgerLoading.value
              ? null
              : controller.loadNextPage,
          icon: controller.isLedgerLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.chevronDown, size: 18),
          label: Text(controller.isLedgerLoading.value ? 'Loading...' : 'Load More'),
        ),
      );
    });
  }
}
