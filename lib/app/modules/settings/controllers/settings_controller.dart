import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
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
  Rxn<int> servicesFilterBranchId = Rxn<int>();

  // ── Phase 2.6 — Branches ──────────────────────────────────────────────────
  RxBool isBranchesLoading = false.obs;
  RxBool isBranchSubmitting = false.obs;
  RxList<Map<String, dynamic>> branchesList = <Map<String, dynamic>>[].obs;

  final count = 0.obs;
  @override
  void onInit() {
    getCuponsFromApi();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> createDiscountCoupen(
    String name,
    String discount,
    String maxAmount,
  ) async {
    if (name.isEmpty || discount.isEmpty || maxAmount.isEmpty) {
      HelperUi.showToast(message: "Please fill all the fields.");
      return;
    }

    try {
      isCreateCuponLoading.value = true;

      Map<String, dynamic> requestBody = {
        "coupon_name": name,
        "discount_percentage": discount,
        "discount_upper_limit_value": maxAmount,
      };

      final response = await apiService.postRaw(
        ApiConstants.createCouponApi,
        requestBody,
      );

      isCreateCuponLoading.value = false;

      if (response != null && response.statusCode == 201) {
        final data = response.data;
        debugPrint("Coupon created response: $data");
        getCuponsFromApi();
        HelperUi.showToast(message: "Coupon created successfully.");
        Get.back();
      } else if (response != null && response.statusCode == 401) {
        HelperUi.showToast(message: "Unauthorized. Please login again.");
      } else if (response != null && response.statusCode == 400) {
        HelperUi.showToast(
          message: "Invalid coupon details. Please check and try again.",
        );
      } else {
        HelperUi.showToast(
          message: "Failed to create coupon. Please try again.",
        );
      }
    } catch (error) {
      isCreateCuponLoading.value = false;
      HelperUi.showToast(
        message: "Something went wrong. Please try again later.",
      );
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
          debugPrint("all users $result");
          getAllCuponsData.value = result ?? [];
          filteredCoupons.value = getAllCuponsData.value;
        })
        .catchError((e) {
          debugPrint("Error fetching users: $e");
        })
        .whenComplete(() => getAllCuponsLoading.value = false);
  }

  Future<void> getOtpForBooking({
    required String hpUniqueId,
    required String bkngId,
  }) async {
    try {
      getOtpLoading.value = true;

      final result = await apiService.get<OtpResponseModel>(
        "${ApiConstants.getBookingOTPApi}?bkng_id=$bkngId&hp_unique_id=$hpUniqueId",
            (json) => OtpResponseModel.fromJson(json),
      );

      if (result?.status == true) {
        getOtpData.value = result;
      } else {
        getOtpData.value = null;
        HelperUi.showToast(message: result?.message ?? "Failed to fetch OTP");
      }

    } catch (e, stackTrace) {
      debugPrint("Error fetching OTP: $e");
      debugPrintStack(stackTrace: stackTrace);

      getOtpData.value = null;
      HelperUi.showToast(message: "Something went wrong. Try again.");
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

    double finalPrice =
        basePrice - discountAmount;

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
      HelperUi.showToast(
        message: "Discount cannot be greater than Base Price",
      );
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
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          servicesList.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      isServicesLoading.value = false;
    }
  }

  Future<bool> createService({
    required String name,
    required String description,
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
      };
      if (categoryId       != null) body['service_category_id'] = categoryId;
      if (branchId         != null) body['branch_id']           = branchId;
      if (serviceRate      != null && serviceRate.isNotEmpty)      body['service_rate']        = serviceRate;
      if (marketRate       != null && marketRate.isNotEmpty)       body['market_rate']         = marketRate;
      if (effectiveFromDate != null && effectiveFromDate.isNotEmpty) body['effective_from_date'] = effectiveFromDate;
      final response = await apiService.postRaw(ApiConstants.createService, body);
      if (response != null && response.statusCode == 201) {
        await fetchServices();
        HelperUi.showToast(message: 'Service created successfully.');
        return true;
      }
      HelperUi.showToast(message: 'Failed to create service.');
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
      };
      if (categoryId        != null) body['service_category_id'] = categoryId;
      if (branchId          != null) body['branch_id']           = branchId;
      if (serviceRate       != null && serviceRate.isNotEmpty)       body['service_rate']        = serviceRate;
      if (marketRate        != null && marketRate.isNotEmpty)        body['market_rate']         = marketRate;
      if (effectiveFromDate != null && effectiveFromDate.isNotEmpty)  body['effective_from_date'] = effectiveFromDate;
      final response = await apiService.putRaw(
        ApiConstants.updateServiceById(id),
        body,
      );
      if (response != null && response.statusCode == 200) {
        await fetchServices();
        HelperUi.showToast(message: 'Service updated successfully.');
        return true;
      }
      // Show server-side validation message (e.g. "Effective from date is required")
      final msg = response?.data is Map ? response?.data['message'] : null;
      HelperUi.showToast(message: msg?.toString() ?? 'Failed to update service.');
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
      if (response != null && response.statusCode == 200) {
        final idx = servicesList.indexWhere((s) => s['id'] == id);
        if (idx != -1) {
          servicesList[idx] = {...servicesList[idx], 'status': newStatus};
          servicesList.refresh();
        }
      } else {
        HelperUi.showToast(message: 'Failed to update status.');
      }
    } catch (e) {
      debugPrint('Error toggling service status: $e');
    }
  }

  // ── Branches CRUD (Phase 2.6) ────────────────────────────────────────────

  Future<void> fetchBranches() async {
    try {
      isBranchesLoading.value = true;
      final response = await apiService.getRaw(ApiConstants.getAllBranches);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          branchesList.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching branches: $e');
    } finally {
      isBranchesLoading.value = false;
    }
  }

  Future<bool> createBranch({
    required String name,
    required String city,
    required String state,
    String address = '',
  }) async {
    try {
      isBranchSubmitting.value = true;
      final response = await apiService.postRaw(ApiConstants.createBranch, {
        'br_name': name,
        'br_city': city,
        'br_state': state,
        'br_address': address,
      });
      if (response != null && response.statusCode == 201) {
        await fetchBranches();
        HelperUi.showToast(message: 'Branch created successfully.');
        return true;
      }
      HelperUi.showToast(message: 'Failed to create branch.');
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
        },
      );
      if (response != null && response.statusCode == 200) {
        await fetchBranches();
        HelperUi.showToast(message: 'Branch updated successfully.');
        return true;
      }
      HelperUi.showToast(message: 'Failed to update branch.');
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
      if (response != null && response.statusCode == 200) {
        final idx = branchesList.indexWhere((b) => b['br_id'] == id);
        if (idx != -1) {
          branchesList[idx] = {...branchesList[idx], 'br_status': newStatus};
          branchesList.refresh();
        }
      } else {
        HelperUi.showToast(message: 'Failed to update status.');
      }
    } catch (e) {
      debugPrint('Error toggling branch status: $e');
    }
  }
}
