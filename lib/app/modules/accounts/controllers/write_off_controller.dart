import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/write_off_model.dart';
import 'accounts_feedback.dart';

class WriteOffController extends GetxController {
  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  var writeOffs         = <WriteOffModel>[].obs;
  var activeClients     = <dynamic>[].obs;
  var bookingInvoices   = <dynamic>[].obs;
  var isLoading         = false.obs;
  var isSubmitting      = false.obs;
  var selectedWriteOff  = Rxn<WriteOffModel>();
  var selectedClientId  = Rxn<int>();
  var selectedBookingId = Rxn<int>();
  var selectedInvoiceIds = <int>[].obs;
  var writeOffType      = 'BAD_DEBT'.obs;

  // ─────────────────────────────────────────────
  // Text Editing Controllers
  // ─────────────────────────────────────────────
  final TextEditingController writeOffAmountCtrl  = TextEditingController();
  final TextEditingController reasonCtrl          = TextEditingController();
  final TextEditingController remarksCtrl         = TextEditingController();
  final TextEditingController approvalNotesCtrl   = TextEditingController();

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────
  final ApiService _api = ApiService();

  @override
  void onInit() {
    super.onInit();
    loadWriteOffs();
    loadActiveClients();
  }

  @override
  void onClose() {
    writeOffAmountCtrl.dispose();
    reasonCtrl.dispose();
    remarksCtrl.dispose();
    approvalNotesCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // API Methods
  // ─────────────────────────────────────────────

  /// Fetch write-offs with optional query filters.
  Future<void> loadWriteOffs({String? bookingId, String? status}) async {
    isLoading.value = true;
    try {
      String url = ApiConstants.getWriteOffs(
        bookingId: bookingId != null ? int.tryParse(bookingId) : null,
        status:    status,
      );
      final response = await _api.getRaw(url);
      if (isOkResponse(response)) {
        final data = response!.data;
        writeOffs.value = data is List ? WriteOffModel.listFromJson(data) : [];
      } else {
        toastApiError(response, 'Failed to load write-offs.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading write-offs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all active clients for the client-selection dropdown.
  Future<void> loadActiveClients() async {
    try {
      final response = await _api.getRaw(ApiConstants.getActiveClients);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        activeClients.value = (data is List) ? data : [];
      } else {
        toastApiError(response, 'Failed to load clients.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading clients: $e');
    }
  }

  /// Fetch invoices for a specific booking.
  Future<void> loadBookingInvoices(int bookingId) async {
    try {
      final url = ApiConstants.getInvoices(bookingId: bookingId);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        bookingInvoices.value = (data is List) ? data : [];
      } else {
        toastApiError(response, 'Failed to load invoices.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading invoices: $e');
    }
  }

  /// Submit a new write-off via POST /api/createWriteOffV2
  /// { booking_id, user_id, write_off_type, invoice_ids, write_off_amount, reason, remarks }.
  /// Returns true on success.
  Future<bool> createWriteOff() async {
    if (selectedBookingId.value == null) {
      toastValidation('Please select a booking.');
      return false;
    }
    if (writeOffAmountCtrl.text.trim().isEmpty) {
      toastValidation('Please enter a write-off amount.');
      return false;
    }
    if (reasonCtrl.text.trim().isEmpty) {
      toastValidation('Please enter a reason.');
      return false;
    }

    final amount = double.tryParse(writeOffAmountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      toastValidation('Write-off amount must be greater than zero.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'booking_id':       selectedBookingId.value,
        'write_off_amount': amount,
        'reason':           reasonCtrl.text.trim(),
        'remarks':          remarksCtrl.text.trim(),
        'write_off_type':   writeOffType.value,
        if (selectedClientId.value != null)
          'user_id': selectedClientId.value,
        if (selectedInvoiceIds.isNotEmpty)
          'invoice_ids': selectedInvoiceIds.toList(),
      };

      final response = await _api.postRaw(ApiConstants.createWriteOffV2, body);

      if (isOkResponse(response)) {
        clearForm();
        await loadWriteOffs();
        toastSuccess('Write-off created and sent for approval.');
        return true;
      }
      toastApiError(response, 'Failed to create write-off. Please try again.');
    } catch (e) {
      toastValidation('Error creating write-off: $e');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  /// PATCH /api/approveWriteOff { write_off_id, action: 'Approved'|'Rejected', notes }.
  /// Returns true on success.
  Future<bool> approveWriteOff(
    int writeOffId,
    String action,
    String notes,
  ) async {
    isSubmitting.value = true;
    try {
      final response = await _api.patchRaw(ApiConstants.approveWriteOff, {
        'write_off_id': writeOffId,
        'action':       action,
        if (notes.isNotEmpty) 'notes': notes,
      });

      if (isOkResponse(response)) {
        await loadWriteOffs();
        toastSuccess('Write-off ${action.toLowerCase()} successfully.');
        return true;
      }
      toastApiError(response, 'Failed to update write-off.');
    } catch (e) {
      toastValidation('Error updating write-off: $e');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  // ─────────────────────────────────────────────
  // Form Helpers
  // ─────────────────────────────────────────────

  /// Toggle an invoice in/out of [selectedInvoiceIds].
  void toggleInvoiceSelection(int invoiceId) {
    if (selectedInvoiceIds.contains(invoiceId)) {
      selectedInvoiceIds.remove(invoiceId);
    } else {
      selectedInvoiceIds.add(invoiceId);
    }
  }

  /// Reset all form fields and selections.
  void clearForm() {
    writeOffAmountCtrl.clear();
    reasonCtrl.clear();
    remarksCtrl.clear();
    approvalNotesCtrl.clear();
    selectedClientId.value  = null;
    selectedBookingId.value = null;
    selectedWriteOff.value  = null;
    selectedInvoiceIds.clear();
    writeOffType.value      = 'BAD_DEBT';
    bookingInvoices.value   = [];
  }
}
