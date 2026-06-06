import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/write_off_model.dart';

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
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          writeOffs.value = WriteOffModel.listFromJson(data);
        } else {
          writeOffs.value = [];
        }
      } else {
        HelperUi.showToast(message: 'Failed to load write-offs.');
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
        HelperUi.showToast(message: 'Failed to load clients.');
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
        HelperUi.showToast(message: 'Failed to load invoices.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading invoices: $e');
    }
  }

  /// Submit a new write-off via /api/createWriteOffV2.
  Future<void> createWriteOff() async {
    if (writeOffAmountCtrl.text.isEmpty) {
      HelperUi.showToast(
        message: 'Please enter a write-off amount.',
        backgroundColor: Colors.red,
      );
      return;
    }
    if (reasonCtrl.text.isEmpty) {
      HelperUi.showToast(
        message: 'Please enter a reason.',
        backgroundColor: Colors.red,
      );
      return;
    }
    if (selectedBookingId.value == null) {
      HelperUi.showToast(
        message: 'Please select a booking.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final amount = double.tryParse(writeOffAmountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      HelperUi.showToast(
        message: 'Write-off amount must be greater than zero.',
        backgroundColor: Colors.red,
      );
      return;
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
          'client_id': selectedClientId.value,
        if (selectedInvoiceIds.isNotEmpty)
          'invoice_ids': selectedInvoiceIds.toList(),
      };

      final response = await _api.postRaw(ApiConstants.createWriteOffV2, body);

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        clearForm();
        await loadWriteOffs();
        Get.snackbar(
          'Success',
          'Write-off created successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final msg = response?.data['message'] ??
            'Failed to create write-off. Please try again.';
        Get.snackbar(
          'Error',
          msg.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error creating write-off: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Approve or reject a write-off via PATCH /api/approveWriteOff.
  Future<void> approveWriteOff(
    int writeOffId,
    String action,
    String notes,
  ) async {
    isSubmitting.value = true;
    try {
      final response = await _api.patchRaw(ApiConstants.approveWriteOff, {
        'id':     writeOffId,
        'action': action,   // e.g. 'approve' | 'reject'
        'notes':  notes,
      });

      if (response != null && response.statusCode == 200) {
        await loadWriteOffs();
        Get.snackbar(
          'Success',
          'Write-off ${action == 'approve' ? 'approved' : 'rejected'} successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final msg = response?.data['message'] ?? 'Failed to update write-off.';
        Get.snackbar(
          'Error',
          msg.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error updating write-off: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
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
