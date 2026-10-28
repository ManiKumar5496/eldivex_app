import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/active_booking_client_model.dart';
import '../models/provisional_receipt_model.dart';
import '../models/client_statement_model.dart';
import '../models/write_off_model.dart';
import '../models/invoice_model.dart';
import '../models/credit_note_model.dart';
import '../models/insurance_claim_model.dart';
import '../models/parse_utils.dart';
import '../views/accounts_format.dart' as fmt;
import 'accounts_feedback.dart';

/// Default payment terms (days) sent to bulkGenerateInvoices when the org
/// profile does not configure its own.
const int kDefaultPaymentTermsDays = 15;

class GroupedClient {
  final int userId;
  final String clientName;
  final String clientMobile;
  final List<ClientStatement> bookings;

  GroupedClient({
    required this.userId,
    required this.clientName,
    required this.clientMobile,
    required this.bookings,
  });

  double get totalBilled    => bookings.fold(0.0, (s, b) => s + b.totalBilled);
  double get totalReceived  => bookings.fold(0.0, (s, b) => s + b.totalReceived);
  double get closingBalance => bookings.fold(0.0, (s, b) => s + b.closingBalance);
}

class AccountsController extends GetxController {
  // ─────────────────────────────────────────────
  // Loading States
  // ─────────────────────────────────────────────
  RxBool isLoadingClients = false.obs;
  RxBool isLoadingReceipts = false.obs;
  RxBool isLoadingStatements = false.obs;
  RxBool isLoadingWriteOffs = false.obs;
  RxBool isFilterVisible = false.obs;

  // ─────────────────────────────────────────────
  // Data Lists
  // ─────────────────────────────────────────────
  RxList<ActiveBookingClient> activeClients = <ActiveBookingClient>[].obs;
  RxList<ActiveBookingClient> filteredClients = <ActiveBookingClient>[].obs;

  RxList<ProvisionalReceipt> receipts = <ProvisionalReceipt>[].obs;
  RxList<ProvisionalReceipt> filteredReceipts = <ProvisionalReceipt>[].obs;

  RxList<ClientStatement> statements = <ClientStatement>[].obs;
  RxList<ClientStatement> filteredStatements = <ClientStatement>[].obs;

  RxList<WriteOffModel> writeOffs = <WriteOffModel>[].obs;
  RxList<WriteOffModel> filteredWriteOffs = <WriteOffModel>[].obs;

  // ─────────────────────────────────────────────
  // Search Controllers
  // ─────────────────────────────────────────────
  final TextEditingController searchClientController = TextEditingController();
  final TextEditingController searchReceiptController = TextEditingController();
  final TextEditingController searchStatementController =
      TextEditingController();
  final TextEditingController searchWriteOffController =
      TextEditingController();

  // ─────────────────────────────────────────────
  // Filter Controllers
  // ─────────────────────────────────────────────
  final TextEditingController filterBookingIdController =
      TextEditingController();
  final TextEditingController filterClientNameController =
      TextEditingController();
  final TextEditingController filterMobileController = TextEditingController();
  RxString filterStatus = ''.obs;
  RxString filterCity = ''.obs;

  // ─────────────────────────────────────────────
  // Record Payment Form Controllers
  // ─────────────────────────────────────────────
  Rx<InvoiceModel?> selectedInvoiceForPayment = Rx<InvoiceModel?>(null);
  final TextEditingController recordPaymentAmountController =
      TextEditingController();
  RxString recordPaymentMode = ''.obs;
  final TextEditingController recordTransactionIdController =
      TextEditingController();
  final TextEditingController recordPaymentRemarksController =
      TextEditingController();

  List<InvoiceModel> get invoicesWithBalance =>
      invoices.where((i) => i.balanceDue > 0).toList();

  // Groups filteredStatements by userId so clients with multiple bookings
  // appear as a single row in the statement list.
  List<GroupedClient> get groupedFilteredStatements {
    final Map<int, List<ClientStatement>> byUser = {};
    for (final s in filteredStatements) {
      byUser.putIfAbsent(s.userId, () => []).add(s);
    }
    return byUser.entries.map((e) {
      final stmts = e.value;
      return GroupedClient(
        userId:       e.key,
        clientName:   stmts.first.clientName,
        clientMobile: stmts.first.clientMobile,
        bookings:     stmts,
      );
    }).toList();
  }

  /// Pre-selects the oldest invoice with a balance for [bookingId] (if any)
  /// so the record-payment sheet opens on it.
  void selectInvoiceForBooking(int bookingId) {
    final open = invoicesWithBalance.where((i) => i.bookingId == bookingId).toList()
      ..sort((a, b) => a.invoiceDbId.compareTo(b.invoiceDbId));
    if (open.isEmpty) {
      selectedInvoiceForPayment.value = null;
      recordPaymentAmountController.clear();
    } else {
      selectInvoiceForPayment(open.first);
    }
  }

  void selectInvoiceForPayment(InvoiceModel inv) {
    selectedInvoiceForPayment.value = inv;
    recordPaymentAmountController.text = inv.balanceDue.toStringAsFixed(2);
  }

  // ─────────────────────────────────────────────
  // Write-Off Form Controllers
  // ─────────────────────────────────────────────
  final TextEditingController writeOffAmountController =
      TextEditingController();
  final TextEditingController writeOffReasonController =
      TextEditingController();
  final TextEditingController writeOffRemarksController =
      TextEditingController();
  RxString writeOffApprover = ''.obs;
  Rx<ActiveBookingClient?> selectedClientForWriteOff =
      Rx<ActiveBookingClient?>(null);

  // ─────────────────────────────────────────────
  // Invoices
  // ─────────────────────────────────────────────
  RxBool isLoadingInvoices = false.obs;
  RxList<InvoiceModel> invoices         = <InvoiceModel>[].obs;
  RxList<InvoiceModel> filteredInvoices = <InvoiceModel>[].obs;
  RxString invoiceStatusFilter          = ''.obs;
  final TextEditingController searchInvoiceController = TextEditingController();

  // ─────────────────────────────────────────────
  // Credit Notes
  // ─────────────────────────────────────────────
  RxBool isLoadingCreditNotes          = false.obs;
  RxList<CreditNoteModel> creditNotes         = <CreditNoteModel>[].obs;
  RxList<CreditNoteModel> filteredCreditNotes = <CreditNoteModel>[].obs;
  RxString selectedCreditNoteFilter           = 'All'.obs;

  // ─────────────────────────────────────────────
  // Insurance Claims
  // ─────────────────────────────────────────────
  RxBool isLoadingClaims              = false.obs;
  RxList<InsuranceClaimModel> claims         = <InsuranceClaimModel>[].obs;
  RxList<InsuranceClaimModel> filteredClaims = <InsuranceClaimModel>[].obs;
  // Insurance claim form controllers
  final TextEditingController claimTpaNameController      = TextEditingController();
  final TextEditingController claimPolicyNumberController = TextEditingController();
  final TextEditingController claimPreAuthController      = TextEditingController();
  final TextEditingController claimAmountController       = TextEditingController();
  final TextEditingController claimRemarksController      = TextEditingController();
  RxString claimStatus                                    = 'Pending'.obs;
  Rx<ActiveBookingClient?> selectedClientForClaim         = Rx<ActiveBookingClient?>(null);

  // ─────────────────────────────────────────────
  // Collections KPIs
  // ─────────────────────────────────────────────
  RxBool isLoadingKPIs   = false.obs;
  RxDouble totalBilled      = 0.0.obs;
  RxDouble totalCollected   = 0.0.obs;
  RxDouble totalOutstanding = 0.0.obs;
  RxInt    collectionRate   = 0.obs;   // percentage
  RxInt    dso              = 0.obs;   // days sales outstanding
  RxInt    overdueCount     = 0.obs;
  RxDouble overdueAmount    = 0.0.obs;

  // ─────────────────────────────────────────────
  // AR Aging
  // ─────────────────────────────────────────────
  RxBool isLoadingAging = false.obs;
  // Each entry: { label, count, amount }
  RxList<Map<String, dynamic>> agingBuckets = <Map<String, dynamic>>[].obs;

  // ─────────────────────────────────────────────
  // Revenue Recognition
  // ─────────────────────────────────────────────
  RxBool isLoadingRevenue = false.obs;
  RxInt    mrr           = 0.obs;
  RxInt    arr           = 0.obs;
  RxInt    deferred      = 0.obs;
  RxInt    recognized    = 0.obs;
  RxInt    collected     = 0.obs;
  RxInt    churnCount    = 0.obs;
  RxInt    activeCount   = 0.obs;
  /// True once revenue data has been fetched at least once.
  RxBool   revenueLoaded = false.obs;
  /// Set on the first request so the view triggers a single auto-fetch.
  bool     revenueRequested = false;

  /// Payment terms from the org profile, else [kDefaultPaymentTermsDays].
  Future<int> _orgPaymentTermsDays() async {
    try {
      final r = await _api.getRaw(ApiConstants.orgProfileApi);
      if (isOkResponse(r)) {
        final days = toIntOrNull(field(r!.data, 'payment_terms_days'));
        if (days != null && days > 0) return days;
      }
    } catch (_) {}
    return kDefaultPaymentTermsDays;
  }

  // ─────────────────────────────────────────────
  // Period Closing
  // ─────────────────────────────────────────────
  RxList<Map<String, dynamic>> closedPeriods = <Map<String, dynamic>>[].obs;

  // ─────────────────────────────────────────────
  // Bulk Invoice Generation
  // ─────────────────────────────────────────────
  RxBool isBulkGenerating = false.obs;

  // ─────────────────────────────────────────────
  // Selected Statement
  // ─────────────────────────────────────────────
  Rx<ClientStatement?> selectedStatement = Rx<ClientStatement?>(null);

  // ─────────────────────────────────────────────
  // Dropdown Options
  // ─────────────────────────────────────────────
  final List<String> paymentModes = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Cheque',
    'Credit Card',
    'Debit Card',
  ];

  final List<String> statusOptions = [
    'All',
    'Active',
    'On Hold',
    'Completed',
  ];

  final List<String> approverList = [
    'Admin',
    'Finance Manager',
    'Branch Manager',
    'Operations Head',
  ];

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────
  final ApiService _api = ApiService();

  @override
  void onInit() {
    super.onInit();
    // statements depend on activeClients data — chain after client fetch
    fetchActiveClients().then((_) => fetchStatements());
    fetchReceipts();
    fetchWriteOffs();
    fetchInvoices();
    fetchCollectionsKPIs();
    fetchAgingReport();
    fetchCreditNotes();
    fetchInsuranceClaims();
    fetchClosedPeriods();
  }

  @override
  void onClose() {
    searchClientController.dispose();
    searchReceiptController.dispose();
    searchStatementController.dispose();
    searchWriteOffController.dispose();
    searchInvoiceController.dispose();
    filterBookingIdController.dispose();
    filterClientNameController.dispose();
    filterMobileController.dispose();
    recordPaymentAmountController.dispose();
    recordTransactionIdController.dispose();
    recordPaymentRemarksController.dispose();
    writeOffAmountController.dispose();
    writeOffReasonController.dispose();
    writeOffRemarksController.dispose();
    claimTpaNameController.dispose();
    claimPolicyNumberController.dispose();
    claimPreAuthController.dispose();
    claimAmountController.dispose();
    claimRemarksController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // API Fetch Methods
  // ─────────────────────────────────────────────

  Future<void> fetchActiveClients() async {
    isLoadingClients.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getActiveClients);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          activeClients.value = ActiveBookingClient.listFromJson(data);
        } else {
          activeClients.value = [];
        }
        filteredClients.value = List.from(activeClients);
      } else {
        toastApiError(response, 'Failed to load clients.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading clients: $e');
    } finally {
      isLoadingClients.value = false;
    }
  }

  Future<void> fetchReceipts() async {
    isLoadingReceipts.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getReceipts());
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          receipts.value = ProvisionalReceipt.listFromJson(data);
        } else {
          receipts.value = [];
        }
        filteredReceipts.value = List.from(receipts);
      } else {
        toastApiError(response, 'Failed to load receipts.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading receipts: $e');
    } finally {
      isLoadingReceipts.value = false;
    }
  }

  Future<void> fetchStatements({int? bookingId, int? userId}) async {
    isLoadingStatements.value = true;
    try {
      if (bookingId == null && userId == null) {
        // Populate summary list from already-loaded active clients
        statements.value = activeClients.map(_clientToStatement).toList();
        filteredStatements.value = List.from(statements);
        return;
      }

      String url = ApiConstants.getClientStatements;
      if (bookingId != null) url += '?booking_id=$bookingId';
      if (userId != null) url += '${bookingId != null ? '&' : '?'}user_id=$userId';
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          final txns = data
              .map((e) => StatementTransaction.fromJson(e as Map<String, dynamic>))
              .toList();
          final isMultiBooking = bookingId == null && userId != null;
          final client = isMultiBooking
              ? activeClients.firstWhereOrNull((c) => c.userId == userId)
              : activeClients.firstWhereOrNull((c) => c.bookingId == bookingId);
          final userClients = isMultiBooking
              ? activeClients.where((c) => c.userId == userId).toList()
              : <ActiveBookingClient>[];
          final totalDebit  = txns.fold(0.0, (s, t) => s + t.debit);
          final totalCredit = txns.fold(0.0, (s, t) => s + t.credit);
          selectedStatement.value = ClientStatement(
            id:            bookingId ?? userId ?? 0,
            userId:        client?.userId ?? userId ?? 0,
            bookingId:     bookingId ?? 0,
            clientName:    client?.clientName ?? '',
            clientMobile:  client?.clientMobile ?? '',
            patientName:   isMultiBooking
                ? userClients.map((c) => c.patientName).toSet().join(', ')
                : (client?.patientName ?? ''),
            serviceName:   isMultiBooking
                ? '${userClients.length} booking${userClients.length == 1 ? '' : 's'}'
                : (client?.serviceName ?? ''),
            transactions:  txns,
            totalBilled:   totalDebit,
            totalReceived: totalCredit,
            totalWriteOff: 0,
            closingBalance: totalDebit - totalCredit,
          );
        }
      } else {
        toastApiError(response, 'Failed to load statement.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading statements: $e');
    } finally {
      isLoadingStatements.value = false;
    }
  }

  ClientStatement _clientToStatement(ActiveBookingClient c) {
    return ClientStatement(
      id:            c.bookingId,
      userId:        c.userId,
      bookingId:     c.bookingId,
      clientName:    c.clientName,
      clientMobile:  c.clientMobile,
      patientName:   c.patientName,
      serviceName:   c.serviceName,
      transactions:  [],
      totalBilled:   c.totalBilled,
      totalReceived: c.totalPaid,
      totalWriteOff: 0,
      closingBalance: c.outstandingAmount,
    );
  }

  Future<void> viewStatementForClient(ActiveBookingClient client) async {
    // Show summary immediately, then load full transaction history
    selectedStatement.value = _clientToStatement(client);
    await fetchStatements(bookingId: client.bookingId);
  }

  Future<void> viewStatementForUser(GroupedClient group) async {
    final userClients = activeClients.where((c) => c.userId == group.userId).toList();
    // Show combined summary immediately while the API loads
    selectedStatement.value = ClientStatement(
      id:            group.userId,
      userId:        group.userId,
      bookingId:     0,
      clientName:    group.clientName,
      clientMobile:  group.clientMobile,
      patientName:   userClients.map((c) => c.patientName).toSet().join(', '),
      serviceName:   '${userClients.length} booking${userClients.length == 1 ? '' : 's'}',
      transactions:  [],
      totalBilled:   group.totalBilled,
      totalReceived: group.totalReceived,
      totalWriteOff: 0,
      closingBalance: group.closingBalance,
    );
    await fetchStatements(userId: group.userId);
  }

  Future<void> fetchWriteOffs() async {
    isLoadingWriteOffs.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getWriteOffs());
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          writeOffs.value = WriteOffModel.listFromJson(data);
        } else {
          writeOffs.value = [];
        }
        filteredWriteOffs.value = List.from(writeOffs);
      } else {
        toastApiError(response, 'Failed to load write-offs.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading write-offs: $e');
    } finally {
      isLoadingWriteOffs.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Search & Filter Methods
  // ─────────────────────────────────────────────
  void searchClients(String query) {
    if (query.isEmpty) {
      filteredClients.value = List.from(activeClients);
    } else {
      final q = query.toLowerCase();
      filteredClients.value = activeClients.where((c) {
        return c.clientName.toLowerCase().contains(q) ||
            c.clientMobile.contains(q) ||
            c.patientName.toLowerCase().contains(q) ||
            c.bookingId.toString().contains(q) ||
            c.serviceName.toLowerCase().contains(q);
      }).toList();
    }
  }

  void searchReceipts(String query) {
    if (query.isEmpty) {
      filteredReceipts.value = List.from(receipts);
    } else {
      final q = query.toLowerCase();
      filteredReceipts.value = receipts.where((r) {
        return r.clientName.toLowerCase().contains(q) ||
            r.receiptNumber.toLowerCase().contains(q) ||
            r.clientMobile.contains(q) ||
            r.patientName.toLowerCase().contains(q);
      }).toList();
    }
  }

  void searchStatements(String query) {
    if (query.isEmpty) {
      filteredStatements.value = List.from(statements);
    } else {
      final q = query.toLowerCase();
      filteredStatements.value = statements.where((s) {
        return s.clientName.toLowerCase().contains(q) ||
            s.clientMobile.contains(q) ||
            s.patientName.toLowerCase().contains(q) ||
            s.bookingId.toString().contains(q);
      }).toList();
    }
  }

  void searchWriteOffs(String query) {
    if (query.isEmpty) {
      filteredWriteOffs.value = List.from(writeOffs);
    } else {
      final q = query.toLowerCase();
      filteredWriteOffs.value = writeOffs.where((w) {
        return w.clientName.toLowerCase().contains(q) ||
            w.clientMobile.contains(q) ||
            w.patientName.toLowerCase().contains(q) ||
            w.bookingId.toString().contains(q);
      }).toList();
    }
  }

  void applyClientFilters() {
    filteredClients.value = activeClients.where((c) {
      bool match = true;
      if (filterBookingIdController.text.isNotEmpty) {
        match = match &&
            c.bookingId.toString().contains(filterBookingIdController.text);
      }
      if (filterClientNameController.text.isNotEmpty) {
        match = match &&
            c.clientName
                .toLowerCase()
                .contains(filterClientNameController.text.toLowerCase());
      }
      if (filterMobileController.text.isNotEmpty) {
        match = match && c.clientMobile.contains(filterMobileController.text);
      }
      if (filterStatus.value.isNotEmpty && filterStatus.value != 'All') {
        match = match && c.status == filterStatus.value;
      }
      if (filterCity.value.isNotEmpty) {
        match = match &&
            c.city.toLowerCase().contains(filterCity.value.toLowerCase());
      }
      return match;
    }).toList();
  }

  void clearFilters() {
    filterBookingIdController.clear();
    filterClientNameController.clear();
    filterMobileController.clear();
    filterStatus.value = '';
    filterCity.value = '';
    filteredClients.value = List.from(activeClients);
  }

  // ─────────────────────────────────────────────
  // Receipt Actions
  // ─────────────────────────────────────────────
  void clearRecordPaymentForm() {
    selectedInvoiceForPayment.value = null;
    recordPaymentAmountController.clear();
    recordTransactionIdController.clear();
    recordPaymentRemarksController.clear();
    recordPaymentMode.value = '';
  }

  Future<bool> _confirm(String title, String message,
      {String confirmLabel = 'Confirm', Color color = Colors.orange}) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(confirmLabel,
                style: TextStyle(color: AppColor.buttonTextWhite)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  /// PATCH /updateReceiptStatus — approves an existing Pending receipt
  /// (does not create a new one).
  Future<void> approveReceipt(ProvisionalReceipt receipt) async {
    final ok = await _confirm(
      'Approve Receipt',
      'Approve ${receipt.receiptNumber.isNotEmpty ? receipt.receiptNumber : 'receipt #${receipt.id}'} '
          'for ${formatCurrency(receipt.totalAmount)}?',
      confirmLabel: 'Approve',
      color: Colors.green,
    );
    if (!ok) return;
    await _updateReceiptStatus(receipt.id, 'Approved', 'Receipt approved.');
  }

  Future<void> _updateReceiptStatus(int id, String status, String successMsg) async {
    isLoadingReceipts.value = true;
    try {
      final response = await _api.patchRaw(ApiConstants.updateReceiptStatus, {
        'id': id, 'status': status,
      });
      if (isOkResponse(response)) {
        await fetchReceipts();
        fetchActiveClients();
        fetchInvoices();
        fetchCollectionsKPIs();
        toastSuccess(successMsg);
      } else {
        toastApiError(response, 'Failed to update receipt.');
      }
    } catch (e) {
      toastValidation('Error updating receipt: $e');
    } finally {
      isLoadingReceipts.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Direct Payment: Invoice → create receipt + approve in one step
  // ─────────────────────────────────────────────
  Future<void> recordDirectPayment() async {
    final inv = selectedInvoiceForPayment.value;
    if (inv == null) {
      HelperUi.showToast(
          message: 'Please select an invoice', backgroundColor: Colors.red);
      return;
    }
    if (recordPaymentAmountController.text.isEmpty) {
      HelperUi.showToast(
          message: 'Please enter payment amount', backgroundColor: Colors.red);
      return;
    }
    if (recordPaymentMode.value.isEmpty) {
      HelperUi.showToast(
          message: 'Please select payment mode', backgroundColor: Colors.red);
      return;
    }

    final client =
        activeClients.firstWhereOrNull((c) => c.bookingId == inv.bookingId);
    if (client == null) {
      HelperUi.showToast(
        message: 'Client data not found for this invoice. Please refresh.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final amount = double.tryParse(recordPaymentAmountController.text) ?? 0;
    if (amount <= 0) {
      HelperUi.showToast(
          message: 'Amount must be greater than zero',
          backgroundColor: Colors.red);
      return;
    }

    isLoadingReceipts.value = true;
    try {
      // Single API call — backend creates receipt as Approved directly
      final resp = await _api.postRaw(ApiConstants.createReceipt, {
        'booking_id': client.bookingId,
        'user_id': client.userId,
        'amount': amount,
        'tax_amount': 0,
        'payment_mode': recordPaymentMode.value,
        'transaction_id': recordTransactionIdController.text.trim(),
        'remarks': recordPaymentRemarksController.text.trim(),
        'period_from': inv.periodFrom,
        'period_to': inv.periodTo,
      });

      if (!isOkResponse(resp)) {
        toastApiError(resp, 'Failed to record payment.');
        return;
      }

      clearRecordPaymentForm();
      await fetchReceipts();
      await fetchInvoices();
      fetchActiveClients();
      fetchCollectionsKPIs();
      HelperUi.showToast(
        message: 'Payment of ${formatCurrency(amount)} recorded against ${inv.invoiceId}.',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      HelperUi.showToast(message: 'Error recording payment: $e');
    } finally {
      isLoadingReceipts.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Statement Actions
  // ─────────────────────────────────────────────
  void viewStatement(ClientStatement statement) {
    selectedStatement.value = statement;
  }

  void closeStatementDetail() {
    selectedStatement.value = null;
  }

  // ─────────────────────────────────────────────
  // Write-Off Actions
  // ─────────────────────────────────────────────
  void selectClientForWriteOff(ActiveBookingClient client) {
    selectedClientForWriteOff.value = client;
  }

  bool validateWriteOffForm() {
    if (selectedClientForWriteOff.value == null) {
      HelperUi.showToast(
          message: 'Please select a client', backgroundColor: Colors.red);
      return false;
    }
    if (writeOffAmountController.text.isEmpty) {
      HelperUi.showToast(
          message: 'Please enter write-off amount',
          backgroundColor: Colors.red);
      return false;
    }
    if (writeOffReasonController.text.isEmpty) {
      HelperUi.showToast(
          message: 'Please enter reason', backgroundColor: Colors.red);
      return false;
    }
    if (writeOffApprover.value.isEmpty) {
      HelperUi.showToast(
          message: 'Please select approver', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  Future<void> createWriteOff() async {
    if (!validateWriteOffForm()) return;

    final client = selectedClientForWriteOff.value!;
    final amount = double.tryParse(writeOffAmountController.text) ?? 0;

    // Guard: amount must be positive
    if (amount <= 0) {
      HelperUi.showToast(
        message: 'Write-off amount must be greater than zero.',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Guard: amount cannot exceed outstanding balance
    if (amount > client.outstandingAmount) {
      HelperUi.showToast(
        message: 'Write-off amount (₹${amount.toStringAsFixed(2)}) exceeds outstanding balance '
            '(₹${client.outstandingAmount.toStringAsFixed(2)}).',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Guard: no pending write-off already exists for this booking
    final hasPending = writeOffs.any(
        (w) => w.bookingId == client.bookingId && w.status == 'Pending');
    if (hasPending) {
      HelperUi.showToast(
        message: 'A pending write-off already exists for this booking. Approve or reject it first.',
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Confirm before submitting
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Write-Off'),
        content: Text(
          'This will create a write-off of ₹${amount.toStringAsFixed(2)} '
          'for ${client.clientName} (Booking #${client.bookingId}).\n\nProceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    isLoadingWriteOffs.value = true;
    try {
      final response = await _api.postRaw(ApiConstants.createWriteOff, {
        'booking_id':       client.bookingId,
        'user_id':          client.userId,
        'write_off_amount': amount,
        'reason':           writeOffReasonController.text.trim(),
        'remarks':          writeOffRemarksController.text.trim(),
        'approved_by':      writeOffApprover.value,
      });

      if (isOkResponse(response)) {
        _clearWriteOffForm();
        await fetchWriteOffs();
        HelperUi.showToast(
          message: 'Write-off request created successfully.',
          backgroundColor: Colors.green,
        );
      } else {
        toastApiError(response, 'Failed to create write-off. Please try again.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error creating write-off: $e');
    } finally {
      isLoadingWriteOffs.value = false;
    }
  }

  void _clearWriteOffForm() {
    selectedClientForWriteOff.value = null;
    writeOffAmountController.clear();
    writeOffReasonController.clear();
    writeOffRemarksController.clear();
    writeOffApprover.value = '';
  }

  Future<void> approveWriteOff(int id) =>
      _updateWriteOffStatus(id, 'Approved');

  Future<void> rejectWriteOff(int id) =>
      _updateWriteOffStatus(id, 'Rejected');

  /// PATCH /updateWriteOffStatus { id, status: Approved | Rejected }
  Future<void> _updateWriteOffStatus(int id, String status) async {
    final approving = status == 'Approved';
    final ok = await _confirm(
      approving ? 'Approve Write-Off' : 'Reject Write-Off',
      '${approving ? 'Approve' : 'Reject'} write-off #$id?',
      confirmLabel: approving ? 'Approve' : 'Reject',
      color: approving ? Colors.green : Colors.red,
    );
    if (!ok) return;
    try {
      final response = await _api.patchRaw(ApiConstants.updateWriteOffStatus, {
        'id': id, 'status': status,
      });
      if (isOkResponse(response)) {
        await fetchWriteOffs();
        fetchActiveClients();
        toastSuccess('Write-off ${status.toLowerCase()}.');
      } else {
        toastApiError(response, 'Failed to update write-off.');
      }
    } catch (e) {
      toastValidation('Error: $e');
    }
  }

  /// PATCH /updateReceiptStatus { id, status: Cancelled } after confirmation.
  Future<void> cancelReceipt(int id) async {
    final ok = await _confirm(
      'Cancel Receipt',
      'Cancel receipt #$id? This cannot be undone.',
      confirmLabel: 'Cancel Receipt',
      color: Colors.red,
    );
    if (!ok) return;
    await _updateReceiptStatus(id, 'Cancelled', 'Receipt cancelled.');
  }

  // ─────────────────────────────────────────────
  // Invoice Methods
  // ─────────────────────────────────────────────
  Future<void> fetchInvoices({String? status}) async {
    isLoadingInvoices.value = true;
    try {
      final url = ApiConstants.getInvoices(status: status);
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          invoices.value = InvoiceModel.listFromJson(data);
        } else {
          invoices.value = [];
        }
        _applyInvoiceFilter();
      } else {
        toastApiError(response, 'Failed to load invoices.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading invoices: $e');
    } finally {
      isLoadingInvoices.value = false;
    }
  }

  void searchInvoices(String query) {
    _applyInvoiceFilter(search: query);
  }

  void _applyInvoiceFilter({String? search}) {
    final q = (search ?? searchInvoiceController.text).toLowerCase();
    var result = invoices.toList();
    if (q.isNotEmpty) {
      result = result.where((inv) =>
        inv.invoiceId.toLowerCase().contains(q) ||
        inv.bookingId.toString().contains(q) ||
        inv.clientName.toLowerCase().contains(q) ||
        inv.clientMobile.contains(q) ||
        (inv.patientName).toLowerCase().contains(q)
      ).toList();
    }
    if (invoiceStatusFilter.value.isNotEmpty) {
      result = result.where((inv) => inv.status == invoiceStatusFilter.value).toList();
    }
    filteredInvoices.value = result;
  }

  Future<void> sendPaymentLink(InvoiceModel invoice) async {
    try {
      final response = await _api.postRaw(ApiConstants.createPaymentLink, {
        'invoice_id': invoice.invoiceDbId,
        'amount':     invoice.balanceDue,
      });
      if (isOkResponse(response)) {
        final linkUrl = field(response!.data, 'link_url');
        HelperUi.showToast(
          message: 'Payment link created: $linkUrl',
          backgroundColor: Colors.green,
        );
      } else {
        toastApiError(response, 'Failed to create payment link.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error creating payment link: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Collections KPIs
  // ─────────────────────────────────────────────
  Future<void> fetchCollectionsKPIs() async {
    isLoadingKPIs.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getCollectionsKPIs);
      if (response != null && response.statusCode == 200) {
        final d = response.data;
        totalBilled.value      = toDouble(field(d, 'total_billed'));
        totalCollected.value   = toDouble(field(d, 'total_collected'));
        totalOutstanding.value = toDouble(field(d, 'total_outstanding'));
        collectionRate.value   = toInt(field(d, 'collection_rate'));
        dso.value              = toInt(field(d, 'dso'));
        overdueCount.value     = toInt(field(d, 'overdue_count'));
        overdueAmount.value    = toDouble(field(d, 'overdue_amount'));
      }
    } catch (e) {
      // Non-critical — silently ignore
    } finally {
      isLoadingKPIs.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // AR Aging
  // ─────────────────────────────────────────────
  Future<void> fetchAgingReport() async {
    isLoadingAging.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getAgingReport);
      if (response != null && response.statusCode == 200) {
        final bucketsMap = field(response.data, 'buckets');
        agingBuckets.value = bucketsMap is Map
            ? bucketsMap.values
                .whereType<Map>()
                .map((v) => Map<String, dynamic>.from(v))
                .toList()
            : <Map<String, dynamic>>[];
      }
    } catch (e) {
      // Non-critical
    } finally {
      isLoadingAging.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Credit Notes
  // ─────────────────────────────────────────────
  Future<void> fetchCreditNotes({int? bookingId}) async {
    isLoadingCreditNotes.value = true;
    try {
      final url = ApiConstants.getCreditNotes(bookingId?.toString());
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          creditNotes.value = CreditNoteModel.listFromJson(data);
          filteredCreditNotes.value = List.from(creditNotes);
        }
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading credit notes: $e');
    } finally {
      isLoadingCreditNotes.value = false;
    }
  }

  Future<void> approveCreditNote(int id) => _updateCreditNoteStatus(id, 'Approved');

  Future<void> rejectCreditNote(int id) => _updateCreditNoteStatus(id, 'Rejected');

  /// PATCH /updateCreditNoteStatus { id, status: Approved | Rejected }
  Future<void> _updateCreditNoteStatus(int id, String status) async {
    try {
      final response = await _api.patchRaw(ApiConstants.updateCreditNoteStatus, {
        'id': id, 'status': status,
      });
      if (isOkResponse(response)) {
        await fetchCreditNotes();
        toastSuccess('Credit note ${status.toLowerCase()}.');
      } else {
        toastApiError(response, 'Failed to update credit note.');
      }
    } catch (e) {
      toastValidation('Error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Insurance Claims
  // ─────────────────────────────────────────────
  Future<void> fetchInsuranceClaims({int? bookingId, String? status}) async {
    isLoadingClaims.value = true;
    try {
      String url = ApiConstants.getInsuranceClaims;
      final params = <String>[];
      if (bookingId != null) params.add('booking_id=$bookingId');
      if (status    != null) params.add('status=$status');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          claims.value = InsuranceClaimModel.listFromJson(data);
          filteredClaims.value = List.from(claims);
        }
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading claims: $e');
    } finally {
      isLoadingClaims.value = false;
    }
  }

  Future<void> createInsuranceClaim() async {
    final client = selectedClientForClaim.value;
    if (client == null) {
      HelperUi.showToast(message: 'Please select a client', backgroundColor: Colors.red);
      return;
    }
    isLoadingClaims.value = true;
    try {
      final response = await _api.postRaw(ApiConstants.createInsuranceClaim, {
        'booking_id':      client.bookingId,
        'user_id':         client.userId,
        'tpa_name':        claimTpaNameController.text.trim(),
        'policy_number':   claimPolicyNumberController.text.trim(),
        'pre_auth_number': claimPreAuthController.text.trim(),
        'claim_amount':    double.tryParse(claimAmountController.text) ?? 0,
        'remarks':         claimRemarksController.text.trim(),
      });
      if (isOkResponse(response)) {
        _clearClaimForm();
        await fetchInsuranceClaims();
        toastSuccess('Insurance claim created.');
      } else {
        toastApiError(response, 'Failed to create claim.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      isLoadingClaims.value = false;
    }
  }

  Future<void> updateClaimStatus(int id, String status, {double? settledAmount}) async {
    try {
      final body = <String, dynamic>{'id': id, 'status': status};
      if (settledAmount != null) body['settled_amount'] = settledAmount;
      final response = await _api.patchRaw(ApiConstants.updateInsuranceClaim, body);
      if (isOkResponse(response)) {
        await fetchInsuranceClaims();
        toastSuccess('Claim updated to $status.');
      } else {
        toastApiError(response, 'Failed to update claim.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    }
  }

  void _clearClaimForm() {
    selectedClientForClaim.value = null;
    claimTpaNameController.clear();
    claimPolicyNumberController.clear();
    claimPreAuthController.clear();
    claimAmountController.clear();
    claimRemarksController.clear();
    claimStatus.value = 'Pending';
  }

  // ─────────────────────────────────────────────
  // Bulk Invoice Generation
  // ─────────────────────────────────────────────
  Future<void> bulkGenerateInvoices({int? month, int? year, int? paymentTermsDays}) async {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear  = year  ?? now.year;

    // Guard: period must not be closed
    if (isPeriodClosed(targetMonth, targetYear)) {
      HelperUi.showToast(
        message: 'Period $targetMonth/$targetYear is closed. Invoices cannot be generated.',
        backgroundColor: Colors.red,
      );
      return;
    }

    isBulkGenerating.value = true;
    try {
      final response = await _api.postRaw(ApiConstants.bulkGenerateInvoices, {
        'month': targetMonth,
        'year':  targetYear,
        'payment_terms_days': paymentTermsDays ?? await _orgPaymentTermsDays(),
      });
      if (isOkResponse(response)) {
        final count = toInt(field(response!.data, 'generated'));
        await fetchInvoices();
        await fetchCollectionsKPIs();
        HelperUi.showToast(
          message: '$count invoice(s) generated for $targetMonth/$targetYear.',
          backgroundColor: Colors.green,
        );
      } else {
        toastApiError(response, 'Failed to generate invoices.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      isBulkGenerating.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Period Closing
  // ─────────────────────────────────────────────
  Future<void> fetchClosedPeriods() async {
    try {
      final response = await _api.getRaw(ApiConstants.getClosedPeriods);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          closedPeriods.value = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}
  }

  Future<void> closePeriod(int month, int year) async {
    try {
      final response = await _api.postRaw(ApiConstants.closePeriod, {
        'month': month, 'year': year,
      });
      if (isOkResponse(response)) {
        await fetchClosedPeriods();
        HelperUi.showToast(
          message: 'Period $month/$year closed successfully.',
          backgroundColor: Colors.green,
        );
      } else {
        toastApiError(response, 'Failed to close period.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    }
  }

  bool isPeriodClosed(int month, int year) {
    return closedPeriods.any((p) =>
      toInt(p['period_month']) == month && toInt(p['period_year']) == year
    );
  }

  // ─────────────────────────────────────────────
  // Revenue Recognition
  // ─────────────────────────────────────────────
  Future<void> fetchRevenueRecognition() async {
    revenueRequested = true;
    isLoadingRevenue.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getRevenueRecognition);
      if (response != null && response.statusCode == 200) {
        final d = response.data;
        mrr.value        = toInt(field(d, 'mrr'));
        arr.value        = toInt(field(d, 'arr'));
        deferred.value   = toInt(field(d, 'deferred'));
        recognized.value = toInt(field(d, 'recognized'));
        collected.value  = toInt(field(d, 'collected'));
        churnCount.value = toInt(field(d, 'churn_count'));
        activeCount.value= toInt(field(d, 'active_count'));
        revenueLoaded.value = true;
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error loading revenue data: $e');
    } finally {
      isLoadingRevenue.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  String formatCurrency(double amount) => fmt.formatInr(amount);

  String formatDate(DateTime? date) =>
      fmt.formatAccDate(date, pattern: 'dd-MMM-yyyy', empty: '-');

  Color getStatusColor(String status) => fmt.accountsStatusColor(status);
}
