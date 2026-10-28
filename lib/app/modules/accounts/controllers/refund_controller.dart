import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/refund_model.dart';
import 'accounts_feedback.dart';

class RefundController extends GetxController {
  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  var refunds          = <RefundModel>[].obs;
  var selectedRefund   = Rxn<RefundModel>();
  var activeClients    = <dynamic>[].obs;
  var clientReceipts   = <dynamic>[].obs;
  var selectedReceiptIds = <int>[].obs;
  var isLoading        = false.obs;
  var isSubmitting     = false.obs;
  var selectedClientId = Rxn<int>();
  var selectedBookingId = Rxn<int>();
  var refundChannel    = 'CASH'.obs;
  var refundReason     = 'OVERPAYMENT'.obs;

  // List filters (status + created_on range, applied server-side)
  final listStatusFilter = 'ALL'.obs;
  final TextEditingController listFromDateCtrl = TextEditingController();
  final TextEditingController listToDateCtrl   = TextEditingController();

  // ─────────────────────────────────────────────
  // Text Editing Controllers
  // ─────────────────────────────────────────────
  final TextEditingController refundAmountCtrl      = TextEditingController();
  final TextEditingController notesCtrl             = TextEditingController();
  final TextEditingController actionNotesCtrl       = TextEditingController();

  // Bank transfer fields
  final TextEditingController bankNameCtrl          = TextEditingController();
  final TextEditingController accountNumberCtrl     = TextEditingController();
  final TextEditingController ifscCodeCtrl          = TextEditingController();
  final TextEditingController accountHolderCtrl     = TextEditingController();

  // UPI fields
  final TextEditingController upiIdCtrl             = TextEditingController();

  // Cheque fields
  final TextEditingController chequeNumberCtrl      = TextEditingController();
  final TextEditingController chequeDateCtrl        = TextEditingController();

  // Dispatch / dispatch fields
  final TextEditingController dispatchUtrCtrl       = TextEditingController();
  final TextEditingController dispatchDateCtrl      = TextEditingController();

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
    loadRefunds();
    loadActiveClients();
  }

  @override
  void onClose() {
    listFromDateCtrl.dispose();
    listToDateCtrl.dispose();
    refundAmountCtrl.dispose();
    notesCtrl.dispose();
    actionNotesCtrl.dispose();
    bankNameCtrl.dispose();
    accountNumberCtrl.dispose();
    ifscCodeCtrl.dispose();
    accountHolderCtrl.dispose();
    upiIdCtrl.dispose();
    chequeNumberCtrl.dispose();
    chequeDateCtrl.dispose();
    dispatchUtrCtrl.dispose();
    dispatchDateCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // API Methods
  // ─────────────────────────────────────────────

  /// GET /api/getRefunds?status=&from_date=&to_date= (list filters by default).
  Future<void> loadRefunds({String? bookingId, String? status}) async {
    isLoading.value = true;
    try {
      final st = status ??
          (listStatusFilter.value == 'ALL' ? null : listStatusFilter.value);
      final url = ApiConstants.getRefunds(
        '',
        bookingId: bookingId,
        status: st,
        fromDate: listFromDateCtrl.text.trim(),
        toDate: listToDateCtrl.text.trim(),
      );
      final response = await _api.getRaw(url);
      if (isOkResponse(response)) {
        final data = response!.data;
        refunds.value = data is List ? RefundModel.fromJsonList(data) : [];
      } else {
        toastApiError(response, 'Failed to load refunds.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading refunds: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Id most recently requested by [loadRefundById]; lets the detail view
  /// fetch once per refund instead of on every rebuild.
  int? lastRequestedRefundId;

  /// GET /api/getRefundById/:id — sets [selectedRefund]
  Future<void> loadRefundById(int id) async {
    lastRequestedRefundId = id;
    isLoading.value = true;
    try {
      final url = ApiConstants.getRefundById(id);
      final response = await _api.getRaw(url);
      if (isOkResponse(response) && response!.data is Map) {
        selectedRefund.value =
            RefundModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      } else {
        selectedRefund.value = null;
        toastApiError(response, 'Failed to load refund details.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading refund: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /api/getActiveClients
  Future<void> loadActiveClients() async {
    try {
      final response = await _api.getRaw(ApiConstants.getActiveClients);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          activeClients.value = data;
        } else {
          activeClients.value = [];
        }
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading clients: $e');
    }
  }

  /// GET /api/getReceipts?booking_id=X&status=Approved — only approved
  /// receipts count towards the refundable balance on the backend.
  Future<void> loadClientReceipts(int bookingId) async {
    try {
      final url = ApiConstants.getReceipts(bookingId: bookingId, status: 'Approved');
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          clientReceipts.value = data;
        } else {
          clientReceipts.value = [];
        }
      } else {
        toastApiError(response, 'Failed to load receipts for booking.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading receipts: $e');
    }
  }

  /// POST /api/createRefund
  /// { client_id (= user_id), booking_id, refund_amount, refund_channel,
  ///   refund_reason, notes, receipt_ids, channel_details }. Returns true on success.
  Future<bool> createRefund() async {
    if (selectedClientId.value == null) {
      toastValidation('Please select a client');
      return false;
    }
    if (selectedBookingId.value == null) {
      toastValidation('Please select a booking');
      return false;
    }
    final amount = double.tryParse(refundAmountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      toastValidation('Please enter a valid refund amount');
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'client_id':       selectedClientId.value,
        'booking_id':      selectedBookingId.value,
        'refund_amount':   amount,
        'refund_channel':  refundChannel.value,
        'refund_reason':   refundReason.value,
        'notes':           notesCtrl.text.trim(),
        'receipt_ids':     List<int>.from(selectedReceiptIds),
        'channel_details': getChannelDetails(),
      };

      final response = await _api.postRaw(ApiConstants.createRefund, body);
      if (isOkResponse(response)) {
        clearForm();
        await loadRefunds();
        toastSuccess('Refund request created successfully.');
        return true;
      }
      toastApiError(response, 'Failed to create refund.');
    } catch (e) {
      toastValidation('Error creating refund: $e');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  /// PATCH /api/approveRefund { refund_id, action, notes?, dispatch_details? }.
  /// [action] is one of 'Approved' | 'Rejected' (from PENDING_APPROVAL),
  /// 'Processing' (from APPROVED) or 'Completed' (from PROCESSING).
  Future<bool> updateRefundStatus(
    int refundId,
    String action, {
    String? notes,
    Map<String, dynamic>? dispatchDetails,
  }) async {
    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'refund_id': refundId,
        'action':    action,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (dispatchDetails != null) 'dispatch_details': dispatchDetails,
      };

      final response = await _api.patchRaw(ApiConstants.approveRefund, body);
      if (isOkResponse(response)) {
        await loadRefunds();
        toastSuccess('Refund marked ${action.toLowerCase()}.');
        return true;
      }
      toastApiError(response, 'Failed to update refund status.');
    } catch (e) {
      toastValidation('Error updating refund: $e');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  /// Returns the channel_details map built from the currently active channel's fields.
  Map<String, dynamic> getChannelDetails() {
    switch (refundChannel.value) {
      case 'BANK_TRANSFER':
        return {
          'bank_name':       bankNameCtrl.text.trim(),
          'account_number':  accountNumberCtrl.text.trim(),
          'ifsc_code':       ifscCodeCtrl.text.trim(),
          'account_holder':  accountHolderCtrl.text.trim(),
        };
      case 'UPI':
        return {
          'upi_id': upiIdCtrl.text.trim(),
        };
      case 'CHEQUE':
        return {
          'cheque_number': chequeNumberCtrl.text.trim(),
          'cheque_date':   chequeDateCtrl.text.trim(),
          'bank_name':     bankNameCtrl.text.trim(),
        };
      case 'CASH':
      default:
        return {};
    }
  }

  /// Resets all form fields to their default state.
  void clearForm() {
    selectedClientId.value    = null;
    selectedBookingId.value   = null;
    selectedReceiptIds.clear();
    clientReceipts.value      = [];
    refundChannel.value       = 'CASH';
    refundReason.value        = 'OVERPAYMENT';
    refundAmountCtrl.clear();
    notesCtrl.clear();
    actionNotesCtrl.clear();
    bankNameCtrl.clear();
    accountNumberCtrl.clear();
    ifscCodeCtrl.clear();
    accountHolderCtrl.clear();
    upiIdCtrl.clear();
    chequeNumberCtrl.clear();
    chequeDateCtrl.clear();
    dispatchUtrCtrl.clear();
    dispatchDateCtrl.clear();
  }
}
