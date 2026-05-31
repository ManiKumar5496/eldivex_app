import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_all_branches_model.dart';
import '../models/get_categories_model.dart';
import '../models/get_master_module_list.dart';
import '../models/get_master_roles.dart';
import '../models/get_service_list_id_model.dart';
import '../views/dashboard_stats_widgets/booking_stats_chart.dart';
import '../views/dashboard_stats_widgets/weekly_bookings_widget.dart';
import '../views/dashboard_stats_widgets/service_distribution_widget.dart';
import '../views/dashboard_stats_widgets/top_performing_cgs_widget.dart';
import '../views/dashboard_stats_widgets/top_performing_cities_widget.dart';

class DashboardController extends GetxController {
  final RxBool getCategoriesLoading       = false.obs;
  final RxBool getServiceListByIdLoading  = false.obs;
  final RxBool getAllBranchesLoading       = false.obs;
  final RxBool getMasterRolesLoading      = false.obs;
  final RxBool getMasterModuleListLoading = false.obs;
  final RxBool isCreateRoleLoading        = false.obs;
  final ApiService baseApi = ApiService();

  RxList<CategoryModel>           categoriesList     = <CategoryModel>[].obs;
  RxList<GetMasterRoles>          getMasterRolesData = <GetMasterRoles>[].obs;
  RxList<GetAllBranchesModel>     getAllBranches      = <GetAllBranchesModel>[].obs;
  RxList<MasterModuleList>        getMasterModuleData = <MasterModuleList>[].obs;
  RxList<ServicesByCategoryModel> getServicesByCityId = <ServicesByCategoryModel>[].obs;

  RxInt selectedBranchId  = 1.obs;
  RxInt selectedCategoryId = 0.obs;

  final TextEditingController roleNameController        = TextEditingController();
  final TextEditingController roleDescriptionController = TextEditingController();
  RxList<String> selectedAccessList = <String>[].obs;

  final bookingStatusData = <BookingStatusData>[].obs;
  final selectedStatus    = RxnString();

  // ── Phase 4.1: Dashboard filter state ──────────────────────────────────────
  final RxBool   dashboardLoading = false.obs;
  final RxString dashFrom         = ''.obs;
  final RxString dashTo           = ''.obs;
  final Rxn<int> filterBranchId   = Rxn<int>();

  // ── Dashboard stats (populated by fetchDashboardStats) ─────────────────────
  RxInt    totalBookings  = 0.obs;
  RxInt    activeBookings = 0.obs;
  RxDouble totalRevenue   = 0.0.obs;
  RxInt    totalHPs       = 0.obs;

  RxList<BookingData>     weeklyBookingsData      = <BookingData>[].obs;
  RxList<ServiceData>     serviceDistributionData = <ServiceData>[].obs;
  RxList<TopCgItem>       topCgItems              = <TopCgItem>[].obs;
  RxList<CityPerformance> cityPerformanceData     = <CityPerformance>[].obs;

  @override
  void onInit() {
    getCategoriesList();
    getMasterRoles();
    getMasterModulesApi();
    getAllBranchesApi();
    fetchDashboardStats();
    super.onInit();
  }

  // ── Phase 4.1: Single aggregated dashboard API call ─────────────────────────

  Future<void> fetchDashboardStats({
    String? from,
    String? to,
    int? branchId,
  }) async {
    dashboardLoading.value = true;
    try {
      final String? resolvedFrom = from ??
          (dashFrom.value.isNotEmpty ? dashFrom.value : null);
      final String? resolvedTo = to ??
          (dashTo.value.isNotEmpty ? dashTo.value : null);
      final int? resolvedBranch = branchId ?? filterBranchId.value;

      final url = ApiConstants.getDashboardStats(
        from:     resolvedFrom,
        to:       resolvedTo,
        branchId: resolvedBranch,
      );

      final response = await baseApi.getRaw(url);
      if (response == null || response.statusCode != 200) {
        debugPrint('[dashboard] getDashboardStats → ${response?.statusCode}');
        return;
      }

      final data = response.data as Map<String, dynamic>;

      // ── Summary stats ──────────────────────────────────────────────────────
      totalBookings.value  = (data['totalBookings']  as num? ?? 0).toInt();
      activeBookings.value = (data['activeBookings'] as num? ?? 0).toInt();
      totalRevenue.value   = (data['totalRevenue']   as num? ?? 0).toDouble();
      totalHPs.value       = (data['totalHPs']       as num? ?? 0).toInt();

      // ── Weekly bookings ────────────────────────────────────────────────────
      final weekly = data['weeklyBookings'] as List? ?? [];
      weeklyBookingsData.value = weekly.map((d) {
        final m = d as Map<String, dynamic>;
        return BookingData(
          m['day']?.toString() ?? '',
          (m['count'] as num? ?? 0).toDouble(),
        );
      }).toList();

      // ── Service distribution ───────────────────────────────────────────────
      final services = data['serviceDistribution'] as List? ?? [];
      serviceDistributionData.value = services.map((d) {
        final m = d as Map<String, dynamic>;
        return ServiceData(
          m['name']?.toString() ?? 'Other',
          (m['count'] as num? ?? 0).toDouble(),
        );
      }).toList();

      // ── Top CGs ───────────────────────────────────────────────────────────
      final cgs = data['topCgs'] as List? ?? [];
      topCgItems.value = cgs.map((d) {
        final m = d as Map<String, dynamic>;
        return TopCgItem(
          name:     m['name']?.toString() ?? 'HP #${m['hp_reg_id']}',
          service:  'Health Professional',
          rating:   0,
          bookings: (m['bookings'] as num? ?? 0).toInt(),
        );
      }).toList();

      // ── City performance ───────────────────────────────────────────────────
      final cities = data['cityPerformance'] as List? ?? [];
      final maxBkgs = cities.isNotEmpty
          ? ((cities.first as Map)['bookings'] as num? ?? 1).toDouble()
          : 1.0;
      cityPerformanceData.value = cities.asMap().entries.map((e) {
        final m   = e.value as Map<String, dynamic>;
        final bkgs = (m['bookings'] as num? ?? 0).toInt();
        return CityPerformance(
          rank:     (m['rank'] as num? ?? e.key + 1).toInt(),
          city:     m['city']?.toString() ?? '',
          bookings: bkgs,
          revenue:  (m['revenue'] as num? ?? 0).toDouble(),
          progress: maxBkgs > 0 ? bkgs / maxBkgs : 0,
        );
      }).toList();

      // ── Booking status breakdown ───────────────────────────────────────────
      final statusColors = <String, Color>{
        'Confirmed':   const Color(0xFF4A7CF0),
        'Pending':     const Color(0xFFE9A53A),
        'Completed':   const Color(0xFF5AC89A),
        'Cancelled':   const Color(0xFFE4574D),
        'Active':      const Color(0xFF4A7CF0),
        'In-Progress': const Color(0xFF2196F3),
      };
      final defaultColors = [
        const Color(0xFF9C27B0),
        const Color(0xFF607D8B),
        const Color(0xFF795548),
        const Color(0xFFFF5722),
      ];
      final statusList = data['bookingStatusBreakdown'] as List? ?? [];
      bookingStatusData.clear();
      int ci = 0;
      for (final s in statusList) {
        final m      = s as Map<String, dynamic>;
        final status = m['status']?.toString() ?? 'Unknown';
        final count  = (m['count'] as num? ?? 0).toInt();
        bookingStatusData.add(BookingStatusData(
          label: status,
          value: count,
          color: statusColors[status] ?? defaultColors[ci++ % defaultColors.length],
        ));
      }
    } catch (e, stack) {
      debugPrint('[dashboard] fetchDashboardStats error: $e\n$stack');
    } finally {
      dashboardLoading.value = false;
    }
  }

  // ── Format helpers ───────────────────────────────────────────────────────────

  String get formattedRevenue {
    return '₹${NumberFormat('#,##,###', 'en_IN').format(totalRevenue.value.toInt())}';
  }

  String get formattedTotalBookings  => NumberFormat('#,###').format(totalBookings.value);
  String get formattedActiveBookings => NumberFormat('#,###').format(activeBookings.value);
  String get formattedTotalHPs       => NumberFormat('#,###').format(totalHPs.value);

  // ── Existing API calls (still needed for booking creation & role management) ─

  Future<void> getMasterRoles() async {
    getMasterRolesLoading.value = true;
    try {
      final result = await baseApi.getList<GetMasterRoles>(
        ApiConstants.getAccessRoles,
        (json) => GetMasterRoles.fromJson(json),
      );
      getMasterRolesData.value = result ?? [];
    } catch (e) {
      debugPrint('Error fetching master roles: $e');
      HelperUi.showToast(message: 'Failed to fetch roles.');
    } finally {
      getMasterRolesLoading.value = false;
    }
  }

  Future<void> getMasterModulesApi() async {
    getMasterModuleListLoading.value = true;
    try {
      final result = await baseApi.getList<MasterModuleList>(
        ApiConstants.getMasterModules,
        (json) => MasterModuleList.fromJson(json),
      );
      getMasterModuleData.value = result ?? [];
    } catch (e) {
      debugPrint('Error fetching master modules: $e');
    } finally {
      getMasterModuleListLoading.value = false;
    }
  }

  Future<void> getAllBranchesApi() async {
    getAllBranchesLoading.value = true;
    try {
      final result = await baseApi.getList<GetAllBranchesModel>(
        ApiConstants.getAllBranches,
        (json) => GetAllBranchesModel.fromJson(json),
      );
      getAllBranches.value = result ?? [];
    } catch (e) {
      debugPrint('Error fetching branches: $e');
    } finally {
      getAllBranchesLoading.value = false;
    }
  }

  Future<void> getCategoriesList() async {
    getCategoriesLoading.value = true;
    try {
      final result = await baseApi.getList<CategoryModel>(
        ApiConstants.getMasterServices,
        (json) => CategoryModel.fromJson(json),
      );
      categoriesList.value = result ?? [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      getCategoriesLoading.value = false;
    }
  }

  Future<void> getServiceListById() async {
    getServiceListByIdLoading.value = true;
    try {
      final result = await baseApi.getList<ServicesByCategoryModel>(
        '${ApiConstants.getAllServicesByCatId}?branch_id=$selectedBranchId'
        '&service_category_id=$selectedCategoryId',
        (json) => ServicesByCategoryModel.fromJson(json),
      );
      getServicesByCityId.value = result ?? [];
    } catch (e) {
      debugPrint('Error fetching services by id: $e');
    } finally {
      getServiceListByIdLoading.value = false;
    }
  }

  // ── Role management ──────────────────────────────────────────────────────────

  bool validateRoleForm() {
    if (roleNameController.text.trim().isEmpty) {
      HelperUi.showToast(
        message: 'Please enter role name',
        backgroundColor: Colors.orange,
      );
      return false;
    }
    if (selectedAccessList.isEmpty) {
      HelperUi.showToast(
        message: 'Please select at least one access permission',
        backgroundColor: Colors.orange,
      );
      return false;
    }
    return true;
  }

  void createUserRole() async {
    if (!validateRoleForm()) return;
    isCreateRoleLoading.value = true;
    try {
      final body = <String, dynamic>{
        'role_name':   roleNameController.text.trim(),
        'access_list': selectedAccessList.join(','),
      };
      if (roleDescriptionController.text.trim().isNotEmpty) {
        body['description'] = roleDescriptionController.text.trim();
      }
      final response = await baseApi.postRaw(ApiConstants.createEmployeeRoles, body);
      isCreateRoleLoading.value = false;
      if (response == null) {
        HelperUi.showToast(message: 'No response from server', backgroundColor: Colors.red);
        return;
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        HelperUi.showToast(
          message: 'Role created successfully!',
          backgroundColor: const Color(0xFF14B8A6),
        );
        clearRoleForm();
        getMasterRoles();
        Get.back();
      } else if (response.statusCode == 409) {
        HelperUi.showToast(
          message: 'Role name already exists.',
          backgroundColor: Colors.orange,
        );
      } else {
        HelperUi.showToast(
          message: 'Failed to create role. (${response.statusCode})',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      isCreateRoleLoading.value = false;
      debugPrint('Error creating role: $e');
      HelperUi.showToast(message: 'Error creating role', backgroundColor: Colors.red);
    }
  }

  void clearRoleForm() {
    roleNameController.clear();
    roleDescriptionController.clear();
    selectedAccessList.clear();
  }

  String getSelectedAccessListString() => selectedAccessList.join(',');
}
