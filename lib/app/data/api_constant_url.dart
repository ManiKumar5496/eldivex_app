class ApiConstants {
  /// Base URL is configured via --dart-define at build/run time.
  ///
  /// Usage examples:
  ///   Local dev  : flutter run   (uses default below)
  ///   QA         : flutter run   --dart-define=API_BASE_URL=http://18.61.254.100:3000/api
  ///   Production : flutter build web --dart-define=API_BASE_URL=http://65.2.74.114:4000/api
  static const String baseURL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
    //defaultValue: 'https://eldivexbe-production.up.railway.app/api',
  );

  ///End point
  static const String loginEndPoint = "$baseURL/loginWeb";
  static const String getAccessRoles = "$baseURL/getRoles";
  static const String getAllLanguages = "$baseURL/getlanguages";
  static const String getMasterServices = "$baseURL/masterServices";
  static const String getAllServicesByCatId =
      "$baseURL/masterServicesTypes";
  static const String getAllEmployees = "$baseURL/getWebEmpDetails";
  static const String createEmployee = "$baseURL/createUser";
  static const String updateEmployee = "$baseURL/update-user";
  static const String terminateEmployee = "$baseURL/terminate-user";
  static const String createEmployeeRoles = "$baseURL/createRole";
  static const String createHp = "$baseURL/createHPProfile";
  static const String getHp = "$baseURL/getHPDetails";
  static String getAddressByClient(String userId) => "$baseURL/getAddress?user_id=$userId";
  static const String addAddressByClient = "$baseURL/addAddress";
  static const String getMasterModules = "$baseURL/getAppModules";
  static const String getAllBranches = "$baseURL/getbranches";
  static const String createSupportTicket = "$baseURL/createSupportTicket";
  static const String getSupportTicket = "$baseURL/getSupportTickets";
  static const String getSupportCategories = "$baseURL/getSupportCategory";
  static const String createBookingApi = "$baseURL/createBooking";
  static const String getBookingsApi = "$baseURL/getUserBookings";
  static const String updateBannerStatus = "$baseURL/disable-banner";
  static const String getAllBanners = "$baseURL/getBanners";
  static const String updateBookingApi = '$baseURL/bookings/update';
  static const String manageCgStatus = '$baseURL/updateHPStatus';
  static const String updateSupportTicketStatus = '$baseURL/updateSupportStatus';
  static const String extendServiceApi = '$baseURL/extendBooking';
  static const String holdBookingApi = '$baseURL/holdBooking';
  static const String cancelBookingApi = '$baseURL/cancelUserService';
  static const String markCgAttendance = '$baseURL/markAttendance';
  static const String addClientUser = '$baseURL/login';
  static const String updateAddressApi = '$baseURL/updateAddress';
  static const String updatePatientApi = '$baseURL/updatePatient';
  static const String updateClientUserApi = '$baseURL/update-user-client';
  static const String updateBookingsEditApi = '$baseURL/updateBooking';
  static const String createCouponApi = '$baseURL/createCoupon';
  static const String getCouponApi = '$baseURL/getCoupons';
  static const String createBannersApi = '$baseURL/createBanner';
  static const String getBookingOTPApi = '$baseURL/getBookingOTP';
  static const String putClientUserDetails = '$baseURL/saveUser';
  static const String getClientUserDetails = '$baseURL/getUserDetails';
  static const String assignCgApi = '$baseURL/assignHPToBooking';
  static const String getBookingsHpApi = '$baseURL/getHPByBooking';
  static const String updateHPBookingApi = '$baseURL/updateHPBooking';
  static const String verifyOtpApi = '$baseURL/finalBookingSave';
    static const String getMasterLanguages = '$baseURL/getlanguages';
  static const String getSupportStats    = '$baseURL/getSupportStats';

  // ── Phase 2.3 — Forgot / Reset Password ────────────────────────────────────
  static const String forgotPassword = '$baseURL/forgotPassword';
  static const String resetPassword  = '$baseURL/resetPassword';

  // ── Phase 2.4 — Accounts ───────────────────────────────────────────────────
  static const String getActiveClients     = '$baseURL/getActiveClients';
  static const String createReceipt        = '$baseURL/createReceipt';
  static const String updateReceiptStatus  = '$baseURL/updateReceiptStatus';
  static const String getClientStatements  = '$baseURL/getClientStatements';
  static const String createWriteOff       = '$baseURL/createWriteOff';
  static const String createWriteOffV2     = '$baseURL/createWriteOffV2';
  static const String approveWriteOff      = '$baseURL/approveWriteOff';
  static const String updateWriteOffStatus = '$baseURL/updateWriteOffStatus';

  static String getReceipts({String? status, int? bookingId, String? periodFrom, String? periodTo, int limit = 200}) {
    final params = <String>['limit=$limit'];
    if (status    != null) params.add('status=$status');
    if (bookingId != null) params.add('booking_id=$bookingId');
    if (periodFrom != null) params.add('period_from=$periodFrom');
    if (periodTo   != null) params.add('period_to=$periodTo');
    return '$baseURL/getReceipts?${params.join('&')}';
  }

  static String getWriteOffs({String? status, int? bookingId, int limit = 200}) {
    final params = <String>['limit=$limit'];
    if (status    != null) params.add('status=$status');
    if (bookingId != null) params.add('booking_id=$bookingId');
    return '$baseURL/getWriteOffs?${params.join('&')}';
  }

  // ── Advanced Accounts — Invoices ───────────────────────────────────────────
  static String getInvoices({
    int? bookingId,
    String? status,
    String? from,
    String? to,
    int? branchId,
    int limit = 200,
  }) {
    final params = <String>['limit=$limit'];
    if (bookingId != null) params.add('booking_id=$bookingId');
    if (status    != null) params.add('status=$status');
    if (from      != null) params.add('from=$from');
    if (to        != null) params.add('to=$to');
    if (branchId  != null) params.add('branch_id=$branchId');
    return '$baseURL/getInvoices?${params.join('&')}';
  }

  // ── Advanced Accounts — Credit Notes ──────────────────────────────────────
  static const String createCreditNote       = '$baseURL/createCreditNote';
  static const String updateCreditNoteStatus = '$baseURL/updateCreditNoteStatus';
  static const String applyCreditNote        = '$baseURL/applyCreditNote';

  static String getCreditNotes([String? bookingId, String? status]) {
    final params = <String>[];
    if (bookingId != null && bookingId.isNotEmpty) params.add('booking_id=$bookingId');
    if (status    != null && status.isNotEmpty)    params.add('status=$status');
    return params.isEmpty
        ? '$baseURL/getCreditNotes'
        : '$baseURL/getCreditNotes?${params.join('&')}';
  }

  static String getCreditNoteApplications([String? creditNoteId]) {
    if (creditNoteId != null && creditNoteId.isNotEmpty) {
      return '$baseURL/getCreditNoteApplications?credit_note_id=$creditNoteId';
    }
    return '$baseURL/getCreditNoteApplications';
  }

  // ── Advanced Accounts — Cancellation Billing Preview ──────────────────────
  static String getCancellationBilling(int bookingId, {String? cancelDate}) {
    final params = ['booking_id=$bookingId'];
    if (cancelDate != null) params.add('cancel_date=$cancelDate');
    return '$baseURL/getCancellationBilling?${params.join('&')}';
  }

  // ── Advanced Accounts — Collections ───────────────────────────────────────
  static const String getAgingReport        = '$baseURL/getAgingReport';
  static const String getCollectionsKPIs    = '$baseURL/getCollectionsKPIs';
  static const String bulkGenerateInvoices  = '$baseURL/bulkGenerateInvoices';

  // ── Advanced Accounts — Payment Links ─────────────────────────────────────
  static const String createPaymentLink     = '$baseURL/createPaymentLink';

  // ── Advanced Accounts — Insurance Claims ──────────────────────────────────
  static const String createInsuranceClaim  = '$baseURL/createInsuranceClaim';
  static const String updateInsuranceClaim  = '$baseURL/updateInsuranceClaim';
  static const String getInsuranceClaims    = '$baseURL/getInsuranceClaims';

  // ── Advanced Accounts — Period Closing ────────────────────────────────────
  static const String closePeriod           = '$baseURL/closePeriod';
  static const String getClosedPeriods      = '$baseURL/getClosedPeriods';

  // ── Advanced Accounts — Revenue Recognition ───────────────────────────────
  static const String getRevenueRecognition = '$baseURL/getRevenueRecognition';

  // ── Advanced Accounts — Internal Transfers ────────────────────────────────
  static const String createInternalTransfer  = '$baseURL/createInternalTransfer';
  static const String approveInternalTransfer = '$baseURL/approveInternalTransfer';

  static String getInternalTransfers({String? clientId, String? status, int limit = 200}) {
    final params = <String>['limit=$limit'];
    if (clientId != null) params.add('client_id=$clientId');
    if (status   != null) params.add('status=$status');
    return '$baseURL/getInternalTransfers?${params.join('&')}';
  }

  static String getClientOutstanding(int clientId)   => '$baseURL/clientOutstanding/$clientId';
  static String getBookingOutstanding(int bookingId) => '$baseURL/bookingOutstanding/$bookingId';
  static String getTransactionLedger(String params)  => '$baseURL/transactionLedger?$params';

  // ── Advanced Accounts — Refunds ───────────────────────────────────────────
  static const String createRefund  = '$baseURL/createRefund';
  static const String approveRefund = '$baseURL/approveRefund';

  static String getRefunds(String extra, {String? bookingId, String? status, int limit = 200}) {
    final params = <String>['limit=$limit'];
    if (bookingId != null && bookingId.isNotEmpty) params.add('booking_id=$bookingId');
    if (status    != null && status.isNotEmpty)    params.add('status=$status');
    return '$baseURL/getRefunds?${params.join('&')}';
  }

  static String getRefundById(int id) => '$baseURL/getRefundById/$id';

  // ── Advanced Accounts — Rate History ──────────────────────────────────────
  static String getRateHistory(int bookingId) => '$baseURL/getRateHistory?booking_id=$bookingId';

  // ── Phase 4.1 — Dashboard aggregation ─────────────────────────────────────
  static String getDashboardStats({String? from, String? to, int? branchId}) {
    final params = <String>[];
    if (from != null)     params.add('from=$from');
    if (to != null)       params.add('to=$to');
    if (branchId != null) params.add('branch_id=$branchId');
    final q = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseURL/getDashboardStats$q';
  }

  // ── Phase 4.2 — Audit log ──────────────────────────────────────────────────
  static String getAuditTrail({String? entityType, int? entityId, int page = 1}) {
    final params = <String>['page=$page'];
    if (entityType != null) params.add('entity_type=$entityType');
    if (entityId != null)   params.add('entity_id=$entityId');
    return '$baseURL/getAuditTrail?${params.join('&')}';
  }

  // ── Phase 4.3 — Reports ────────────────────────────────────────────────────
  static String generateReport({
    required String type,
    String? from,
    String? to,
    int? branchId,
    String format = 'json',
  }) {
    final params = <String>['type=$type', 'format=$format'];
    if (from != null)     params.add('from=$from');
    if (to != null)       params.add('to=$to');
    if (branchId != null) params.add('branch_id=$branchId');
    return '$baseURL/generateReport?${params.join('&')}';
  }
  static const String configureReportSchedule = '$baseURL/configureReportSchedule';
  static const String getScheduledReports     = '$baseURL/getScheduledReports';

  // ── Phase 4.4 — HP Matching ────────────────────────────────────────────────
  static String matchHP(int bookingId) => '$baseURL/matchHP?booking_id=$bookingId';

  // ── Phase 2.5 — Services CRUD ──────────────────────────────────────────────
  static String getServices({int? branchId}) {
    final q = branchId != null ? '?branch_id=$branchId' : '';
    return '$baseURL/getServices$q';
  }
  static const String createService         = '$baseURL/createService';
  static String updateServiceById(int id)   => '$baseURL/updateService/$id';
  static const String toggleServiceStatus   = '$baseURL/toggleServiceStatus';
  static const String createServiceCategory = '$baseURL/createServiceCategory';

  // ── Phase 2.6 — Branch CRUD ────────────────────────────────────────────────
  static const String createBranch          = '$baseURL/createBranch';
  static String updateBranchById(int id)    => '$baseURL/updateBranch/$id';
  static const String toggleBranchStatus    = '$baseURL/toggleBranchStatus';

  static const String getAttendanceList  = '$baseURL/getAttendanceList';

  // ── Phase 2.7 — HP Payouts ─────────────────────────────────────────────────
  static const String getPendingPayouts = '$baseURL/getPendingPayouts';
  static const String createPayout      = '$baseURL/createPayout';
  static const String markPayoutPaid    = '$baseURL/markPayoutPaid';
  static const String getPayoutHistory  = '$baseURL/getPayoutHistory';

  // ── Phase 5 — Organisations & Subscriptions ────────────────────────────────
  static const String getPlans              = '$baseURL/getPlans';
  static const String getSubscriptionStatus = '$baseURL/getSubscriptionStatus';
  static const String updateOrgPlan         = '$baseURL/updateOrgPlan';
  static const String getOrganisations      = '$baseURL/getOrganisations';
  static const String createOrganisation    = '$baseURL/createOrganisation';
  static String updateOrganisation(int id)  => '$baseURL/updateOrganisation/$id';
  static const String getOrgDetails         = '$baseURL/getOrgDetails';

  // ── SaaS Accounts Module ───────────────────────────────────────────────────
  static const String getSaasAccounts              = '$baseURL/getOrganisations';
  static String checkSlugAvailable(String slug)    => '$baseURL/saas/checkSlugAvailable?slug=$slug';
  static String checkEmailAvailable(String email)  => '$baseURL/saas/checkEmailAvailable?email=${Uri.encodeComponent(email)}';
  static String getOrgUsage(int orgId)             => '$baseURL/saas/getOrgUsage?org_id=$orgId';
  static String getSubscriptionHistory(int orgId)  => '$baseURL/saas/getSubscriptionHistory?org_id=$orgId';
  static const String transitionSubscriptionStatus = '$baseURL/saas/transitionSubscriptionStatus';
  static const String checkDowngradeViability      = '$baseURL/saas/checkDowngradeViability';
  static const String generateSaasInvoice          = '$baseURL/saas/generateSaasInvoice';
  static const String markSaasInvoicePaid          = '$baseURL/saas/markSaasInvoicePaid';
  static const String getAccountHealthSummary      = '$baseURL/saas/getAccountHealthSummary';
  static String getSaasInvoices({int? orgId}) {
    final q = orgId != null ? '?org_id=$orgId' : '';
    return '$baseURL/saas/getSaasInvoices$q';
  }
}
