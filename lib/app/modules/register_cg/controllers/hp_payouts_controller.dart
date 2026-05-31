import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';

class HpPayoutsController extends GetxController {
  final ApiService _api = ApiService();

  // ── State ──────────────────────────────────────────────────────────────────
  RxBool isPendingLoading  = false.obs;
  RxBool isHistoryLoading  = false.obs;
  RxBool isSubmitting      = false.obs;

  RxList<Map<String, dynamic>> pendingPayouts  = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> payoutHistory   = <Map<String, dynamic>>[].obs;

  // Filter
  final fromDateCtrl = TextEditingController();
  final toDateCtrl   = TextEditingController();

  @override
  void onInit() {
    fetchPendingPayouts();
    fetchPayoutHistory();
    super.onInit();
  }

  @override
  void onClose() {
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    super.onClose();
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> fetchPendingPayouts() async {
    try {
      isPendingLoading.value = true;
      final response = await _api.getRaw(ApiConstants.getPendingPayouts);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          pendingPayouts.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching pending payouts: $e');
    } finally {
      isPendingLoading.value = false;
    }
  }

  Future<void> fetchPayoutHistory({String? from, String? to}) async {
    try {
      isHistoryLoading.value = true;
      var url = ApiConstants.getPayoutHistory;
      final params = <String>[];
      if (from != null && from.isNotEmpty) params.add('from=$from');
      if (to != null && to.isNotEmpty)   params.add('to=$to');
      if (params.isNotEmpty) url = '$url?${params.join('&')}';

      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          payoutHistory.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching payout history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  // ── Create Payout ──────────────────────────────────────────────────────────

  Future<bool> createPayout({
    required String hpUniqueId,
    required String periodFrom,
    required String periodTo,
    required String payAmount,
    String paymentMode = 'Cash',
    String? bookingId,
  }) async {
    try {
      isSubmitting.value = true;
      final body = <String, dynamic>{
        'hp_unique_id': int.tryParse(hpUniqueId) ?? 0,
        'period_from':  periodFrom,
        'period_to':    periodTo,
        'pay_amount':   double.tryParse(payAmount) ?? 0.0,
        'payment_mode': paymentMode,
      };
      if (bookingId != null && bookingId.isNotEmpty) {
        body['booking_id'] = int.tryParse(bookingId);
      }
      final response = await _api.postRaw(ApiConstants.createPayout, body);
      if (response != null && response.statusCode == 201) {
        await fetchPendingPayouts();
        HelperUi.showToast(message: 'Payout record created.');
        return true;
      }
      HelperUi.showToast(message: 'Failed to create payout.');
      return false;
    } catch (e) {
      debugPrint('Error creating payout: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Mark Paid ──────────────────────────────────────────────────────────────

  Future<void> markPayoutPaid(int id) async {
    try {
      final response = await _api.patchApi(
        '${ApiConstants.markPayoutPaid}?id=$id',
      );
      if (response != null && response.statusCode == 200) {
        pendingPayouts.removeWhere((p) => p['id'] == id);
        await fetchPayoutHistory();
        HelperUi.showToast(message: 'Marked as paid.');
      } else {
        HelperUi.showToast(message: 'Failed to update payout.');
      }
    } catch (e) {
      debugPrint('Error marking payout paid: $e');
    }
  }

  // ── History filter ─────────────────────────────────────────────────────────

  void applyHistoryFilter() {
    fetchPayoutHistory(
      from: fromDateCtrl.text.trim(),
      to:   toDateCtrl.text.trim(),
    );
  }

  void clearHistoryFilter() {
    fromDateCtrl.clear();
    toDateCtrl.clear();
    fetchPayoutHistory();
  }
}
