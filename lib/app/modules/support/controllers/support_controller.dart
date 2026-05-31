import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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

  // Holds the typeId to auto-select after categories finish loading
  int? _pendingPrefillTypeId;
  RxString priority = ''.obs;
  RxString subject = ''.obs;
  RxString description = ''.obs;

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
    supportCommentsController.dispose();
    bookingIdTextController.dispose();
    clientUserIdTextController.dispose();
    super.onClose();
  }

  // ── Pre-fill from bookings navigation ─────────────────────────────────────
  /// Called by [CreateSupportTicket] when opened via Get.to() with arguments.
  /// [typeId] is the edx_support_category.id to auto-select (4=Hold, 5=Cancel).
  void prefillFromBooking({
    required int bookingId,
    required int userId,
    int? typeId,
  }) {
    bookingIdTextController.text = bookingId.toString();
    clientUserIdTextController.text = userId.toString();
    this.bookingId.value = bookingId.toString();
    clientUserId.value = userId.toString();
    _pendingPrefillTypeId = typeId;
    _applyPrefillType(); // apply immediately if categories already loaded
  }

  void _applyPrefillType() {
    if (_pendingPrefillTypeId == null) return;
    if (getSupportCategoriesData.isEmpty) return;
    final matches = getSupportCategoriesData
        .where((c) => c.id == _pendingPrefillTypeId);
    final match = matches.isEmpty ? null : matches.first;
    if (match != null) {
      selectedTicketType.value = match;
      _pendingPrefillTypeId = null;
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

    try {
      final result = await baseApi.getList<GetAllSupportTickets>(
        ApiConstants.getSupportTicket,
            (json) => GetAllSupportTickets.fromJson(json),
      );

      getAllSupportTicketsData.value = result ?? [];
      debugPrint("Support tickets loaded: ${getAllSupportTicketsData.length}");
    } catch (e, stack) {
      debugPrint("Error fetching support tickets: $e");
      debugPrint("Stack trace: $stack");
      HelperUi.showToast(message: "Failed to fetch support tickets.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllSupportCategoriesApi() async {
    getSupportCategoriesLoading.value = true;

    try {
      final result = await baseApi.getList<SupportCategory>(
        ApiConstants.getSupportCategories,
            (json) => SupportCategory.fromJson(json),
      );
      getSupportCategoriesData.value = result ?? [];
      _applyPrefillType(); // auto-select type if prefill was requested before load

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
      if (response != null && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        openTickets.value        = (data['open_tickets']        as num?)?.toInt() ?? 0;
        inProgressTickets.value  = (data['in_progress_tickets'] as num?)?.toInt() ?? 0;
        resolvedToday.value      = (data['resolved_today']      as num?)?.toInt() ?? 0;
        avgResponseTime.value    = data['avg_response_hours']?.toString() ?? '—';
        debugPrint("Support stats loaded: open=${openTickets.value}, "
            "inProgress=${inProgressTickets.value}, "
            "resolvedToday=${resolvedToday.value}, "
            "avg=${avgResponseTime.value}");
      }
    } catch (e, stack) {
      debugPrint("Error fetching support stats: $e");
      debugPrint("Stack trace: $stack");
    } finally {
      isStatsLoading.value = false;
    }
  }

  bool validateFields() {
    if (clientUserId.value.isEmpty) {
      HelperUi.showToast(message: "Please enter User ID");
      return false;
    }
    if (bookingId.value.isEmpty) {
      HelperUi.showToast(message: "Please enter Booking ID");
      return false;
    }
    if (selectedTicketType.value == null) {
      HelperUi.showToast(message: "Please select Ticket Type");
      return false;
    }
    if (priority.value.isEmpty) {
      HelperUi.showToast(message: "Please select Priority");
      return false;
    }
    if (subject.value.isEmpty) {
      HelperUi.showToast(message: "Please enter Subject");
      return false;
    }
    if (description.value.isEmpty) {
      HelperUi.showToast(message: "Please enter Description");
      return false;
    }

    // Validate dynamic fields
    if (requiresHoldDates) {
      if (holdStartDate.value == null) {
        HelperUi.showToast(message: "Please select Hold Start Date");
        return false;
      }
      if (holdEndDate.value == null) {
        HelperUi.showToast(message: "Please select Hold End Date");
        return false;
      }
      if (holdEndDate.value!.isBefore(holdStartDate.value!)) {
        HelperUi.showToast(message: "Hold End Date must be after Start Date");
        return false;
      }
    }

    if (requiresReplacementDate && replacementPlannedDate.value == null) {
      HelperUi.showToast(message: "Please select Replacement Planned Date");
      return false;
    }

    if (requiresCancellationDate && lastServiceDate.value == null) {
      HelperUi.showToast(message: "Please select Last Service Date");
      return false;
    }

    return true;
  }

  Future<void> createSupportTicket() async {
    if (!validateFields()) return;

    debugPrint('Creating ticket:');
    debugPrint('Booking ID: ${bookingId.value}');
    debugPrint('Type: ${selectedTicketType.value?.name}');
    debugPrint('Priority: ${priority.value}');
    debugPrint('Subject: ${subject.value}');
    debugPrint('Description: ${description.value}');

    try {
      isCreateSupportLoading.value = true;

      Map<String, dynamic> requestBody = {
        "user_id": clientUserId.value,
        "support_type_id": selectedTicketType.value!.id.toString(),
        "due_date": "2025-12-20",
        "title": subject.value,
        "description": description.value,
        "comments": buildCommentsFromDynamicFields(),
        "conversionlog_details": "conversionlog_details",
        "created_by_employee": "1",
        "booking_details": bookingId.value,
      };

      final response = await baseApi.postRaw(
        ApiConstants.createSupportTicket,
        requestBody,
      );

      isCreateSupportLoading.value = false;

      if (response != null && response.statusCode == 201) {
        final data = response.data;
        debugPrint("support ticket data $data");
        HelperUi.showToast(message: "Ticket Created Successfully");
        clearForm();
        Get.back();
        await getAllSupportTicketsApi();
      } else if (response != null && response.statusCode == 401) {
        HelperUi.showToast(message: "Ticket Creation Failed. Please Try Again!");
      } else {
        HelperUi.showToast(message: "Something went Wrong");
      }
    } catch (error) {
      isCreateSupportLoading.value = false;
      HelperUi.showToast(message: "An error occurred: $error");
    }
  }

  String buildCommentsFromDynamicFields() {
    List<String> comments = [];

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

    return comments.isEmpty ? "No additional comments" : comments.join(" | ");
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
    selectedTicketType.value = null;
    priority.value = '';
    subject.value = '';
    description.value = '';
    _pendingPrefillTypeId = null;
    resetDynamicFields();
  }

  void updateSupportStatus(int status, int userId) {
    updateSupportStatusLoading.value = true;

    baseApi
        .patchApi("${ApiConstants.updateSupportTicketStatus}?id=$userId&status=$status&comments=${supportCommentsController.text}")
        .then((response) {
      updateSupportStatusLoading.value = false;

      if (response == null) {
        HelperUi.showToast(message: "No response from server.");
        return;
      }

      Map<String, dynamic> responseData = response.data ?? {};
      var statusMessage = responseData['message'] ?? "No message provided.";
      debugPrint("Response from updateUserVisible: $responseData");

      if (response.statusCode == 200) {
        if (statusMessage == 'Updated successfully.') {
          HelperUi.showToast(message: "Support ticket status updated successfully.");
        } else {
          HelperUi.showToast(message: statusMessage);
        }
        onInit();
      } else if (response.statusCode == 401) {
        HelperUi.showToast(
            message: "Unauthorized access. Please log in again.");
      } else {
        HelperUi.showToast(
            message: "Failed to update status. Status: ${response.statusCode}");
      }
    }).catchError((error) {
      updateSupportStatusLoading.value = false;
      HelperUi.showToast(message: "Error updating status: $error");
    });
  }
}