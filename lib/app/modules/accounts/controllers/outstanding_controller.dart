import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/outstanding_balance_model.dart';
import '../models/transaction_entry_model.dart';

class OutstandingController extends GetxController {
  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  var clientOutstanding  = Rxn<OutstandingBalanceModel>();
  var bookingOutstanding = Rxn<OutstandingBalanceModel>();

  var ledgerEntries = <TransactionEntryModel>[].obs;
  var activeClients = <dynamic>[].obs;

  var isLoading        = false.obs;
  var isLedgerLoading  = false.obs;

  var ledgerTotal  = 0.obs;
  var ledgerOffset = 0.obs;
  static const int ledgerLimit = 50;

  var selectedClientId  = Rxn<int>();
  var selectedBookingId = Rxn<int>();

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
    loadActiveClients();
    loadLedger();
  }

  @override
  void onClose() {
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // API Methods
  // ─────────────────────────────────────────────

  /// Fetches the list of all active clients for the filter dropdown.
  Future<void> loadActiveClients() async {
    isLoading.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getActiveClients);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        activeClients.value = data is List ? data : [];
      } else {
        HelperUi.showToast(message: 'Failed to load clients.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading clients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads outstanding balance summary for a given client (all bookings).
  Future<void> loadClientOutstanding(int clientId) async {
    isLoading.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getClientOutstanding(clientId));
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          clientOutstanding.value = OutstandingBalanceModel.fromJson(data);
        } else {
          clientOutstanding.value = null;
        }
      } else {
        HelperUi.showToast(message: 'Failed to load client outstanding.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading client outstanding: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads outstanding balance summary for a specific booking.
  Future<void> loadBookingOutstanding(int bookingId) async {
    isLoading.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getBookingOutstanding(bookingId));
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          bookingOutstanding.value = OutstandingBalanceModel.fromJson(data);
        } else {
          bookingOutstanding.value = null;
        }
      } else {
        HelperUi.showToast(message: 'Failed to load booking outstanding.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading booking outstanding: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads the transaction ledger.
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
        params.add('from=${fromDateCtrl.text.trim()}');
      }
      if (toDateCtrl.text.trim().isNotEmpty) {
        params.add('to=${toDateCtrl.text.trim()}');
      }

      final url = '${ApiConstants.getTransactionLedger('')}?${params.join('&')}';
      final response = await _api.getRaw(url);

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        List<dynamic> rows = [];
        int total = 0;

        if (data is Map<String, dynamic>) {
          rows  = data['data'] as List<dynamic>? ?? [];
          total = (data['total'] as num?)?.toInt() ?? rows.length;
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
        HelperUi.showToast(message: 'Failed to load ledger.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading ledger: $e');
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

  /// Re-fetches the ledger from the beginning using the current filter values.
  Future<void> applyFilters() => loadLedger(reset: true);

  /// Clears all filter fields and selected IDs, then reloads the ledger.
  Future<void> clearFilters() async {
    fromDateCtrl.clear();
    toDateCtrl.clear();
    selectedClientId.value  = null;
    selectedBookingId.value = null;
    clientOutstanding.value  = null;
    bookingOutstanding.value = null;
    await loadLedger(reset: true);
  }
}
