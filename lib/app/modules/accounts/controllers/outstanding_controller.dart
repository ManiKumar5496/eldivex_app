import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../models/active_booking_client_model.dart';
import '../models/outstanding_balance_model.dart';
import '../models/parse_utils.dart';
import '../models/transaction_entry_model.dart';
import 'accounts_feedback.dart';

/// Per-client roll-up of getActiveClients booking rows.
class ClientReceivable {
  final ClientOption client;
  final double billed;
  final double paid;
  final double outstanding;

  const ClientReceivable({
    required this.client,
    required this.billed,
    required this.paid,
    required this.outstanding,
  });
}

class OutstandingController extends GetxController {
  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  var clientOutstanding  = Rxn<OutstandingBalanceModel>();
  var bookingOutstanding = Rxn<OutstandingBalanceModel>();

  var ledgerEntries = <TransactionEntryModel>[].obs;
  /// getActiveClients rows — one per booking (`id` = booking id, `user_id` = client).
  var activeClients = <dynamic>[].obs;

  /// Org-wide KPIs from GET /getCollectionsKPIs.
  final totalBilled      = 0.0.obs;
  final totalCollected   = 0.0.obs;
  final totalOutstanding = 0.0.obs;
  final collectionRate   = 0.obs;
  final overdueAmount    = 0.0.obs;

  /// Aging buckets from GET /getAgingReport.
  var agingBuckets = <AgingBucket>[].obs;

  var isLoading        = false.obs;
  var isLedgerLoading  = false.obs;
  var isSummaryLoading = false.obs;

  var ledgerTotal  = 0.obs;
  var ledgerOffset = 0.obs;
  static const int ledgerLimit = 50;

  var selectedClientId  = Rxn<int>();
  var selectedBookingId = Rxn<int>();

  /// Last ids requested by the detail screens, so they fetch once per record
  /// rather than on every rebuild.
  int? lastClientRequested;
  int? lastBookingRequested;

  // ─────────────────────────────────────────────
  // Text Controllers
  // ─────────────────────────────────────────────
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl   = TextEditingController();

  // ─────────────────────────────────────────────
  // Internals
  // ─────────────────────────────────────────────
  final ApiService _api = ApiService();

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  @override
  void onClose() {
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    super.onClose();
  }

  /// Reloads everything the dashboard shows.
  Future<void> refreshDashboard() async {
    await Future.wait([loadActiveClients(), loadSummary()]);
  }

  // ─────────────────────────────────────────────
  // Derived
  // ─────────────────────────────────────────────

  /// Unique clients (deduped by user_id) with billed / paid / outstanding
  /// summed across their bookings, optionally narrowed to [selectedClientId].
  List<ClientReceivable> get clientReceivables {
    final options = ClientOption.fromBookingRows(activeClients);
    final out = <ClientReceivable>[];
    for (final c in options) {
      if (selectedClientId.value != null && c.userId != selectedClientId.value) continue;
      final rows = bookingRowsForUser(activeClients, c.userId);
      out.add(ClientReceivable(
        client: c,
        billed: rows.fold(0.0, (s, r) => s + toDouble(field(r, 'total_billed'))),
        paid: rows.fold(0.0, (s, r) => s + toDouble(field(r, 'total_paid'))),
        outstanding: rows.fold(0.0, (s, r) => s + toDouble(field(r, 'outstanding_amount'))),
      ));
    }
    out.sort((a, b) => b.outstanding.compareTo(a.outstanding));
    return out;
  }

  // ─────────────────────────────────────────────
  // API Methods
  // ─────────────────────────────────────────────

  /// GET /api/getActiveClients — booking rows used for the client roll-up.
  Future<void> loadActiveClients() async {
    isLoading.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getActiveClients);
      if (isOkResponse(response)) {
        final data = response!.data;
        activeClients.value = data is List ? data : [];
      } else {
        toastApiError(response, 'Failed to load clients.');
      }
    } catch (e) {
      toastValidation('Error loading clients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /getCollectionsKPIs + /getAgingReport (org-wide, invoice based).
  Future<void> loadSummary() async {
    isSummaryLoading.value = true;
    try {
      final results = await Future.wait([
        _api.getRaw(ApiConstants.getCollectionsKPIs),
        _api.getRaw(ApiConstants.getAgingReport),
      ]);
      final kpi = results[0];
      if (isOkResponse(kpi)) {
        final d = kpi!.data;
        totalBilled.value      = toDouble(field(d, 'total_billed'));
        totalCollected.value   = toDouble(field(d, 'total_collected'));
        totalOutstanding.value = toDouble(field(d, 'total_outstanding'));
        collectionRate.value   = toInt(field(d, 'collection_rate'));
        overdueAmount.value    = toDouble(field(d, 'overdue_amount'));
      }
      final aging = results[1];
      if (isOkResponse(aging)) {
        final buckets = field(aging!.data, 'buckets');
        agingBuckets.value = buckets is Map
            ? buckets.values
                .whereType<Map>()
                .map((b) => AgingBucket.fromJson(Map<String, dynamic>.from(b)))
                .toList()
            : <AgingBucket>[];
      }
    } catch (e) {
      toastValidation('Error loading receivables summary: $e');
    } finally {
      isSummaryLoading.value = false;
    }
  }

  /// Loads outstanding balance summary for a given client (all bookings).
  Future<void> loadClientOutstanding(int clientId) async {
    lastClientRequested = clientId;
    isLoading.value = true;
    clientOutstanding.value = null;
    try {
      final response = await _api.getRaw(ApiConstants.getClientOutstanding(clientId));
      if (isOkResponse(response) && response!.data is Map) {
        clientOutstanding.value = OutstandingBalanceModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      } else {
        toastApiError(response, 'Failed to load client outstanding.');
      }
    } catch (e) {
      toastValidation('Error loading client outstanding: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads outstanding balance summary for a specific booking.
  Future<void> loadBookingOutstanding(int bookingId) async {
    lastBookingRequested = bookingId;
    isLoading.value = true;
    bookingOutstanding.value = null;
    try {
      final response = await _api.getRaw(ApiConstants.getBookingOutstanding(bookingId));
      if (isOkResponse(response) && response!.data is Map) {
        bookingOutstanding.value = OutstandingBalanceModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      } else {
        toastApiError(response, 'Failed to load booking outstanding.');
      }
    } catch (e) {
      toastValidation('Error loading booking outstanding: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads the transaction ledger
  /// (GET /transactionLedger?limit&offset&client_id&booking_id&from_date&to_date).
  ///
  /// When [reset] is true the list and offset are cleared before fetching
  /// (use for first load and filter changes). When [reset] is false the
  /// response is appended for pagination.
  Future<void> loadLedger({bool reset = true}) async {
    if (reset) {
      ledgerOffset.value = 0;
      ledgerEntries.clear();
    }

    isLedgerLoading.value = true;
    try {
      final params = <String>[
        'limit=$ledgerLimit',
        'offset=${ledgerOffset.value}',
      ];

      if (selectedClientId.value != null) {
        params.add('client_id=${selectedClientId.value}');
      }
      if (selectedBookingId.value != null) {
        params.add('booking_id=${selectedBookingId.value}');
      }
      if (fromDateCtrl.text.trim().isNotEmpty) {
        params.add('from_date=${fromDateCtrl.text.trim()}');
      }
      if (toDateCtrl.text.trim().isNotEmpty) {
        params.add('to_date=${toDateCtrl.text.trim()}');
      }

      final response =
          await _api.getRaw(ApiConstants.getTransactionLedger(params.join('&')));

      if (isOkResponse(response)) {
        final data = response!.data;
        List<dynamic> rows = [];
        int total = 0;

        if (data is Map) {
          final d = data['data'];
          rows  = d is List ? d : [];
          total = toInt(data['total'], rows.length);
        } else if (data is List) {
          rows  = data;
          total = rows.length;
        }

        final entries = TransactionEntryModel.fromJsonList(rows);

        if (reset) {
          ledgerEntries.value = entries;
        } else {
          ledgerEntries.addAll(entries);
        }

        ledgerTotal.value   = total;
        ledgerOffset.value += entries.length;
      } else {
        toastApiError(response, 'Failed to load ledger.');
      }
    } catch (e) {
      toastValidation('Error loading ledger: $e');
    } finally {
      isLedgerLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────

  /// Appends the next page of ledger entries.
  Future<void> loadNextPage() => loadLedger(reset: false);

  // ─────────────────────────────────────────────
  // Filter Helpers
  // ─────────────────────────────────────────────

  /// Re-fetches the dashboard data using the current filter values.
  Future<void> applyFilters() => refreshDashboard();

  /// Clears all filter fields and selected IDs, then reloads.
  Future<void> clearFilters() async {
    fromDateCtrl.clear();
    toDateCtrl.clear();
    selectedClientId.value  = null;
    selectedBookingId.value = null;
    clientOutstanding.value  = null;
    bookingOutstanding.value = null;
    await refreshDashboard();
  }
}
