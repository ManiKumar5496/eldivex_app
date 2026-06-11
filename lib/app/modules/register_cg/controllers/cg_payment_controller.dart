import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../../hostels/models/hostel_stay_model.dart';
import '../models/attendance_model.dart';
import '../models/cg_payment_summary.dart';
import '../models/get_cg_details_model.dart';

class CgPaymentController extends GetxController {
  final ApiService _api = ApiService();

  // ── State ──────────────────────────────────────────────────────────────────
  RxBool isLoading          = false.obs;
  RxBool isGeneratingPayout = false.obs;

  Rx<GetCgDetails?> selectedCg  = Rx<GetCgDetails?>(null);
  RxString selectedCgId         = ''.obs;

  final periodFromCtrl = TextEditingController();
  final periodToCtrl   = TextEditingController();

  RxList<AttendanceModel> periodAttendance = <AttendanceModel>[].obs;
  RxList<HostelStayModel> periodHostelStays = <HostelStayModel>[].obs;
  Rx<CgPaymentSummary?> paymentSummary     = Rx<CgPaymentSummary?>(null);

  RxString paymentMode = 'Cash'.obs;
  static const List<String> paymentModes = ['Cash', 'UPI', 'Bank Transfer', 'Cheque'];

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    periodFromCtrl.text =
        DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    periodToCtrl.text = DateFormat('yyyy-MM-dd').format(now);
  }

  @override
  void onClose() {
    periodFromCtrl.dispose();
    periodToCtrl.dispose();
    super.onClose();
  }

  // ── CG selection ────────────────────────────────────────────────────────────
  void selectCg(GetCgDetails cg) {
    selectedCg.value   = cg;
    selectedCgId.value = cg.hpRegId.toString();
    paymentSummary.value = null;
    periodAttendance.clear();
  }

  void clearSelection() {
    selectedCg.value   = null;
    selectedCgId.value = '';
    paymentSummary.value = null;
    periodAttendance.clear();
  }

  // ── Fetch & calculate ───────────────────────────────────────────────────────
  Future<void> fetchAndCalculate() async {
    if (selectedCgId.value.isEmpty) {
      HelperUi.showToast(message: 'Please select a caregiver first.');
      return;
    }
    isLoading.value = true;
    try {
      final params = [
        'hp_id=${selectedCgId.value}',
        if (periodFromCtrl.text.isNotEmpty) 'from_date=${periodFromCtrl.text}',
        if (periodToCtrl.text.isNotEmpty)   'to_date=${periodToCtrl.text}',
      ];
      final url = '${ApiConstants.getAttendanceList}?${params.join('&')}';
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200 && response.data is List) {
        periodAttendance.value =
            AttendanceModel.listFromJson(response.data as List<dynamic>);
        await _fetchHostelStays();
        _calculatePaySummary();
      }
    } catch (e) {
      debugPrint('[CgPayment] fetchAndCalculate error: $e');
      HelperUi.showToast(message: 'Failed to fetch attendance data.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch hostel stays overlapping the selected period for this CG.
  Future<void> _fetchHostelStays() async {
    periodHostelStays.clear();
    try {
      final url = ApiConstants.getHostelStays(
        hpId: int.tryParse(selectedCgId.value),
        fromDate: periodFromCtrl.text.isEmpty ? null : periodFromCtrl.text,
        toDate: periodToCtrl.text.isEmpty ? null : periodToCtrl.text,
      );
      final response = await _api.getRaw(url);
      if (response != null && response.statusCode == 200 && response.data is List) {
        periodHostelStays.value =
            HostelStayModel.listFromJson(response.data as List<dynamic>);
      }
    } catch (e) {
      debugPrint('[CgPayment] _fetchHostelStays error: $e');
    }
  }

  /// Nights of [stay] that fall inside the selected pay period. Open stays
  /// (no check-out) are billed up to the period end.
  int _nightsInPeriod(HostelStayModel stay, DateTime periodFrom, DateTime periodTo) {
    final checkIn = DateTime.tryParse(stay.checkInDate);
    if (checkIn == null) return 0;
    final checkOut = stay.isOpen ? periodTo : (DateTime.tryParse(stay.checkOutDate!) ?? periodTo);
    final start = checkIn.isAfter(periodFrom) ? checkIn : periodFrom;
    final end = checkOut.isBefore(periodTo) ? checkOut : periodTo;
    final nights = DateTime(end.year, end.month, end.day)
        .difference(DateTime(start.year, start.month, start.day))
        .inDays;
    return nights < 0 ? 0 : nights;
  }

  void _calculatePaySummary() {
    final cg = selectedCg.value;
    if (cg == null) return;

    final liveInRate  = double.tryParse(cg.liveinPay  ?? '') ?? 0.0;
    final liveOutRate = double.tryParse(cg.liveoutPay ?? '') ?? 0.0;

    int liveInFull = 0, liveInHalf = 0;
    int liveOutFull = 0, liveOutHalf = 0;
    int absentDays = 0, leaveDays = 0;

    for (final record in periodAttendance) {
      final d = record.attDetails;
      final isLiveIn = d.shiftType == 'live_in';

      switch (d.status) {
        case 'present':
          isLiveIn ? liveInFull++ : liveOutFull++;
          break;
        case 'half_day':
          isLiveIn ? liveInHalf++ : liveOutHalf++;
          break;
        case 'absent':
          absentDays++;
          break;
        case 'leave':
          leaveDays++;
          break;
      }
    }

    final liveInSubtotal  = liveInFull  * liveInRate  + liveInHalf  * liveInRate  * 0.5;
    final liveOutSubtotal = liveOutFull * liveOutRate + liveOutHalf * liveOutRate * 0.5;

    final breakdowns = <ShiftBreakdown>[];
    if (liveInFull > 0 || liveInHalf > 0) {
      breakdowns.add(ShiftBreakdown(
        shiftType: 'live_in',
        fullDays:  liveInFull,
        halfDays:  liveInHalf,
        rate:      liveInRate,
        subtotal:  liveInSubtotal,
      ));
    }
    if (liveOutFull > 0 || liveOutHalf > 0) {
      breakdowns.add(ShiftBreakdown(
        shiftType: 'live_out',
        fullDays:  liveOutFull,
        halfDays:  liveOutHalf,
        rate:      liveOutRate,
        subtotal:  liveOutSubtotal,
      ));
    }

    // ── Hostel deductions (clamped to the pay period) ──────────────────────────
    final hostelLines = <HostelDeductionLine>[];
    double hostelDeduction = 0.0;
    final periodFrom = DateTime.tryParse(periodFromCtrl.text);
    final periodTo = DateTime.tryParse(periodToCtrl.text);
    if (periodFrom != null && periodTo != null) {
      for (final stay in periodHostelStays) {
        final nights = _nightsInPeriod(stay, periodFrom, periodTo);
        if (nights <= 0) continue;
        final amount = nights * stay.ratePerDay;
        hostelDeduction += amount;
        hostelLines.add(HostelDeductionLine(
          hostelName:  stay.hostelName.isEmpty ? 'Hostel #${stay.hostelId}' : stay.hostelName,
          nights:      nights,
          ratePerDay:  stay.ratePerDay,
          amount:      amount,
        ));
      }
    }

    paymentSummary.value = CgPaymentSummary(
      hpId:        cg.hpRegId,
      hpName:      '${cg.hpRegFirstName} ${cg.hpRegLastName}'.trim(),
      periodFrom:  periodFromCtrl.text,
      periodTo:    periodToCtrl.text,
      totalDays:   periodAttendance.length,
      liveInDays:  liveInFull,
      liveOutDays: liveOutFull,
      halfDays:    liveInHalf + liveOutHalf,
      absentDays:  absentDays,
      leaveDays:   leaveDays,
      breakdowns:  breakdowns,
      totalPay:    liveInSubtotal + liveOutSubtotal,
      hostelLines:     hostelLines,
      hostelDeduction: hostelDeduction,
    );
  }

  // ── Generate payout ─────────────────────────────────────────────────────────
  Future<bool> generatePayout() async {
    final summary = paymentSummary.value;
    if (summary == null) {
      HelperUi.showToast(message: 'Calculate payment first before generating a payout.');
      return false;
    }
    isGeneratingPayout.value = true;
    try {
      final body = <String, dynamic>{
        'hp_unique_id': summary.hpId,
        'period_from':  summary.periodFrom,
        'period_to':    summary.periodTo,
        'pay_amount':   summary.netPay,
        'gross_pay':    summary.totalPay,
        'hostel_deduction': summary.hostelDeduction,
        'payment_mode': paymentMode.value,
      };
      final response = await _api.postRaw(ApiConstants.createPayout, body);
      if (response != null && response.statusCode == 201) {
        HelperUi.showToast(message: 'Payout created successfully.');
        return true;
      }
      HelperUi.showToast(message: 'Failed to create payout.');
      return false;
    } catch (e) {
      debugPrint('[CgPayment] generatePayout error: $e');
      HelperUi.showToast(message: 'Something went wrong.');
      return false;
    } finally {
      isGeneratingPayout.value = false;
    }
  }
}
