import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/credit_note_model.dart';
import '../models/credit_note_application_model.dart';

class CreditNoteController extends GetxController {
  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  var creditNotes              = <dynamic>[].obs;
  var selectedCreditNote       = Rxn<dynamic>();
  var creditNoteApplications   = <CreditNoteApplicationModel>[].obs;
  var targetInvoices           = <dynamic>[].obs;
  var activeClients            = <dynamic>[].obs;
  var isLoading                = false.obs;
  var isSubmitting             = false.obs;

  // Selection state
  var selectedBookingId        = Rxn<int>();
  var selectedInvoiceId        = Rxn<int>();
  var creditType               = 'Hold'.obs;
  var creditNoteType           = 'SERVICE_ADJUSTMENT'.obs;
  var selectedCreditNoteId     = Rxn<int>();
  var selectedTargetBookingId  = Rxn<int>();
  var selectedTargetInvoiceId  = Rxn<int>();

  // ─────────────────────────────────────────────
  // Text Editing Controllers
  // ─────────────────────────────────────────────
  final TextEditingController amountCtrl       = TextEditingController();
  final TextEditingController reasonCtrl       = TextEditingController();
  final TextEditingController notesCtrl        = TextEditingController();
  final TextEditingController expiryDateCtrl   = TextEditingController();
  final TextEditingController applyAmountCtrl  = TextEditingController();
  final TextEditingController applyNotesCtrl   = TextEditingController();
  final TextEditingController approvalNotesCtrl = TextEditingController();

  // ─────────────────────────────────────────────
  // Services
  // ─────────────────────────────────────────────
  final ApiService _api = ApiService();

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadCreditNotes();
    loadActiveClients();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    reasonCtrl.dispose();
    notesCtrl.dispose();
    expiryDateCtrl.dispose();
    applyAmountCtrl.dispose();
    applyNotesCtrl.dispose();
    approvalNotesCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // Load Credit Notes
  // ─────────────────────────────────────────────

  /// Fetches all credit notes, optionally filtered by bookingId and/or status.
  Future<void> loadCreditNotes({String? bookingId, String? status}) async {
    isLoading.value = true;
    try {
      final url = ApiConstants.getCreditNotes(bookingId, status);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          creditNotes.value = CreditNoteModel.listFromJson(data);
        } else {
          creditNotes.value = [];
        }
      } else {
        HelperUi.showToast(message: 'Failed to load credit notes.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading credit notes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Selects a credit note by id — uses the already-loaded list first;
  /// falls back to a network fetch if not found locally.
  Future<void> loadCreditNoteById(int id) async {
    final existing = creditNotes.firstWhereOrNull(
      (cn) => (cn is CreditNoteModel) && cn.id == id,
    );
    if (existing != null) {
      selectedCreditNote.value = existing;
      return;
    }
    // Not cached — reload list and try again.
    await loadCreditNotes();
    selectedCreditNote.value = creditNotes.firstWhereOrNull(
      (cn) => (cn is CreditNoteModel) && cn.id == id,
    );
  }

  // ─────────────────────────────────────────────
  // Load Target Invoices (for apply screen)
  // ─────────────────────────────────────────────

  /// Loads invoices for a booking so the user can choose a target invoice
  /// when applying a credit note.
  Future<void> loadTargetInvoices(int bookingId) async {
    isLoading.value = true;
    try {
      final url = ApiConstants.getInvoices(bookingId: bookingId);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        targetInvoices.value = data is List ? data : [];
      } else {
        HelperUi.showToast(message: 'Failed to load invoices for booking.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading invoices: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Load Applications
  // ─────────────────────────────────────────────

  /// Fetches all application records for the given credit note id.
  Future<void> loadApplications(int creditNoteId) async {
    isLoading.value = true;
    try {
      final url = ApiConstants.getCreditNoteApplications(creditNoteId.toString());
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          creditNoteApplications.value =
              CreditNoteApplicationModel.fromJsonList(data);
        } else {
          creditNoteApplications.value = [];
        }
      } else {
        HelperUi.showToast(message: 'Failed to load credit note applications.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading applications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Load Active Clients
  // ─────────────────────────────────────────────

  Future<void> loadActiveClients() async {
    try {
      final response = await _api.getRaw(ApiConstants.getActiveClients);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        activeClients.value = data is List ? data : [];
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading clients: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Create Credit Note
  // ─────────────────────────────────────────────

  Future<void> createCreditNote() async {
    if (selectedBookingId.value == null) {
      HelperUi.showToast(
        message: 'Please select a client/booking.',
        backgroundColor: Colors.red,
      );
      return;
    }
    final amountText = amountCtrl.text.trim();
    if (amountText.isEmpty) {
      HelperUi.showToast(
        message: 'Please enter the credit amount.',
        backgroundColor: Colors.red,
      );
      return;
    }
    final amount = double.tryParse(amountText) ?? 0;
    if (amount <= 0) {
      HelperUi.showToast(
        message: 'Amount must be greater than zero.',
        backgroundColor: Colors.red,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'booking_id':       selectedBookingId.value,
        'credit_type':      creditType.value,
        'credit_note_type': creditNoteType.value,
        'amount':           amount,
        'reason':           reasonCtrl.text.trim(),
        'notes':            notesCtrl.text.trim(),
        if (selectedInvoiceId.value != null)
          'invoice_id':     selectedInvoiceId.value,
        if (expiryDateCtrl.text.trim().isNotEmpty)
          'expiry_date':    expiryDateCtrl.text.trim(),
      };

      final response = await _api.postRaw(ApiConstants.createCreditNote, body);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        clearForm();
        await loadCreditNotes();
        HelperUi.showToast(
          message: 'Credit note created successfully.',
          backgroundColor: Colors.green,
        );
      } else {
        final msg = response?.data['message'] ?? 'Failed to create credit note.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error creating credit note: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Approve / Reject Credit Note
  // ─────────────────────────────────────────────

  /// action should be 'Approved' or 'Rejected'.
  Future<void> approveCreditNote(int id, String action, String notes) async {
    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'id':     id,
        'status': action,
        if (notes.isNotEmpty) 'notes': notes,
      };
      final response =
          await _api.patchRaw(ApiConstants.updateCreditNoteStatus, body);
      if (response != null && response.statusCode == 200) {
        approvalNotesCtrl.clear();
        await loadCreditNotes();
        HelperUi.showToast(
          message: 'Credit note $action.',
          backgroundColor:
              action == 'Approved' ? Colors.green : Colors.orange,
        );
      } else {
        final msg =
            response?.data['message'] ?? 'Failed to update credit note status.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error updating status: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Apply Credit Note
  // ─────────────────────────────────────────────

  Future<void> applyCreditNote() async {
    if (selectedCreditNoteId.value == null) {
      HelperUi.showToast(
        message: 'Please select a credit note.',
        backgroundColor: Colors.red,
      );
      return;
    }
    if (selectedTargetBookingId.value == null) {
      HelperUi.showToast(
        message: 'Please select a target booking.',
        backgroundColor: Colors.red,
      );
      return;
    }
    if (selectedTargetInvoiceId.value == null) {
      HelperUi.showToast(
        message: 'Please select a target invoice.',
        backgroundColor: Colors.red,
      );
      return;
    }
    final applyAmountText = applyAmountCtrl.text.trim();
    if (applyAmountText.isEmpty) {
      HelperUi.showToast(
        message: 'Please enter the amount to apply.',
        backgroundColor: Colors.red,
      );
      return;
    }
    final applyAmount = double.tryParse(applyAmountText) ?? 0;
    if (applyAmount <= 0) {
      HelperUi.showToast(
        message: 'Apply amount must be greater than zero.',
        backgroundColor: Colors.red,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'credit_note_id':      selectedCreditNoteId.value,
        'target_booking_id':   selectedTargetBookingId.value,
        'target_invoice_id':   selectedTargetInvoiceId.value,
        'amount_applied':      applyAmount,
        if (applyNotesCtrl.text.trim().isNotEmpty)
          'notes':             applyNotesCtrl.text.trim(),
      };

      final response = await _api.postRaw(ApiConstants.applyCreditNote, body);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        clearApplyForm();
        await loadCreditNotes();
        if (selectedCreditNoteId.value != null) {
          await loadApplications(selectedCreditNoteId.value!);
        }
        HelperUi.showToast(
          message: 'Credit note applied successfully.',
          backgroundColor: Colors.green,
        );
      } else {
        final msg =
            response?.data['message'] ?? 'Failed to apply credit note.';
        HelperUi.showToast(message: msg);
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error applying credit note: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Clear Helpers
  // ─────────────────────────────────────────────

  void clearForm() {
    selectedBookingId.value  = null;
    selectedInvoiceId.value  = null;
    creditType.value         = 'Hold';
    creditNoteType.value     = 'SERVICE_ADJUSTMENT';
    amountCtrl.clear();
    reasonCtrl.clear();
    notesCtrl.clear();
    expiryDateCtrl.clear();
  }

  void clearApplyForm() {
    selectedCreditNoteId.value    = null;
    selectedTargetBookingId.value = null;
    selectedTargetInvoiceId.value = null;
    applyAmountCtrl.clear();
    applyNotesCtrl.clear();
    targetInvoices.value = [];
  }
}
