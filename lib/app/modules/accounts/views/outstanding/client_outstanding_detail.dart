import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../controllers/outstanding_controller.dart';
import '../../models/outstanding_balance_model.dart';
import '../../models/parse_utils.dart';
import '../../models/active_booking_client_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../accounts_format.dart';

class ClientOutstandingDetail extends GetView<OutstandingController> {
  const ClientOutstandingDetail({super.key});

  // ─── helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) => formatInr(v);

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Arguments are lost on a browser refresh; ?client_id= survives.
    final args       = Get.arguments;
    final clientId   = toIntOrNull(field(args, 'client_id')) ??
        toInt(Get.parameters['client_id']);
    final clientName = toStrOrNull(field(args, 'client_name')) ?? 'Client #$clientId';

    if (clientId > 0) {
      if (controller.activeClients.isEmpty && !controller.isLoading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadActiveClients());
      }
      if (controller.lastClientRequested != clientId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadClientOutstanding(clientId);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => HelperUi.safeBack(Routes.MAIN),
        ),
        title: Text('Client Outstanding', style: AppTextStyles.semiBold18),
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
        if (clientId <= 0) {
          return recordNotFound(
              title: 'Client', onBack: () => HelperUi.safeBack(Routes.MAIN));
        }
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final loaded = controller.clientOutstanding.value;
        final obs = loaded?.clientId == clientId ? loaded : null;
        final bookings = bookingRowsForUser(controller.activeClients, clientId);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClientHeader(clientName, obs),
              const SizedBox(height: 20),
              if (obs != null) ...[
                _buildBreakdownCards(obs),
                const SizedBox(height: 20),
              ],
              _buildQuickActions(clientId, clientName),
              const SizedBox(height: 24),
              _buildBookingTable(bookings),
            ],
          ),
        );
      }),
    );
  }

  // ─── client header (large outstanding amount) ──────────────────────────────

  Widget _buildClientHeader(String clientName, OutstandingBalanceModel? obs) {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColor.cPrimaryButtonColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clientName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (obs?.lastUpdated != null)
                      Text('Last updated: ${obs!.lastUpdated}',
                          style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text('Net Outstanding',
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
                    isOwed ? 'Amount Owed' : 'No Balance Due',
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
            _summaryBox('Billed',        _fmt(obs.totalBilled),            Colors.blue),
            _summaryBox('Paid',          _fmt(obs.totalPaid),              Colors.green),
            _summaryBox('Write-off',     _fmt(obs.totalWriteOff),          Colors.orange),
            _summaryBox('Credit Applied', _fmt(obs.totalCreditNoteApplied), AppColor.cPrimaryButtonColor),
            _summaryBox('Refunded',      _fmt(obs.totalRefunded),          Colors.purple),
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

  // ─── quick actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(int clientId, String clientName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.semiBold16),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => Get.toNamed(
                Routes.CREATE_CREDIT_NOTE,
                arguments: {'client_id': clientId, 'client_name': clientName},
              ),
              icon: const Icon(Icons.note_add_outlined, size: 18),
              label: const Text('Issue Credit Note'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.cPrimaryButtonColor,
                side: BorderSide(color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Get.toNamed(
                Routes.CREATE_WRITE_OFF,
                arguments: {'client_id': clientId, 'client_name': clientName},
              ),
              icon: const Icon(Icons.edit_off_outlined, size: 18),
              label: const Text('Create Write-off'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Get.toNamed(
                Routes.CREATE_REFUND,
                arguments: {'client_id': clientId, 'client_name': clientName},
              ),
              icon: const Icon(Icons.currency_exchange_outlined, size: 18),
              label: const Text('Process Refund'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── booking breakdown table ────────────────────────────────────────────────

  /// Per-booking rows for this client from getActiveClients
  /// (invoice totals vs approved receipts).
  Widget _buildBookingTable(List<dynamic> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Booking Breakdown', style: AppTextStyles.semiBold18),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 48, color: AppColor.divColor),
                  const SizedBox(height: 12),
                  Text('No booking data available', style: AppTextStyles.regular16Gre),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.divColor),
            ),
            child: horizontalTable(DataTable(
                headingRowColor: WidgetStateProperty.all(AppColor.fieldColorGrey),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColor.cPrimaryHeadingColor,
                ),
                dataTextStyle: const TextStyle(fontSize: 13),
                columnSpacing: 28,
                horizontalMargin: 16,
                columns: const [
                  DataColumn(label: Text('Booking Ref')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Billed'),      numeric: true),
                  DataColumn(label: Text('Paid'),        numeric: true),
                  DataColumn(label: Text('Outstanding'), numeric: true),
                ],
                rows: bookings.map((b) {
                  final bookingId   = toInt(field(b, 'booking_id'), toInt(field(b, 'id')));
                  final ref         = 'Booking #$bookingId';
                  final service     = toStr(field(b, 'service_name'), '-');
                  final billed      = toDouble(field(b, 'total_billed'));
                  final paid        = toDouble(field(b, 'total_paid'));
                  final outstanding = toDoubleOrNull(field(b, 'outstanding_amount')) ?? (billed - paid);

                  return DataRow(
                    onSelectChanged: (_) => Get.toNamed(
                      Routes.BOOKING_OUTSTANDING,
                      arguments: {
                        'booking_id':  bookingId,
                        'booking_ref': ref,
                        'service':     service,
                      },
                      parameters: {'booking_id': '$bookingId'},
                    ),
                    cells: [
                      DataCell(Text(ref,
                          style: TextStyle(
                              color: AppColor.cPrimaryButtonColor,
                              fontWeight: FontWeight.w500))),
                      DataCell(Text(service)),
                      DataCell(Text(_fmt(billed),
                          style: TextStyle(color: AppColor.cPrimaryHeadingColor))),
                      DataCell(Text(_fmt(paid),
                          style: const TextStyle(color: Colors.green))),
                      DataCell(Text(
                        _fmt(outstanding),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: outstanding > 0 ? Colors.red : Colors.green,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              )),
          ),
      ],
    );
  }

}
