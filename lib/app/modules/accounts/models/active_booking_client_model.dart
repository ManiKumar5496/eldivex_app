import 'parse_utils.dart';

/// Booking status codes ('1'..'7') stored in edx_bookings.status, with the
/// same labels BookingsController uses. getActiveClients now also sends
/// `status_label`; this map is the fallback when it is absent.
const Map<String, String> kBookingStatusLabels = {
  '1': 'Booking Submitted',
  '2': 'HP Assigned',
  '3': 'Booking Cancelled',
  '4': 'Service Started',
  '5': 'service on hold',
  '6': 'Service cancelled',
  '7': 'Service Suspended',
};

/// Codes '3' (booking cancelled) and '6' (service cancelled).
const Set<String> kCancelledBookingStatuses = {'3', '6'};

/// Display label for a booking status code (unknown values pass through).
String bookingStatusLabel(String code) {
  final c = code.trim();
  return kBookingStatusLabels[c] ?? c;
}

class ActiveBookingClient {
  final int id;
  final int bookingId;
  final int userId;
  final String clientName;
  final String clientMobile;
  final String? clientEmail;
  final String patientName;
  final String serviceName;
  final String? serviceTypeName;
  final String city;
  final String branchName;
  final DateTime? serviceStartDate;
  final DateTime? serviceEndDate;
  final double baseRate;
  final double totalBilled;
  final double totalPaid;
  final double outstandingAmount;

  /// Booking status code ('1'..'7').
  final String status;

  /// Backend `status_label` (e.g. 'Service Started'), else the local label.
  final String statusLabel;

  const ActiveBookingClient({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.clientName,
    required this.clientMobile,
    this.clientEmail,
    required this.patientName,
    required this.serviceName,
    this.serviceTypeName,
    required this.city,
    required this.branchName,
    this.serviceStartDate,
    this.serviceEndDate,
    required this.baseRate,
    required this.totalBilled,
    required this.totalPaid,
    required this.outstandingAmount,
    required this.status,
    String? statusLabel,
  }) : statusLabel = statusLabel ?? '';

  /// Display label: `status_label` when sent, else mapped from the code.
  String get statusText =>
      statusLabel.isNotEmpty ? statusLabel : bookingStatusLabel(status);

  bool get isCancelled => kCancelledBookingStatuses.contains(status.trim());

  factory ActiveBookingClient.fromJson(Map<String, dynamic> json) {
    return ActiveBookingClient(
      id: toInt(json['id']),
      bookingId: toInt(json['booking_id']),
      userId: toInt(json['user_id']),
      clientName: toStr(json['client_name']),
      clientMobile: toStr(json['client_mobile']),
      clientEmail: toStrOrNull(json['client_email']),
      patientName: toStr(json['patient_name']),
      serviceName: toStr(json['service_name']),
      serviceTypeName: toStrOrNull(json['service_type_name']),
      city: toStr(json['city']),
      branchName: toStr(json['branch_name']),
      serviceStartDate: toDate(json['service_start_date']),
      serviceEndDate: toDate(json['service_end_date']),
      baseRate: toDouble(json['base_rate']),
      totalBilled: toDouble(json['total_billed']),
      totalPaid: toDouble(json['total_paid']),
      outstandingAmount: toDouble(json['outstanding_amount']),
      status: toStr(json['status']),
      statusLabel: toStrOrNull(json['status_label']),
    );
  }

  static List<ActiveBookingClient> listFromJson(List<dynamic> jsonList) {
    return parseList(jsonList, ActiveBookingClient.fromJson);
  }
}

/// One client (edx_client_app_users) derived from getActiveClients, which
/// returns one row per booking (`id` = booking id, `user_id` = client id).
class ClientOption {
  final int userId;
  final String name;
  final String mobile;
  final int bookingCount;
  final double outstanding;

  const ClientOption({
    required this.userId,
    required this.name,
    required this.mobile,
    required this.bookingCount,
    required this.outstanding,
  });

  String get label {
    final n = name.isNotEmpty ? name : 'Client #$userId';
    return mobile.isNotEmpty ? '$n ($mobile)' : n;
  }

  /// Dedupes booking rows by `user_id`, summing outstanding per client.
  static List<ClientOption> fromBookingRows(Iterable<dynamic> rows) {
    final byUser = <int, ClientOption>{};
    for (final r in rows) {
      final uid = toInt(field(r, 'user_id'));
      if (uid <= 0) continue;
      final prev = byUser[uid];
      byUser[uid] = ClientOption(
        userId: uid,
        name: prev?.name.isNotEmpty == true ? prev!.name : toStr(field(r, 'client_name')),
        mobile: prev?.mobile.isNotEmpty == true ? prev!.mobile : toStr(field(r, 'client_mobile')),
        bookingCount: (prev?.bookingCount ?? 0) + 1,
        outstanding: (prev?.outstanding ?? 0) + toDouble(field(r, 'outstanding_amount')),
      );
    }
    final list = byUser.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return list;
  }
}

/// Booking rows (from getActiveClients) that belong to client [userId].
List<dynamic> bookingRowsForUser(Iterable<dynamic> rows, int? userId) {
  if (userId == null) return const [];
  return rows.where((r) => toInt(field(r, 'user_id')) == userId).toList();
}

/// "BK #12 · Patient · Service" label for a getActiveClients booking row.
String bookingRowLabel(dynamic r) {
  final id = toInt(field(r, 'booking_id'), toInt(field(r, 'id')));
  final parts = <String>['Booking #$id'];
  final patient = toStr(field(r, 'patient_name'));
  final service = toStr(field(r, 'service_name'));
  if (patient.isNotEmpty) parts.add(patient);
  if (service.isNotEmpty) parts.add(service);
  return parts.join(' · ');
}
