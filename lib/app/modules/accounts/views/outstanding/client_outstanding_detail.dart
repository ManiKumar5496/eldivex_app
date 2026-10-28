import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../controllers/outstanding_controller.dart';
import '../../models/outstanding_balance_model.dart';
import '../../models/parse_utils.dart';
import '../../models/active_booking_client_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
      // Fresh figures on every visit (approvals elsewhere change them).
      runOncePerRoute(context, 'clientOutstanding', () {
        controller.loadClientOutstanding(clientId);
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
                  title: 'Client Outstanding',
                  subtitle: clientId > 0 ? clientName : null,
                  breadcrumbs: const ['Accounts', 'Receivables'],
                  onBack: () => HelperUi.safeBack(Routes.MAIN),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  // Read an observable on every path so Obx always subscribes.
                  final loading = controller.isLoading.value;
                  if (clientId <= 0) {
                    return recordNotFound(
                        title: 'Client',
                        onBack: () => HelperUi.safeBack(Routes.MAIN));
                  }
                  if (loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final loaded = controller.clientOutstanding.value;
                  final obs = loaded?.clientId == clientId ? loaded : null;
                  final error = controller.clientOutstandingError.value;
                  final bookings =
                      bookingRowsForUser(controller.activeClients, clientId);

                  // Not loaded yet (first frame) — never show a ₹0 balance.
                  if (obs == null && error == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (obs == null)
                        AppCard(
                          child: AppEmptyState(
                            icon: LucideIcons.circleAlert,
                            tone: AppTone.danger,
                            title: 'Balance unavailable',
                            message: error,
                            actionLabel: 'Retry',
                            actionIcon: LucideIcons.refreshCw,
                            onAction: () => controller.loadClientOutstanding(clientId),
                            compact: true,
                          ),
                        )
                      else ...[
                        _buildClientHeader(clientName, obs),
                        const SizedBox(height: 20),
                        _buildBreakdownCards(obs),
                      ],
                      const SizedBox(height: 20),
                      _buildQuickActions(clientId, clientName),
                      const SizedBox(height: 20),
                      _buildBookingTable(bookings),
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

  // ─── client header (large outstanding amount) ──────────────────────────────

  Widget _buildClientHeader(String clientName, OutstandingBalanceModel? obs) {
    final outstanding = obs?.outstandingAmount ?? 0.0;
    final isOwed      = outstanding > 0;

    final identity = Row(
      children: [
        AppAvatar(name: clientName, size: 48),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(clientName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary)),
              if (obs?.lastUpdated != null)
                Text('Last updated: ${obs!.lastUpdated}',
                    style: TextStyle(
                        fontSize: 12.5, color: AppColor.textTertiary)),
            ],
          ),
        ),
      ],
    );

    final amount = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Net Outstanding',
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
          label: isOwed ? 'Amount Owed' : 'No Balance Due',
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

  // ─── quick actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(int clientId, String clientName) {
    return AppCard(
      title: 'Quick Actions',
      subtitle: 'Adjust this client\'s balance',
      icon: LucideIcons.zap,
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(
              Routes.CREATE_CREDIT_NOTE,
              arguments: {'client_id': clientId, 'client_name': clientName},
            ),
            icon: Icon(LucideIcons.filePlus,
                size: 18, color: AppColor.cAppPrimaryColor),
            label: const Text('Issue Credit Note'),
          ),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(
              Routes.CREATE_WRITE_OFF,
              arguments: {'client_id': clientId, 'client_name': clientName},
            ),
            icon: Icon(LucideIcons.pencilOff,
                size: 18, color: AppColor.warning),
            label: const Text('Create Write-off'),
          ),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(
              Routes.CREATE_REFUND,
              arguments: {'client_id': clientId, 'client_name': clientName},
            ),
            icon: Icon(LucideIcons.arrowLeftRight,
                size: 18, color: AppColor.success),
            label: const Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  // ─── booking breakdown table ────────────────────────────────────────────────

  /// Per-booking rows for this client from getActiveClients
  /// (invoice totals vs approved receipts).
  Widget _buildBookingTable(List<dynamic> bookings) {
    return AppCard(
      title: 'Booking Breakdown',
      subtitle: 'Select a booking to open its ledger',
      icon: LucideIcons.calendarDays,
      padding: EdgeInsets.zero,
      child: bookings.isEmpty
          ? const AppEmptyState(
              icon: LucideIcons.calendar,
              title: 'No booking data available',
              compact: true,
            )
          : horizontalTable(DataTable(
              showCheckboxColumn: false,
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
                            color: AppColor.cAppPrimaryColor,
                            fontWeight: FontWeight.w600))),
                    DataCell(Text(service)),
                    DataCell(Text(_fmt(billed))),
                    DataCell(Text(_fmt(paid),
                        style: TextStyle(color: AppColor.success))),
                    DataCell(Text(
                      _fmt(outstanding),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: outstanding > 0 ? AppColor.danger : AppColor.success,
                      ),
                    )),
                  ],
                );
              }).toList(),
            )),
    );
  }

}
