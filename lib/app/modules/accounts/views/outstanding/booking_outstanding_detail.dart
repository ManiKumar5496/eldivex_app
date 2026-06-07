import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../controllers/outstanding_controller.dart';
import '../../models/outstanding_balance_model.dart';
import '../../models/transaction_entry_model.dart';

class BookingOutstandingDetail extends GetView<OutstandingController> {
  const BookingOutstandingDetail({super.key});

  // ─── helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) => '₹${v.toStringAsFixed(2)}';

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'INVOICE':
        return Colors.blue;
      case 'PAYMENT':
        return Colors.green;
      case 'CREDIT_NOTE':
        return AppColor.cPrimaryButtonColor;
      case 'WRITE_OFF':
        return Colors.orange;
      case 'REFUND':
        return Colors.purple;
      case 'REVERSAL':
        return Colors.red.shade800;
      default:
        return AppColor.fontColorGrey;
    }
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final args       = Get.arguments as Map<String, dynamic>? ?? {};
    final bookingId  = (args['booking_id']  as num?)?.toInt() ?? 0;
    final bookingRef = args['booking_ref']?.toString() ?? 'Bkg #$bookingId';
    final service    = args['service']?.toString() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedBookingId.value = bookingId;
      controller.loadBookingOutstanding(bookingId);
      controller.loadLedger();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Outstanding', style: AppTextStyles.semiBold18),
        centerTitle: false,
        backgroundColor: AppColor.whiteColor,
        foregroundColor: AppColor.cPrimaryHeadingColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColor.divColor),
        ),
      ),
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final obs = controller.bookingOutstanding.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookingHeader(bookingRef, service, obs),
              const SizedBox(height: 20),
              if (obs != null) ...[
                _buildBreakdownCards(obs),
                const SizedBox(height: 24),
              ],
              _buildLedgerSection(bookingId),
            ],
          ),
        );
      }),
    );
  }

  // ─── booking header ────────────────────────────────────────────────────────

  Widget _buildBookingHeader(
      String bookingRef, String service, OutstandingBalanceModel? obs) {
    final outstanding = obs?.outstandingAmount ?? 0.0;
    final isOwed      = outstanding > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bookingRef,
                  style: TextStyle(
                    color: AppColor.cPrimaryButtonColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (service.isNotEmpty) ...[
                const SizedBox(width: 10),
                Text(service,
                    style: TextStyle(fontSize: 14, color: AppColor.fontColorGrey)),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text('Outstanding Amount',
                    style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
                const SizedBox(height: 6),
                Text(
                  _fmt(outstanding),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: isOwed ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOwed ? Colors.red : Colors.green).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOwed ? 'Amount Owed' : 'Fully Settled',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOwed ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── breakdown cards ───────────────────────────────────────────────────────

  Widget _buildBreakdownCards(OutstandingBalanceModel obs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Breakdown', style: AppTextStyles.semiBold16),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _summaryBox('Billed',          _fmt(obs.totalBilled),            Colors.blue),
            _summaryBox('Paid',            _fmt(obs.totalPaid),              Colors.green),
            _summaryBox('Write-off',       _fmt(obs.totalWriteOff),          Colors.orange),
            _summaryBox('Credit Applied',  _fmt(obs.totalCreditNoteApplied), AppColor.cPrimaryButtonColor),
            _summaryBox('Refunded',        _fmt(obs.totalRefunded),          Colors.purple),
            _summaryBox('Net Outstanding', _fmt(obs.outstandingAmount),
                obs.outstandingAmount > 0 ? Colors.red : Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _summaryBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppColor.fontColorGrey)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ─── transaction ledger ────────────────────────────────────────────────────

  Widget _buildLedgerSection(int bookingId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Transaction Ledger', style: AppTextStyles.semiBold18),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.fontColorGrey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Last 50 entries',
                style: TextStyle(fontSize: 11, color: AppColor.fontColorGrey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 56, color: AppColor.divColor),
                    const SizedBox(height: 12),
                    Text('No transactions recorded', style: AppTextStyles.regular16Gre),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
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
                      fontSize: 13,
                      color: AppColor.cPrimaryHeadingColor,
                    ),
                    dataTextStyle: const TextStyle(fontSize: 13),
                    columnSpacing: 22,
                    horizontalMargin: 16,
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
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLoadMoreButton(),
            ],
          );
        }),
      ],
    );
  }

  DataRow _ledgerRow(TransactionEntryModel e) {
    final isDebit   = e.direction.toUpperCase() == 'DEBIT';
    final amtColor  = isDebit ? Colors.red : Colors.green;
    final dirLabel  = isDebit ? '↑' : '↓';
    final balance   = e.runningBalanceBooking ?? e.runningBalanceClient ?? 0.0;
    final typeColor = _typeColor(e.transactionType);

    return DataRow(cells: [
      DataCell(Text(_formatDate(e.createdOn))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          e.transactionType.replaceAll('_', ' '),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: typeColor,
          ),
        ),
      )),
      DataCell(Text(
        dirLabel,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
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
          color: balance > 0 ? Colors.red : Colors.green,
        ),
      )),
      DataCell(Text(
        e.referenceType != null && e.referenceId != null
            ? '${e.referenceType} #${e.referenceId}'
            : '-',
        style: TextStyle(fontSize: 12, color: AppColor.cPrimaryButtonColor),
      )),
      DataCell(SizedBox(
        width: 220,
        child: Text(
          e.description ?? '-',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
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
            style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey),
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
              : const Icon(Icons.expand_more, size: 18),
          label: Text(controller.isLedgerLoading.value ? 'Loading...' : 'Load More'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      );
    });
  }
}
