import '../../data/api_constant_url.dart';

/// Endpoints for the client (customer) self-service portal.
class ClientApi {
  ClientApi._();
  static const String _base = ApiConstants.baseURL;

  // Org resolution (shared public endpoints)
  static String orgBySlug(String slug) => "$_base/org/bySlug/$slug";
  // Accepts a numeric id (legacy orgs) or an org code like SUN-482913.
  static String orgById(String ref) => "$_base/org/byId/$ref";

  // Auth
  static const String requestOtp = "$_base/clientAuth/requestOtp";
  static const String verifyOtp = "$_base/clientAuth/verifyOtp";

  // Profile
  static const String me = "$_base/client/me";

  // Bookings
  static String bookings(String filter) => "$_base/client/bookings?filter=$filter";
  static String bookingById(int id) => "$_base/client/bookings/$id";
  static String bookingHp(int id) => "$_base/client/bookings/$id/hp";
  static String bookingAttendance(int id) => "$_base/client/bookings/$id/attendance";

  // Patients
  static const String patients = "$_base/client/patients";
  static String patientById(int id) => "$_base/client/patients/$id";

  // Support
  static const String supportCategories = "$_base/client/support/categories";
  static const String support = "$_base/client/support";

  // Accounts
  static const String invoices = "$_base/client/invoices";
  static const String receipts = "$_base/client/receipts";
  static const String outstanding = "$_base/client/outstanding";
}
