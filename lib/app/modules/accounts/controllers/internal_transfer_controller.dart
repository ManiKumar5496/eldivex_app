import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/internal_transfer_model.dart';
import '../models/outstanding_balance_model.dart';

class InternalTransferController extends GetxController {
  // ─────────────────────────────────────────────
  // Observable State
  // ─────────────────────────────────────────────
  var transfers             = <InternalTransferModel>[].obs;
  var selectedTransfer      = Rxn<InternalTransferModel>();
  var activeClients         = <dynamic>[].obs;
  var clientBookings        = <dynamic>[].obs;
  var sourceBookingOutstanding = Rxn<OutstandingBalanceModel>();
  var targetBookingOutstanding = Rxn<OutstandingBalanceModel>();
  var isLoading             = false.obs;
  var isSubmitting          = false.obs;
  var selectedClientId      = Rxn<int>();
  var selectedSourceBookingId = Rxn<int>();
  var selectedTargetBookingId = Rxn<int>();
  var transferType          = 'OVERPAYMENT_TRANSFER'.obs;

  // ─────────────────────────────────────────────
  // Text Editing Controllers
  // ─────────────────────────────────────────────
  final TextEditingController transferAmountCtrl = TextEditingController();
  final TextEditingController reasonCtrl         = TextEditingController();
  final TextEditingController notesCtrl          = TextEditingController();
  final TextEditingController approvalNotesCtrl  = TextEditingController();

  // ─────────────────────────────────────────────
  // Private
  // ─────────────────────────────────────────────
  final ApiService _api = ApiService();

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadTransfers();
    loadActiveClients();
  }

  @override
  void onClose() {
    transferAmountCtrl.dispose();
    reasonCtrl.dispose();
    notesCtrl.dispose();
    approvalNotesCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // API Methods
  // ─────────────────────────────────────────────

  /// GET /api/getInternalTransfers
  Future<void> loadTransfers({String? clientId, String? status}) async {
    isLoading.value = true;
    try {
      final url = ApiConstants.getInternalTransfers(
        clientId: clientId,
        status: status,
      );
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          transfers.value = InternalTransferModel.fromJsonList(data);
        } else {
          transfers.value = [];
        }
      } else {
        HelperUi.showToast(message: 'Failed to load internal transfers.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading transfers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /api/getActiveClients — loads the full active client list
  Future<void> loadActiveClients() async {
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
    }
  }

  /// GET /api/getActiveClients — filters the cached list to bookings for
  /// [clientId] (matched via the `user_id` field on each record).
  Future<void> loadClientBookings(int clientId) async {
    selectedSourceBookingId.value = null;
    selectedTargetBookingId.value = null;
    sourceBookingOutstanding.value = null;
    targetBookingOutstanding.value = null;
    clientBookings.value = [];

    try {
      // Re-use already-loaded data when available; otherwise fetch fresh.
      List<dynamic> all = activeClients.toList();
      if (all.isEmpty) {
        final response = await _api.getRaw(ApiConstants.getActiveClients);
        if (response != null && response.statusCode == 200) {
          final data = response.data;
          all = data is List ? data : [];
          activeClients.value = all;
        }
      }
      clientBookings.value = all
          .where((c) => (c['user_id'] as num?)?.toInt() == clientId)
          .toList();
    } catch (e) {
      HelperUi.showToast(message: 'Error loading bookings: $e');
    }
  }

  /// GET /api/bookingOutstanding/:bookingId
  /// Sets [sourceBookingOutstanding] when [isSource] is true, otherwise
  /// sets [targetBookingOutstanding].
  Future<void> loadBookingOutstanding(int bookingId, bool isSource) async {
    try {
      final url = ApiConstants.getBookingOutstanding(bookingId);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final model = OutstandingBalanceModel.fromJson(data);
          if (isSource) {
            sourceBookingOutstanding.value = model;
          } else {
            targetBookingOutstanding.value = model;
          }
        }
      } else {
        HelperUi.showToast(message: 'Failed to load booking outstanding.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading outstanding: $e');
    }
  }

  /// Called when the source booking dropdown changes.
  void onSourceBookingChanged(int? bookingId) {
    selectedSourceBookingId.value = bookingId;
    sourceBookingOutstanding.value = null;
    if (bookingId != null) {
      loadBookingOutstanding(bookingId, true);
    }
  }

  /// Called when the target booking dropdown changes.
  void onTargetBookingChanged(int? bookingId) {
    selectedTargetBookingId.value = bookingId;
    targetBookingOutstanding.value = null;
    if (bookingId != null) {
      loadBookingOutstanding(bookingId, false);
    }
  }

  // ─────────────────────────────────────────────
  // Create Transfer
  // ─────────────────────────────────────────────

  /// POST /api/createInternalTransfer
  Future<void> createTransfer() async {
    if (!_validateCreateForm()) return;

    isSubmitting.value = true;
    try {
      final amount = double.tryParse(transferAmountCtrl.text.trim()) ?? 0;
      final body = <String, dynamic>{
        'client_id':         selectedClientId.value,
        'source_booking_id': selectedSourceBookingId.value,
        'target_booking_id': selectedTargetBookingId.value,
        'transfer_amount':   amount,
        'transfer_type':     transferType.value,
        'reason':            reasonCtrl.text.trim(),
        if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
      };

      final response = await _api.postRaw(ApiConstants.createInternalTransfer, body);

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        clearForm();
        await loadTransfers();
        HelperUi.showToast(
          message: 'Internal transfer created successfully.',
          backgroundColor: Colors.green,
        );
      } else {
        final msg = response?.data['message'] ??
            'Failed to create internal transfer. Please try again.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error creating transfer: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Approve / Reject Transfer
  // ─────────────────────────────────────────────

  /// PATCH /api/approveInternalTransfer
  /// [action] should be 'APPROVE' or 'REJECT'.
  Future<void> approveTransfer(
    int transferId,
    String action,
    String notes,
  ) async {
    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'transfer_id':    transferId,
        'action':         action,
        'approval_notes': notes,
      };

      final response =
          await _api.patchRaw(ApiConstants.approveInternalTransfer, body);

      if (response != null && response.statusCode == 200) {
        await loadTransfers();
        approvalNotesCtrl.clear();
        HelperUi.showToast(
          message: 'Transfer ${action.toLowerCase()}d successfully.',
          backgroundColor:
              action == 'APPROVE' ? Colors.green : Colors.orange,
        );
      } else {
        final msg = response?.data['message'] ??
            'Failed to ${action.toLowerCase()} transfer.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  bool _validateCreateForm() {
    if (selectedClientId.value == null) {
      HelperUi.showToast(
          message: 'Please select a client', backgroundColor: Colors.red);
      return false;
    }
    if (selectedSourceBookingId.value == null) {
      HelperUi.showToast(
          message: 'Please select a source booking',
          backgroundColor: Colors.red);
      return false;
    }
    if (selectedTargetBookingId.value == null) {
      HelperUi.showToast(
          message: 'Please select a target booking',
          backgroundColor: Colors.red);
      return false;
    }
    if (selectedSourceBookingId.value == selectedTargetBookingId.value) {
      HelperUi.showToast(
          message: 'Source and target bookings must be different',
          backgroundColor: Colors.red);
      return false;
    }
    final amount = double.tryParse(transferAmountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      HelperUi.showToast(
          message: 'Please enter a valid transfer amount',
          backgroundColor: Colors.red);
      return false;
    }
    if (reasonCtrl.text.trim().isEmpty) {
      HelperUi.showToast(
          message: 'Please enter a reason', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  void clearForm() {
    selectedClientId.value         = null;
    selectedSourceBookingId.value  = null;
    selectedTargetBookingId.value  = null;
    sourceBookingOutstanding.value = null;
    targetBookingOutstanding.value = null;
    clientBookings.value           = [];
    transferType.value             = 'OVERPAYMENT_TRANSFER';
    transferAmountCtrl.clear();
    reasonCtrl.clear();
    notesCtrl.clear();
    approvalNotesCtrl.clear();
  }
}
