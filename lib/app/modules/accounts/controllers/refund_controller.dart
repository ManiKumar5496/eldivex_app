import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/refund_model.dart';

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

  /// GET /api/getRefunds
  Future<void> loadRefunds({String? bookingId, String? status}) async {
    isLoading.value = true;
    try {
      final url = ApiConstants.getRefunds('', bookingId: bookingId, status: status);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          refunds.value = RefundModel.fromJsonList(data);
        } else {
          refunds.value = [];
        }
      } else {
        HelperUi.showToast(message: 'Failed to load refunds.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading refunds: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /api/getRefundById/:id — sets [selectedRefund]
  Future<void> loadRefundById(int id) async {
    isLoading.value = true;
    try {
      final url = ApiConstants.getRefundById(id);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          selectedRefund.value = RefundModel.fromJson(data);
        }
      } else {
        HelperUi.showToast(message: 'Failed to load refund details.');
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

  /// GET /api/getReceipts?booking_id=X
  Future<void> loadClientReceipts(int bookingId) async {
    try {
      final url = ApiConstants.getReceipts(bookingId: bookingId);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          clientReceipts.value = data;
        } else {
          clientReceipts.value = [];
        }
      } else {
        HelperUi.showToast(message: 'Failed to load receipts for booking.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading receipts: $e');
    }
  }

  /// POST /api/createRefund
  Future<void> createRefund() async {
    if (selectedClientId.value == null) {
      HelperUi.showToast(
          message: 'Please select a client', backgroundColor: Colors.red);
      return;
    }
    if (selectedBookingId.value == null) {
      HelperUi.showToast(
          message: 'Please select a booking', backgroundColor: Colors.red);
      return;
    }
    if (refundAmountCtrl.text.trim().isEmpty) {
      HelperUi.showToast(
          message: 'Please enter refund amount', backgroundColor: Colors.red);
      return;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'client_id':       selectedClientId.value,
        'booking_id':      selectedBookingId.value,
        'refund_amount':   double.tryParse(refundAmountCtrl.text.trim()) ?? 0,
        'refund_channel':  refundChannel.value,
        'refund_reason':   refundReason.value,
        'notes':           notesCtrl.text.trim(),
        'receipt_ids':     List<int>.from(selectedReceiptIds),
        'channel_details': getChannelDetails(),
      };

      final response = await _api.postRaw(ApiConstants.createRefund, body);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        clearForm();
        await loadRefunds();
        HelperUi.showToast(
          message: 'Refund request created successfully.',
          backgroundColor: Colors.green,
        );
      } else {
        final msg = response?.data['message'] ?? 'Failed to create refund.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error creating refund: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// PATCH /api/approveRefund
  Future<void> updateRefundStatus(
    int refundId,
    String action, {
    String? notes,
    Map<String, dynamic>? dispatchDetails,
  }) async {
    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'id':     refundId,
        'action': action,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (dispatchDetails != null) 'dispatch_details': dispatchDetails,
      };

      final response = await _api.patchRaw(ApiConstants.approveRefund, body);
      if (response != null && response.statusCode == 200) {
        await loadRefunds();
        HelperUi.showToast(
          message: 'Refund status updated to $action.',
          backgroundColor: Colors.green,
        );
      } else {
        final msg = response?.data['message'] ?? 'Failed to update refund status.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error updating refund: $e');
    } finally {
      isSubmitting.value = false;
    }
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
