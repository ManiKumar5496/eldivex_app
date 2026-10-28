import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../main.dart';
import 'package:eldivex_app/app/modules/support/models/get_all_support_tickets.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_support_categories.dart';

class SupportController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool updateSupportStatusLoading = false.obs;
  RxBool getSupportCategoriesLoading = false.obs;
  final TextEditingController supportCommentsController = TextEditingController();
  RxBool isCreateSupportLoading = false.obs;
  final ApiService baseApi = ApiService();
  RxList<GetAllSupportTickets> getAllSupportTicketsData =
      <GetAllSupportTickets>[].obs;
  // What the ticket list renders: the org-scoped tickets narrowed by the
  // search box and the status chip filter.
  RxList<GetAllSupportTickets> filteredSupportTickets =
      <GetAllSupportTickets>[].obs;
  final RxString ticketSearchQuery = ''.obs;
  // -1 = All, otherwise one of the edx_support_requests.status values below.
  final RxInt ticketStatusFilter = (-1).obs;
  final RxString loadError = ''.obs;

  // edx_support_requests.status: 1 = Open, 2 = In Progress, 3 = Resolved,
  // 0 = Closed (see getSupportStats / updateSupportStatus on the backend).
  static const int statusClosed = 0;
  static const int statusOpen = 1;
  static const int statusInProgress = 2;
  static const int statusResolved = 3;

  static String statusLabel(int status) {
    switch (status) {
      case statusOpen:
        return 'Open';
      case statusInProgress:
        return 'In Progress';
      case statusResolved:
        return 'Resolved';
      case statusClosed:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  static Color statusColor(int status) {
    switch (status) {
      case statusOpen:
        return Colors.blue;
      case statusInProgress:
        return Colors.orange;
      case statusResolved:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Category name for a ticket's support_type_id (falls back to the raw id).
  String categoryName(String supportTypeId) {
    final id = int.tryParse(supportTypeId);
    final match = getSupportCategoriesData.firstWhereOrNull((c) => c.id == id);
    final name = match?.name ?? '';
    if (name.isNotEmpty) return name;
    return (supportTypeId.isEmpty || supportTypeId == 'NA') ? '—' : 'Type $supportTypeId';
  }
  RxList<SupportCategory> getSupportCategoriesData =
      <SupportCategory>[].obs;
  RxInt openTickets = 0.obs;
  RxInt inProgressTickets = 0.obs;
  RxInt resolvedToday = 0.obs;
  RxString avgResponseTime = "—".obs;
  RxBool isStatsLoading = false.obs;
  RxString bookingId = ''.obs;
  RxString clientUserId = ''.obs;
  Rx<SupportCategory?> selectedTicketType = Rx<SupportCategory?>(null);

  // TextEditingControllers so text fields can be pre-filled programmatically
  final TextEditingController bookingIdTextController = TextEditingController();
  final TextEditingController clientUserIdTextController = TextEditingController();

  // Client looked up from User Id or Booking ID: name shown under User Id,
  // errors shown under the field that was looked up.
  final RxString clientName = ''.obs;
  final RxString clientPhone = ''.obs;
  final RxString userIdLookupError = ''.obs;
  final RxString bookingIdLookupError = ''.obs;
  final RxBool clientLookupLoading = false.obs;
  Timer? _lookupDebounce;
  // Bumped per lookup so a slow, older response never overwrites a newer one.
  int _lookupSeq = 0;

  // Ticket type to auto-select once categories load: a word its name contains
  // ('hold', 'cancel'). Category ids differ per org, so never match on id.
  String? _pendingPrefillTypeName;
  RxString priority = ''.obs;
  RxString subject = ''.obs;
  RxString description = ''.obs;
  final TextEditingController subjectTextController = TextEditingController();
  final TextEditingController descriptionTextController = TextEditingController();
  final TextEditingController reasonTextController = TextEditingController();
  // Route arguments already applied, so a rebuild never re-applies them.
  Object? _appliedPrefillArgs;

  // Dynamic fields based on ticket type
  Rx<DateTime?> holdStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> holdEndDate = Rx<DateTime?>(null);
  Rx<DateTime?> replacementPlannedDate = Rx<DateTime?>(null);
  Rx<DateTime?> lastServiceDate = Rx<DateTime?>(null);
  RxString cancellationReason = ''.obs;
  RxString replacementReason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getAllSupportTicketsApi();
    getAllSupportCategoriesApi();
    getSupportStatsApi();
  }

  @override
  void onClose() {
    _lookupDebounce?.cancel();
    supportCommentsController.dispose();
    bookingIdTextController.dispose();
    clientUserIdTextController.dispose();
    subjectTextController.dispose();
    descriptionTextController.dispose();
    reasonTextController.dispose();
    super.onClose();
  }

  // ── Pre-fill from bookings navigation ─────────────────────────────────────
  /// Called by [CreateSupportTicket] when opened via Get.to() with arguments.
  /// typeName is a word in the category name to auto-select ('hold', 'cancel').
  static int? _toIntOrNull(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  /// Apply {bookingId, userId, typeName} route arguments once per navigation.
  void applyPrefillArgs(Object? args) {
    if (args is! Map || identical(args, _appliedPrefillArgs)) return;
    _appliedPrefillArgs = args;
    final bookingId = _toIntOrNull(args['bookingId']);
    final userId = _toIntOrNull(args['userId']);
    if (bookingId == null || userId == null) return;
    prefillFromBooking(
      bookingId: bookingId,
      userId: userId,
      typeName: args['typeName']?.toString(),
    );
  }

  void prefillFromBooking({
    required int bookingId,
    required int userId,
    String? typeName,
  }) {
    bookingIdTextController.text = bookingId.toString();
    clientUserIdTextController.text = userId.toString();
    this.bookingId.value = bookingId.toString();
    clientUserId.value = userId.toString();
    _pendingPrefillTypeName = typeName?.toLowerCase();
    _applyPrefillType(); // apply immediately if categories already loaded
    _scheduleClientLookup(userId: userId, delay: Duration.zero);
  }

  // ── Client lookup (name under User Id, User Id from Booking ID) ───────────

  void onUserIdChanged(String value) {
    clientUserId.value = value;
    _scheduleClientLookup(userId: int.tryParse(value.trim()));
  }

  /// A valid Booking ID fills User Id from the booking; clearing it falls
  /// back to looking up whatever User Id is typed.
  void onBookingIdChanged(String value) {
    bookingId.value = value;
    final id = int.tryParse(value.trim());
    if (id != null) {
      _scheduleClientLookup(bookingId: id);
    } else {
      bookingIdLookupError.value = '';
      _scheduleClientLookup(userId: int.tryParse(clientUserId.value.trim()));
    }
  }

  void _resetClientLookup() {
    _lookupDebounce?.cancel();
    _lookupSeq++;
    clientName.value = '';
    clientPhone.value = '';
    userIdLookupError.value = '';
    bookingIdLookupError.value = '';
    clientLookupLoading.value = false;
  }

  void _scheduleClientLookup({
    int? userId,
    int? bookingId,
    Duration delay = const Duration(milliseconds: 400),
  }) {
    _resetClientLookup();
    if (userId == null && bookingId == null) return;
    final seq = _lookupSeq;
    clientLookupLoading.value = true;
    _lookupDebounce = Timer(
      delay,
      () => _lookupClient(seq, userId: userId, bookingId: bookingId),
    );
  }

  Future<void> _lookupClient(int seq, {int? userId, int? bookingId}) async {
    final response = await baseApi.getRaw(
      ApiConstants.getSupportClient(userId: userId, bookingId: bookingId),
    );
    if (seq != _lookupSeq) return; // a newer lookup has started
    clientLookupLoading.value = false;

    final data = response?.data;
    if (ApiService.isOk(response) && data is Map) {
      final foundId = _toIntOrNull(data['user_id']);
      clientName.value = data['user_name']?.toString().trim() ?? '';
      clientPhone.value = data['phone_number']?.toString().trim() ?? '';
      if (bookingId != null && foundId != null) {
        clientUserIdTextController.text = foundId.toString();
        clientUserId.value = foundId.toString();
      }
      return;
    }

    final notFound = response?.statusCode == 404;
    if (bookingId != null) {
      bookingIdLookupError.value = notFound
          ? 'No booking #$bookingId in your organisation'
          : 'Could not look up this booking';
    } else {
      userIdLookupError.value = notFound
          ? 'No client with User Id $userId'
          : 'Could not look up this client';
    }
  }

  void _applyPrefillType() {
    final word = _pendingPrefillTypeName;
    if (word == null || getSupportCategoriesData.isEmpty) return;
    final match = getSupportCategoriesData.firstWhereOrNull(
        (c) => (c.name ?? '').toLowerCase().contains(word));
    if (match != null) {
      selectedTicketType.value = match;
      _pendingPrefillTypeName = null;
    }
  }

  // Reset dynamic fields when ticket type changes
  void resetDynamicFields() {
    holdStartDate.value = null;
    holdEndDate.value = null;
    replacementPlannedDate.value = null;
    lastServiceDate.value = null;
    cancellationReason.value = '';
    replacementReason.value = '';
    reasonTextController.clear();
  }

  // Check if current ticket type requires specific fields
  bool get requiresHoldDates =>
      selectedTicketType.value?.name?.toLowerCase().contains('hold') ?? false;

  bool get requiresReplacementDate =>
      selectedTicketType.value?.name?.toLowerCase().contains('replacement') ?? false;

  bool get requiresCancellationDate =>
      selectedTicketType.value?.name?.toLowerCase().contains('cancel') ?? false;

  Future<void> getAllSupportTicketsApi() async {
    isLoading.value = true;
    loadError.value = '';

    try {
      final result = await baseApi.getList<GetAllSupportTickets>(
        ApiConstants.getSupportTicket,
            (json) => GetAllSupportTickets.fromJson(json),
      );

      if (result == null) {
        loadError.value =
            ApiService.lastError ?? 'Failed to fetch support tickets.';
      } else {
        // Newest first
        result.sort((a, b) => b.id.compareTo(a.id));
        getAllSupportTicketsData.value = result;
      }
      applyTicketFilters();
    } catch (e, stack) {
      debugPrint("Error fetching support tickets: $e");
      debugPrint("Stack trace: $stack");
      loadError.value = 'Failed to fetch support tickets.';
    } finally {
      isLoading.value = false;
    }
  }

  void searchTickets(String query) {
    ticketSearchQuery.value = query;
    applyTicketFilters();
  }

  void setTicketStatusFilter(int status) {
    ticketStatusFilter.value = status;
    applyTicketFilters();
  }

  void applyTicketFilters() {
    final q = ticketSearchQuery.value.toLowerCase().trim();
    final status = ticketStatusFilter.value;
    filteredSupportTickets.value = getAllSupportTicketsData.where((t) {
      final matchesSearch = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.bookingDetails.toLowerCase().contains(q) ||
          t.userId.toLowerCase().contains(q) ||
          categoryName(t.supportTypeId).toLowerCase().contains(q) ||
          t.id.toString().contains(q);
      final matchesStatus = status == -1 || t.status == status;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> getAllSupportCategoriesApi() async {
    getSupportCategoriesLoading.value = true;

    try {
      final result = await baseApi.getList<SupportCategory>(
        ApiConstants.getSupportCategories,
            (json) => SupportCategory.fromJson(json),
      );
      getSupportCategoriesData.value = result ?? [];
      // Keep the selection pointing at an item of the new list (dropdown
      // values must be one of its items).
      final sel = selectedTicketType.value;
      if (sel != null) {
        selectedTicketType.value =
            getSupportCategoriesData.firstWhereOrNull((c) => c.id == sel.id);
      }
      _applyPrefillType(); // auto-select type if prefill was requested before load
      applyTicketFilters(); // category names feed the search

      debugPrint("Support categories loaded: ${getSupportCategoriesData.length}");
    } catch (e, stack) {
      debugPrint("Error fetching support categories: $e");
      debugPrint("Stack trace: $stack");
      HelperUi.showToast(message: "Failed to fetch support categories.");
    } finally {
      getSupportCategoriesLoading.value = false;
    }
  }

  Future<void> getSupportStatsApi() async {
    isStatsLoading.value = true;
    try {
      final response = await baseApi.getRaw(ApiConstants.getSupportStats);
      if (ApiService.isOk(response) && response!.data is Map) {
        final data = response.data as Map;
        openTickets.value        = _toIntOrNull(data['open_tickets']) ?? 0;
        inProgressTickets.value  = _toIntOrNull(data['in_progress_tickets']) ?? 0;
        resolvedToday.value      = _toIntOrNull(data['resolved_today']) ?? 0;
        final avg = data['avg_response_hours']?.toString() ?? '';
        avgResponseTime.value    = (avg.isEmpty || avg == 'N/A') ? '—' : avg;
      }
    } catch (e, stack) {
      debugPrint("Error fetching support stats: $e");
      debugPrint("Stack trace: $stack");
    } finally {
      isStatsLoading.value = false;
    }
  }

  void _fail(String message) =>
      HelperUi.showToast(message: message, backgroundColor: Colors.red);

  bool validateFields() {
    if (int.tryParse(clientUserId.value.trim()) == null) {
      _fail("Please enter a valid numeric User ID");
      return false;
    }
    if (bookingId.value.trim().isEmpty) {
      _fail("Please enter Booking ID");
      return false;
    }
    if (selectedTicketType.value == null) {
      _fail("Please select Ticket Type");
      return false;
    }
    if (priority.value.isEmpty) {
      _fail("Please select Priority");
      return false;
    }
    if (subject.value.trim().length < 3) {
      _fail("Subject must be at least 3 characters");
      return false;
    }
    if (description.value.trim().length < 5) {
      _fail("Description must be at least 5 characters");
      return false;
    }

    // Validate dynamic fields
    if (requiresHoldDates) {
      if (holdStartDate.value == null) {
        _fail("Please select Hold Start Date");
        return false;
      }
      if (holdEndDate.value == null) {
        _fail("Please select Hold End Date");
        return false;
      }
      if (holdEndDate.value!.isBefore(holdStartDate.value!)) {
        _fail("Hold End Date must be after Start Date");
        return false;
      }
    }

    if (requiresReplacementDate && replacementPlannedDate.value == null) {
      _fail("Please select Replacement Planned Date");
      return false;
    }

    if (requiresCancellationDate && lastServiceDate.value == null) {
      _fail("Please select Last Service Date");
      return false;
    }

    return true;
  }

  String _errorText(dio.Response? r, String fallback) {
    final data = r?.data;
    if (data is Map) {
      final details = data['details'];
      if (details is List && details.isNotEmpty && details.first is Map) {
        final msg = (details.first as Map)['message'];
        if (msg != null) return msg.toString();
      }
      final msg = data['error'] ?? data['message'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    return ApiService.lastError ?? fallback;
  }

  String _isoDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  /// Returns true when the ticket was created.
  Future<bool> createSupportTicket() async {
    if (!validateFields()) return false;
    if (isCreateSupportLoading.value) return false;

    try {
      isCreateSupportLoading.value = true;

      // org_id comes from the JWT. The backend has no due_date / priority
      // columns, so priority travels in the comments; hold dates map to the
      // stored start_date / end_date.
      final requestBody = <String, dynamic>{
        "user_id": int.parse(clientUserId.value.trim()),
        "support_type_id": selectedTicketType.value!.id,
        "title": subject.value.trim(),
        "description": description.value.trim(),
        "comments": buildCommentsFromDynamicFields(),
        "booking_details": bookingId.value.trim(),
      };
      final employeeId = box.read("userId")?.toString();
      if (employeeId != null && employeeId.isNotEmpty) {
        requestBody["created_by_employee"] = employeeId;
      }
      if (requiresHoldDates &&
          holdStartDate.value != null &&
          holdEndDate.value != null) {
        requestBody["start_date"] = _isoDate(holdStartDate.value!);
        requestBody["end_date"] = _isoDate(holdEndDate.value!);
      }

      final response = await baseApi.postRaw(
        ApiConstants.createSupportTicket,
        requestBody,
      );

      if (ApiService.isOk(response)) {
        HelperUi.showToast(
            message: "Ticket Created Successfully", backgroundColor: Colors.green);
        clearForm();
        getAllSupportTicketsApi();
        getSupportStatsApi();
        return true;
      }
      _fail(_errorText(response, "Ticket creation failed. Please try again."));
      return false;
    } catch (error) {
      debugPrint("createSupportTicket error: $error");
      _fail("Something went wrong. Please try again.");
      return false;
    } finally {
      isCreateSupportLoading.value = false;
    }
  }

  String buildCommentsFromDynamicFields() {
    List<String> comments = [];

    if (priority.value.isNotEmpty) {
      comments.add("Priority: ${priority.value}");
    }

    if (requiresHoldDates) {
      comments.add("Hold Start Date: ${_formatDate(holdStartDate.value)}");
      comments.add("Hold End Date: ${_formatDate(holdEndDate.value)}");
    }

    if (requiresReplacementDate) {
      comments.add("Replacement Planned Date: ${_formatDate(replacementPlannedDate.value)}");
      if (replacementReason.value.isNotEmpty) {
        comments.add("Replacement Reason: ${replacementReason.value}");
      }
    }

    if (requiresCancellationDate) {
      comments.add("Last Service Date: ${_formatDate(lastServiceDate.value)}");
      if (cancellationReason.value.isNotEmpty) {
        comments.add("Cancellation Reason: ${cancellationReason.value}");
      }
    }

    return comments.join(" | ");
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Not specified";
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  void clearForm() {
    bookingId.value = '';
    clientUserId.value = '';
    bookingIdTextController.clear();
    clientUserIdTextController.clear();
    _resetClientLookup();
    selectedTicketType.value = null;
    priority.value = '';
    subject.value = '';
    description.value = '';
    subjectTextController.clear();
    descriptionTextController.clear();
    _pendingPrefillTypeName = null;
    resetDynamicFields();
  }

  /// PATCH /updateSupportStatus?id=<ticketId>&status=<s>&comments=<c>.
  /// Returns true on success; the caller closes its dialog only then.
  Future<bool> updateSupportStatus(int status, int ticketId) async {
    if (updateSupportStatusLoading.value) return false;
    updateSupportStatusLoading.value = true;
    try {
      final comments = supportCommentsController.text.trim();
      // Uri encodes the free-text comments (&, #, spaces, etc.).
      final uri = Uri.parse(ApiConstants.updateSupportTicketStatus).replace(
        queryParameters: {
          'id': ticketId.toString(),
          'status': status.toString(),
          if (comments.isNotEmpty) 'comments': comments,
        },
      );
      final response = await baseApi.patchApi(uri.toString());
      if (ApiService.isOk(response)) {
        HelperUi.showToast(
          message: "Ticket marked ${statusLabel(status)}.",
          backgroundColor: Colors.green,
        );
        supportCommentsController.clear();
        getAllSupportTicketsApi();
        getSupportStatsApi();
        return true;
      }
      _fail(_errorText(response, "Failed to update ticket status."));
      return false;
    } catch (error) {
      debugPrint("updateSupportStatus error: $error");
      _fail("Failed to update ticket status.");
      return false;
    } finally {
      updateSupportStatusLoading.value = false;
    }
  }
}
