import '../../data/api_constant_url.dart';

/// Endpoints for the caregiver (Health Professional) self-service portal.
/// Kept separate from [ApiConstants] so the admin surface stays untouched.
class HpApi {
  HpApi._();
  static const String _base = ApiConstants.baseURL;

  // Auth (public)
  static String orgBySlug(String slug) => "$_base/org/bySlug/$slug";
  static String orgById(int id) => "$_base/org/byId/$id";
  static const String requestOtp = "$_base/hpAuth/requestOtp";
  static const String verifyOtp = "$_base/hpAuth/verifyOtp";

  // Profile + bank
  static const String me = "$_base/hp/me";
  static const String bank = "$_base/hp/bank";

  // Bookings
  static String bookings(String filter) => "$_base/hp/bookings?filter=$filter";
  static String bookingById(int id) => "$_base/hp/bookings/$id";

  // Attendance
  static String attendance({String? from, String? to}) {
    final q = <String>[];
    if (from != null) q.add("from=$from");
    if (to != null) q.add("to=$to");
    return "$_base/hp/attendance${q.isEmpty ? '' : '?${q.join('&')}'}";
  }

  static const String checkIn = "$_base/hp/attendance/checkin";
  static const String checkOut = "$_base/hp/attendance/checkout";

  // Earnings
  static const String earningsToday = "$_base/hp/earnings/today";
  static String earningsSummary(String from, String to) =>
      "$_base/hp/earnings/summary?from=$from&to=$to";

  // Payouts / payslips
  static const String payouts = "$_base/hp/payouts";
  static String payoutById(int id) => "$_base/hp/payouts/$id";

  // Support
  static const String supportCategories = "$_base/hp/support/categories";
  static const String support = "$_base/hp/support";

  // Leave
  static const String leave = "$_base/hp/leave";

  // Notifications
  static const String notifications = "$_base/hp/notifications";
  static String notificationRead(int id) => "$_base/hp/notifications/$id/read";
}
