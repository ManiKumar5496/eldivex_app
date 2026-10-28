import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../models/get_discount_models.dart';
import '../models/otp_model.dart';

class SettingsController extends GetxController {
  RxBool isCreateCuponLoading = false.obs;
  RxBool getAllCuponsLoading = false.obs;
  RxBool getOtpLoading = false.obs;
  final ApiService apiService = ApiService();
  Rx<List<CouponModel>> getAllCuponsData = Rx<List<CouponModel>>([]);
  RxList<CouponModel> filteredCoupons = <CouponModel>[].obs;
  Rxn<OtpResponseModel> getOtpData = Rxn<OtpResponseModel>();

  // ── Phase 2.5 — Services ──────────────────────────────────────────────────
  RxBool isServicesLoading = false.obs;
  RxBool isServiceSubmitting = false.obs;
  RxList<Map<String, dynamic>> servicesList = <Map<String, dynamic>>[].obs;
  // Client-side search over the org-scoped service list. The view renders these.
  RxList<Map<String, dynamic>> filteredServices = <Map<String, dynamic>>[].obs;
  final RxString servicesSearchQuery = ''.obs;
  Rxn<int> servicesFilterBranchId = Rxn<int>();

  // ── Phase 2.6 — Branches ──────────────────────────────────────────────────
  RxBool isBranchesLoading = false.obs;
  RxBool isBranchSubmitting = false.obs;
  RxList<Map<String, dynamic>> branchesList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredBranches = <Map<String, dynamic>>[].obs;
  final RxString branchesSearchQuery = ''.obs;

  // ── Service Categories (per-org "products") ───────────────────────────────
  RxBool isCategoriesLoading = false.obs;
  RxBool isCategorySubmitting = false.obs;
  RxList<Map<String, dynamic>> serviceCategoriesList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredServiceCategories = <Map<String, dynamic>>[].obs;
  final RxString categoriesSearchQuery = ''.obs;

  // Loaded flags so screens fetch once (from initState / onInit), never
  // repeatedly from build() when a list happens to be empty.
  bool servicesLoaded = false;
  bool branchesLoaded = false;
  bool categoriesLoaded = false;

  // ── OTP & coupon screen form (owned here so input survives rebuilds) ──────
  final TextEditingController hpUniqueIdController = TextEditingController();
  final TextEditingController bookingIdController = TextEditingController();
  final TextEditingController couponNameController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController discountPercentController = TextEditingController();
  final TextEditingController discountAmountController = TextEditingController();
  final TextEditingController maxDiscountController = TextEditingController();
  final TextEditingController couponSearchController = TextEditingController();

  @override
  void onInit() {
    getCuponsFromApi();
    super.onInit();
  }

  @override
  void onClose() {
    for (final c in [
      hpUniqueIdController, bookingIdController, couponNameController,
      basePriceController, discountPercentController, discountAmountController,
      maxDiscountController, couponSearchController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  /// Backend rows are loosely typed (ints, numeric strings, 'NA').
  static int toInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static int? toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _errorText(dynamic response) {
    final data = response?.data;
    if (data is Map) {
      final msg = data['error'] ?? data['message'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    return ApiService.lastError;
  }

  void _fail(String fallback, [dynamic response]) => HelperUi.showToast(
        message: _errorText(response) ?? fallback,
        backgroundColor: Colors.red,
      );

  void clearCouponForm() {
    couponNameController.clear();
    basePriceController.clear();
    discountPercentController.clear();
    discountAmountController.clear();
    maxDiscountController.clear();
  }

  void clearOtpForm() {
    hpUniqueIdController.clear();
    bookingIdController.clear();
    getOtpData.value = null;
  }

  /// [maxAmount] is the user-entered cap on the discount
  /// (discount_upper_limit_value), not the computed discount for a sample price.
  Future<bool> createDiscountCoupen(
    String name,
    String discount,
    String maxAmount,
  ) async {
    final pct = double.tryParse(discount.trim());
    final cap = double.tryParse(maxAmount.trim());
    if (name.trim().isEmpty) {
      _fail("Please enter a coupon name.");
      return false;
    }
    if (pct == null || pct <= 0 || pct > 100) {
      _fail("Discount % must be between 0 and 100.");
      return false;
    }
    if (cap == null || cap <= 0) {
      _fail("Please enter a valid maximum discount amount.");
      return false;
    }
    if (isCreateCuponLoading.value) return false;

    try {
      isCreateCuponLoading.value = true;

      final response = await apiService.postRaw(
        ApiConstants.createCouponApi,
        {
          "coupon_name": name.trim(),
          "discount_percentage": discount.trim(),
          "discount_upper_limit_value": maxAmount.trim(),
        },
      );

      if (ApiService.isOk(response)) {
        getCuponsFromApi();
        clearCouponForm();
        HelperUi.showToast(
            message: "Coupon created successfully.", backgroundColor: Colors.green);
        // Shell page: stay here (Get.back() would pop the whole admin shell).
        return true;
      }
      _fail("Failed to create coupon. Please try again.", response);
      return false;
    } catch (error) {
      debugPrint("createDiscountCoupen error: $error");
      _fail("Something went wrong. Please try again later.");
      return false;
    } finally {
      isCreateCuponLoading.value = false;
    }
  }

  void getCuponsFromApi() {
    getAllCuponsLoading.value = true;
    apiService
        .getList<CouponModel>(
          "${ApiConstants.getCouponApi}",
          (json) => CouponModel.fromJson(json),
        )
        .then((result) {
          getAllCuponsData.value = result ?? [];
          filterCoupons(couponSearchController.text);
        })
        .whenComplete(() => getAllCuponsLoading.value = false);
  }

  Future<void> getOtpForBooking({
    required String hpUniqueId,
    required String bkngId,
  }) async {
    if (hpUniqueId.trim().isEmpty || bkngId.trim().isEmpty) {
      _fail("Enter both the HP unique ID and the booking ID.");
      return;
    }
    try {
      getOtpLoading.value = true;

      final uri = Uri.parse(ApiConstants.getBookingOTPApi).replace(
        queryParameters: {
          'bkng_id': bkngId.trim(),
          'hp_unique_id': hpUniqueId.trim(),
        },
      );
      final result = await apiService.get<OtpResponseModel>(
        uri.toString(),
        (json) => OtpResponseModel.fromJson(json),
      );

      if (result?.status == true) {
        getOtpData.value = result;
      } else {
        getOtpData.value = null;
        // One toast per failure.
        _fail(result?.message ?? "Failed to fetch OTP");
      }
    } catch (e) {
      debugPrint("Error fetching OTP: $e");
      getOtpData.value = null;
      _fail("Something went wrong. Try again.");
    } finally {
      getOtpLoading.value = false;
    }
  }


  void filterCoupons(String query) {
    if (query.isEmpty) {
      filteredCoupons.value = getAllCuponsData.value;
    } else {
      filteredCoupons.value = getAllCuponsData.value
          .where((coupon) =>
          coupon.couponName
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }

  void calculateDiscount(
      String basePriceText,
      String percentageText,
      TextEditingController discountAmountController,
      ) {
    double basePrice =
        double.tryParse(basePriceText) ?? 0.0;

    double percentage =
        double.tryParse(percentageText) ?? 0.0;

    if (basePrice == 0 || percentage == 0) {
      discountAmountController.text = "";
      return;
    }

    double discountAmount =
        (basePrice * percentage) / 100;

    discountAmountController.text =
        discountAmount.toStringAsFixed(2);

  }


  void calculatePercentage(
      String basePriceText,
      String discountAmountText,
      TextEditingController percentageController,
      ) {
    double basePrice = double.tryParse(basePriceText) ?? 0.0;
    double discountAmount = double.tryParse(discountAmountText) ?? 0.0;

    if (basePrice <= 0 || discountAmount <= 0) {
      percentageController.text = "";
      return;
    }

    if (discountAmount > basePrice) {
      percentageController.text = "";
      _fail("Discount cannot be greater than Base Price");
      return;
    }

    double percentage = (discountAmount / basePrice) * 100;

    percentageController.text = percentage.toStringAsFixed(2);
  }

  // ── Services CRUD (Phase 2.5) ────────────────────────────────────────────

  Future<void> fetchServices() async {
    try {
      isServicesLoading.value = true;
      final response = await apiService.getRaw(
        ApiConstants.getServices(branchId: servicesFilterBranchId.value),
      );
      if (ApiService.isOk(response)) {
        final data = response!.data;
        if (data is List) {
          servicesList.value = data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          applyServicesSearch();
        }
        servicesLoaded = true;
      } else {
        _fail('Failed to load services.');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      isServicesLoading.value = false;
    }
  }

  void searchServices(String query) {
    servicesSearchQuery.value = query;
    applyServicesSearch();
  }

  void applyServicesSearch() {
    final q = servicesSearchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredServices.value = List<Map<String, dynamic>>.from(servicesList);
      return;
    }
    filteredServices.value = servicesList.where((s) {
      String f(String k) => (s[k]?.toString() ?? '').toLowerCase();
      return f('name').contains(q) ||
          f('description').contains(q) ||
          f('category_name').contains(q) ||
          f('cat_name').contains(q) ||
          f('branch_name').contains(q);
    }).toList();
  }

  Future<bool> createService({
    required String name,
    required String description,
    int serviceType = 1,
    String gender = 'Any',
    String? careType,
    int? categoryId,
    int? branchId,
    String? serviceRate,
    String? marketRate,
    String? effectiveFromDate,
  }) async {
    try {
      isServiceSubmitting.value = true;
      final body = <String, dynamic>{
        'name': name,
        'description': description,
        'service_type': serviceType,
        'gender': gender,
      };
      if (careType != null && careType.isNotEmpty) body['care_type'] = careType;
      if (categoryId       != null) body['service_category_id'] = categoryId;
      if (branchId         != null) body['branch_id']           = branchId;
      if (serviceRate      != null && serviceRate.isNotEmpty)      body['service_rate']        = serviceRate;
      if (marketRate       != null && marketRate.isNotEmpty)       body['market_rate']         = marketRate;
      if (effectiveFromDate != null && effectiveFromDate.isNotEmpty) body['effective_from_date'] = effectiveFromDate;
      final response = await apiService.postRaw(ApiConstants.createService, body);
      if (ApiService.isOk(response)) {
        await fetchServices();
        HelperUi.showToast(message: 'Service created successfully.', backgroundColor: Colors.green);
        return true;
      }
      _fail('Failed to create service.', response);
      return false;
    } catch (e) {
      debugPrint('Error creating service: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isServiceSubmitting.value = false;
    }
  }

  Future<bool> updateService({
    required int id,
    required String name,
    required String description,
    int serviceType = 1,
    String gender = 'Any',
    String? careType,
    int? categoryId,
    int? branchId,
    String? serviceRate,
    String? marketRate,
    String? effectiveFromDate,
  }) async {
    try {
      isServiceSubmitting.value = true;
      final body = <String, dynamic>{
        'name': name,
        'description': description,
        'service_type': serviceType,
        'gender': gender,
      };
      if (careType != null && careType.isNotEmpty) body['care_type'] = careType;
      if (categoryId        != null) body['service_category_id'] = categoryId;
      if (branchId          != null) body['branch_id']           = branchId;
      if (serviceRate       != null && serviceRate.isNotEmpty)       body['service_rate']        = serviceRate;
      if (marketRate        != null && marketRate.isNotEmpty)        body['market_rate']         = marketRate;
      if (effectiveFromDate != null && effectiveFromDate.isNotEmpty)  body['effective_from_date'] = effectiveFromDate;
      final response = await apiService.putRaw(
        ApiConstants.updateServiceById(id),
        body,
      );
      if (ApiService.isOk(response)) {
        await fetchServices();
        HelperUi.showToast(message: 'Service updated successfully.');
        return true;
      }
      // Show server-side validation message (e.g. "Effective from date is required")
      _fail('Failed to update service.', response);
      return false;
    } catch (e) {
      debugPrint('Error updating service: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isServiceSubmitting.value = false;
    }
  }

  Future<void> toggleServiceStatus(int id, int currentStatus) async {
    final newStatus = currentStatus == 1 ? 0 : 1;
    try {
      final response = await apiService.patchApi(
        '${ApiConstants.toggleServiceStatus}?id=$id&status=$newStatus',
      );
      if (ApiService.isOk(response)) {
        final idx = servicesList.indexWhere((s) => toInt(s['id']) == id);
        if (idx != -1) {
          servicesList[idx] = {...servicesList[idx], 'status': newStatus};
          servicesList.refresh();
        }
        // The view renders filteredServices — rebuild it from the updated list.
        applyServicesSearch();
      } else {
        _fail('Failed to update status.', response);
      }
    } catch (e) {
      debugPrint('Error toggling service status: $e');
    }
  }

  // ── Service Categories CRUD ──────────────────────────────────────────────

  /// The "Add Service" dialog reads its category dropdown from
  /// [DashboardController.categoriesList]. Re-fetch it after any category
  /// mutation so a newly added/renamed category appears without a refresh.
  Future<void> _syncDashboardCategories() async {
    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>().getCategoriesList();
    }
  }

  Future<void> fetchServiceCategories() async {
    try {
      isCategoriesLoading.value = true;
      final response = await apiService.getRaw(ApiConstants.getServiceCategories);
      if (ApiService.isOk(response)) {
        final data = response!.data;
        if (data is List) {
          serviceCategoriesList.value = data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          applyCategoriesSearch();
        }
        categoriesLoaded = true;
      } else {
        _fail('Failed to load service categories.');
      }
    } catch (e) {
      debugPrint('Error fetching service categories: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  void searchServiceCategories(String query) {
    categoriesSearchQuery.value = query;
    applyCategoriesSearch();
  }

  void applyCategoriesSearch() {
    final q = categoriesSearchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredServiceCategories.value =
          List<Map<String, dynamic>>.from(serviceCategoriesList);
      return;
    }
    filteredServiceCategories.value = serviceCategoriesList.where((c) {
      String f(String k) => (c[k]?.toString() ?? '').toLowerCase();
      return f('name').contains(q) || f('cat_name').contains(q);
    }).toList();
  }

  Future<bool> createServiceCategory(String name) async {
    try {
      isCategorySubmitting.value = true;
      final response = await apiService.postRaw(
        ApiConstants.createServiceCategory,
        {'name': name},
      );
      if (ApiService.isOk(response)) {
        await fetchServiceCategories();
        await _syncDashboardCategories();
        HelperUi.showToast(message: 'Category created successfully.');
        return true;
      }
      _fail('Failed to create category.', response);
      return false;
    } catch (e) {
      debugPrint('Error creating service category: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isCategorySubmitting.value = false;
    }
  }

  Future<bool> updateServiceCategory({required int id, required String name}) async {
    try {
      isCategorySubmitting.value = true;
      final response = await apiService.putRaw(
        ApiConstants.updateServiceCategoryById(id),
        {'name': name},
      );
      if (ApiService.isOk(response)) {
        await fetchServiceCategories();
        await _syncDashboardCategories();
        HelperUi.showToast(message: 'Category updated successfully.');
        return true;
      }
      _fail('Failed to update category.', response);
      return false;
    } catch (e) {
      debugPrint('Error updating service category: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isCategorySubmitting.value = false;
    }
  }

  Future<void> toggleServiceCategoryStatus(int id, int currentStatus) async {
    final newStatus = currentStatus == 1 ? 0 : 1;
    try {
      final response = await apiService.patchApi(
        '${ApiConstants.toggleServiceCategoryStatus}?id=$id&status=$newStatus',
      );
      if (ApiService.isOk(response)) {
        final idx = serviceCategoriesList.indexWhere((c) => toInt(c['id']) == id);
        if (idx != -1) {
          serviceCategoriesList[idx] = {...serviceCategoriesList[idx], 'status': newStatus};
          serviceCategoriesList.refresh();
        }
        applyCategoriesSearch();
        await _syncDashboardCategories();
      } else {
        _fail('Failed to update status.', response);
      }
    } catch (e) {
      debugPrint('Error toggling category status: $e');
    }
  }

  // ── Branches CRUD (Phase 2.6) ────────────────────────────────────────────

  /// The branch dropdowns on the User-create and HP-create screens read from
  /// [DashboardController.getAllBranches], which is only fetched once at
  /// startup. After any branch mutation here, re-fetch that list too so a
  /// newly added/edited branch shows up without a manual page refresh.
  Future<void> _syncDashboardBranches() async {
    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>().getAllBranchesApi();
    }
  }

  Future<void> fetchBranches() async {
    try {
      isBranchesLoading.value = true;
      final response = await apiService.getRaw(ApiConstants.getAllBranches);
      if (ApiService.isOk(response)) {
        final data = response!.data;
        if (data is List) {
          branchesList.value = data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          applyBranchesSearch();
        }
        branchesLoaded = true;
      } else {
        _fail('Failed to load branches.');
      }
    } catch (e) {
      debugPrint('Error fetching branches: $e');
    } finally {
      isBranchesLoading.value = false;
    }
  }

  void searchBranches(String query) {
    branchesSearchQuery.value = query;
    applyBranchesSearch();
  }

  void applyBranchesSearch() {
    final q = branchesSearchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredBranches.value = List<Map<String, dynamic>>.from(branchesList);
      return;
    }
    filteredBranches.value = branchesList.where((b) {
      String f(String k) => (b[k]?.toString() ?? '').toLowerCase();
      return f('br_name').contains(q) ||
          f('br_city').contains(q) ||
          f('br_state').contains(q) ||
          f('br_email').contains(q) ||
          f('br_phone').contains(q);
    }).toList();
  }

  Future<bool> createBranch({
    required String name,
    required String city,
    required String state,
    String address = '',
    String phone = '',
    String email = '',
  }) async {
    try {
      isBranchSubmitting.value = true;
      final response = await apiService.postRaw(ApiConstants.createBranch, {
        'br_name': name,
        'br_city': city,
        'br_state': state,
        'br_address': address,
        'br_phone': phone,
        'br_email': email,
      });
      if (ApiService.isOk(response)) {
        await fetchBranches();
        await _syncDashboardBranches();
        HelperUi.showToast(message: 'Branch created successfully.');
        return true;
      }
      _fail('Failed to create branch.', response);
      return false;
    } catch (e) {
      debugPrint('Error creating branch: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isBranchSubmitting.value = false;
    }
  }

  Future<bool> updateBranch({
    required int id,
    required String name,
    required String city,
    required String state,
    String address = '',
    String phone = '',
    String email = '',
  }) async {
    try {
      isBranchSubmitting.value = true;
      final response = await apiService.putRaw(
        ApiConstants.updateBranchById(id),
        {
          'br_name': name,
          'br_city': city,
          'br_state': state,
          'br_address': address,
          'br_phone': phone,
          'br_email': email,
        },
      );
      if (ApiService.isOk(response)) {
        await fetchBranches();
        await _syncDashboardBranches();
        HelperUi.showToast(message: 'Branch updated successfully.');
        return true;
      }
      _fail('Failed to update branch.', response);
      return false;
    } catch (e) {
      debugPrint('Error updating branch: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isBranchSubmitting.value = false;
    }
  }

  Future<void> toggleBranchStatus(int id, int currentStatus) async {
    final newStatus = currentStatus == 1 ? 0 : 1;
    try {
      final response = await apiService.patchApi(
        '${ApiConstants.toggleBranchStatus}?id=$id&status=$newStatus',
      );
      if (ApiService.isOk(response)) {
        final idx = branchesList.indexWhere((b) => toInt(b['br_id']) == id);
        if (idx != -1) {
          branchesList[idx] = {...branchesList[idx], 'br_status': newStatus};
          branchesList.refresh();
        }
        applyBranchesSearch();
        await _syncDashboardBranches();
      } else {
        _fail('Failed to update status.', response);
      }
    } catch (e) {
      debugPrint('Error toggling branch status: $e');
    }
  }
}
