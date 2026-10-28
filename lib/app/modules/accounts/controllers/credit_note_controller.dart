import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import '../models/credit_note_model.dart';
import '../models/credit_note_application_model.dart';
import '../models/parse_utils.dart';
import 'accounts_feedback.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreditNoteController extends GetxController {
  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  var creditNotes              = <dynamic>[].obs;
  // What the list view renders: creditNotes (already status-filtered server-side)
  // narrowed by the free-text search box. Org isolation is guaranteed upstream
  // by getCreditNotes being org-scoped on the backend.
  var filteredCreditNotes      = <dynamic>[].obs;
  var searchQuery              = ''.obs;
  /// Bound to the list's search box so its text matches [searchQuery] when
  /// the page is revisited (the controller outlives the page).
  late final TextEditingController searchCtrl =
      TextEditingController(text: searchQuery.value);
  // Server-side status filter: 'All' | Pending | Approved | Rejected
  final statusFilter           = 'All'.obs;
  var selectedCreditNote       = Rxn<dynamic>();
  var creditNoteApplications   = <CreditNoteApplicationModel>[].obs;
  var targetInvoices           = <dynamic>[].obs;
  var activeClients            = <dynamic>[].obs;
  var isLoading                = false.obs;
  var isSubmitting             = false.obs;

  // Selection state
  var selectedClientId         = Rxn<int>();
  var selectedBookingId        = Rxn<int>();
  var selectedInvoiceId        = Rxn<int>();
  var creditType               = 'Hold'.obs;
  var selectedCreditNoteId     = Rxn<int>();
  var selectedTargetBookingId  = Rxn<int>();
  var selectedTargetInvoiceId  = Rxn<int>();

  // ─────────────────────────────────────────────
  // Text Editing Controllers
  // ─────────────────────────────────────────────
  final TextEditingController amountCtrl       = TextEditingController();
  final TextEditingController reasonCtrl       = TextEditingController();
  final TextEditingController creditDateCtrl   = TextEditingController();
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
    creditDateCtrl.dispose();
    applyAmountCtrl.dispose();
    applyNotesCtrl.dispose();
    approvalNotesCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // Load Credit Notes
  // ─────────────────────────────────────────────

  /// Fetches credit notes, filtered by [status] (defaults to [statusFilter])
  /// and optionally [bookingId].
  Future<void> loadCreditNotes({String? bookingId, String? status}) async {
    isLoading.value = true;
    try {
      final st = status ?? (statusFilter.value == 'All' ? null : statusFilter.value);
      final url = ApiConstants.getCreditNotes(bookingId, st);
      final response = await _api.getRaw(url);
      if (isOkResponse(response)) {
        final data = response!.data;
        creditNotes.value = data is List ? CreditNoteModel.listFromJson(data) : [];
        _applyCreditNoteSearch();
      } else {
        toastApiError(response, 'Failed to load credit notes.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading credit notes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Free-text search box handler — filters the loaded credit notes in memory.
  void searchCreditNotes(String query) {
    searchQuery.value = query;
    _applyCreditNoteSearch();
  }

  void _applyCreditNoteSearch() {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredCreditNotes.value = List.from(creditNotes);
      return;
    }
    filteredCreditNotes.value = creditNotes.where((cn) {
      if (cn is! CreditNoteModel) return false;
      return (cn.clientName ?? '').toLowerCase().contains(q) ||
          (cn.clientMobile ?? '').toLowerCase().contains(q) ||
          (cn.patientName ?? '').toLowerCase().contains(q) ||
          cn.bookingId.toString().contains(q) ||
          cn.creditType.toLowerCase().contains(q);
    }).toList();
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
    // Not cached (e.g. browser refresh) — reload the full list and try again.
    await loadCreditNotes(status: '');
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
      if (isOkResponse(response)) {
        final data = response!.data;
        targetInvoices.value = data is List ? data : [];
      } else {
        toastApiError(response, 'Failed to load invoices for booking.');
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
        toastApiError(response, 'Failed to load credit note applications.');
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

  /// POST /api/createCreditNote
  /// { booking_id, invoice_id?, credit_type, amount, reason, credit_date? }.
  /// The note is created Pending and must be approved before it can be applied.
  Future<bool> createCreditNote() async {
    if (selectedBookingId.value == null) {
      toastValidation('Please select a client and booking.');
      return false;
    }
    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      toastValidation('Amount must be greater than zero.');
      return false;
    }
    if (reasonCtrl.text.trim().isEmpty) {
      toastValidation('Please enter a reason.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'booking_id':  selectedBookingId.value,
        'credit_type': creditType.value,
        'amount':      amount,
        'reason':      reasonCtrl.text.trim(),
        if (selectedInvoiceId.value != null)
          'invoice_id': selectedInvoiceId.value,
        if (creditDateCtrl.text.trim().isNotEmpty)
          'credit_date': creditDateCtrl.text.trim(),
      };

      final response = await _api.postRaw(ApiConstants.createCreditNote, body);
      if (isOkResponse(response)) {
        clearForm();
        await loadCreditNotes();
        toastSuccess('Credit note created and sent for approval.');
        return true;
      }
      toastApiError(response, 'Failed to create credit note.');
    } catch (e) {
      toastValidation('Error creating credit note: $e');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  // ─────────────────────────────────────────────
  // Approve / Reject Credit Note
  // ─────────────────────────────────────────────

  /// PATCH /api/updateCreditNoteStatus { id, status: 'Approved' | 'Rejected' }.
  /// One credit note, ignoring the list's status filter.
  Future<CreditNoteModel?> _fetchCreditNote(int id, {int? bookingId}) async {
    try {
      final response =
          await _api.getRaw(ApiConstants.getCreditNotes(bookingId?.toString()));
      if (!isOkResponse(response) || response!.data is! List) return null;
      return CreditNoteModel.listFromJson(response.data as List)
          .firstWhereOrNull((cn) => cn.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> approveCreditNote(int id, String action) async {
    isSubmitting.value = true;
    try {
      final response = await _api.patchRaw(ApiConstants.updateCreditNoteStatus, {
        'id':     id,
        'status': action,
      });
      if (isOkResponse(response)) {
        await loadCreditNotes();
        final sel = selectedCreditNote.value;
        if (sel is CreditNoteModel && sel.id == id) {
          // The list may be filtered (e.g. "Pending") and no longer contain
          // this note — re-read it unfiltered rather than keep the stale one.
          selectedCreditNote.value =
              creditNotes.firstWhereOrNull((cn) => cn is CreditNoteModel && cn.id == id) ??
                  await _fetchCreditNote(id, bookingId: sel.bookingId) ??
                  sel;
        }
        toastSuccess('Credit note ${action.toLowerCase()}.');
        return true;
      }
      toastApiError(response, 'Failed to update credit note status.');
    } catch (e) {
      toastValidation('Error updating status: $e');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  /// Confirmation dialog, then [approveCreditNote].
  Future<bool> confirmAndUpdateStatus(CreditNoteModel note, String action) async {
    final approving = action == 'Approved';
    final ok = await Get.dialog<bool>(
      AppDialog(
        title: approving ? 'Approve Credit Note' : 'Reject Credit Note',
        icon: approving
            ? LucideIcons.circleCheck
            : LucideIcons.circleX,
        tone: approving ? AppTone.success : AppTone.danger,
        maxWidth: 440,
        onClose: () => Get.back(result: false),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: approving ? null : AppButtonStyles.danger,
            child: Text(approving ? 'Approve' : 'Reject'),
          ),
        ],
        child: Text(
          '${approving ? 'Approve' : 'Reject'} CN-${note.id} for booking '
          '#${note.bookingId} (₹${note.amount.toStringAsFixed(2)})?',
          style: TextStyle(
              fontSize: 14, height: 1.5, color: AppColor.textSecondary),
        ),
      ),
    );
    if (ok != true) return false;
    return approveCreditNote(note.id, action);
  }

  // ─────────────────────────────────────────────
  // Apply Credit Note
  // ─────────────────────────────────────────────

  /// POST /api/applyCreditNote
  /// { credit_note_id, target_booking_id, target_invoice_id, amount_to_apply, notes? }.
  Future<bool> applyCreditNote() async {
    final cnId = selectedCreditNoteId.value;
    if (cnId == null) {
      toastValidation('Please select a credit note.');
      return false;
    }
    if (selectedTargetBookingId.value == null) {
      toastValidation('Please select a target booking.');
      return false;
    }
    if (selectedTargetInvoiceId.value == null) {
      toastValidation('Please select a target invoice.');
      return false;
    }
    final applyAmount = double.tryParse(applyAmountCtrl.text.trim()) ?? 0;
    if (applyAmount <= 0) {
      toastValidation('Apply amount must be greater than zero.');
      return false;
    }
    final note = selectedCreditNote.value;
    if (note is CreditNoteModel && note.id == cnId && applyAmount > note.available) {
      toastValidation('Amount exceeds the remaining credit of ₹${note.available.toStringAsFixed(2)}.');
      return false;
    }
    // Never credit an invoice past its open balance (the server enforces it).
    final inv = targetInvoices.firstWhereOrNull(
        (i) => toInt(field(i, 'invoice_db_id')) == selectedTargetInvoiceId.value);
    if (inv != null) {
      final open = toDouble(field(inv, 'balance_due'));
      if (applyAmount > open + 0.005) {
        toastValidation('Amount exceeds the invoice\'s open balance of ₹${open.toStringAsFixed(2)}.');
        return false;
      }
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'credit_note_id':    cnId,
        'target_booking_id': selectedTargetBookingId.value,
        'target_invoice_id': selectedTargetInvoiceId.value,
        'amount_to_apply':   applyAmount,
        if (applyNotesCtrl.text.trim().isNotEmpty)
          'notes':           applyNotesCtrl.text.trim(),
      };

      final response = await _api.postRaw(ApiConstants.applyCreditNote, body);
      if (isOkResponse(response)) {
        clearApplyForm();
        await loadCreditNotes();
        await loadCreditNoteById(cnId);
        await loadApplications(cnId);
        toastSuccess('Credit note applied successfully.');
        return true;
      }
      toastApiError(response, 'Failed to apply credit note.');
    } catch (e) {
      toastValidation('Error applying credit note: $e');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  // ─────────────────────────────────────────────
  // Clear Helpers
  // ─────────────────────────────────────────────

  void clearForm() {
    selectedBookingId.value  = null;
    selectedInvoiceId.value  = null;
    selectedClientId.value   = null;
    creditType.value         = 'Hold';
    amountCtrl.clear();
    reasonCtrl.clear();
    creditDateCtrl.clear();
    // Shared with the Apply screen — don't carry another booking's invoices.
    targetInvoices.clear();
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
