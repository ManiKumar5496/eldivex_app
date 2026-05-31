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
  final String status;

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
  });

  factory ActiveBookingClient.fromJson(Map<String, dynamic> json) {
    return ActiveBookingClient(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      clientName: json['client_name']?.toString() ?? '',
      clientMobile: json['client_mobile']?.toString() ?? '',
      clientEmail: json['client_email'] as String?,
      patientName: json['patient_name']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      serviceTypeName: json['service_type_name'] as String?,
      city: json['city']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      serviceStartDate: DateTime.tryParse(json['service_start_date']?.toString() ?? ''),
      serviceEndDate: DateTime.tryParse(json['service_end_date']?.toString() ?? ''),
      baseRate: double.tryParse(json['base_rate']?.toString() ?? '0') ?? 0,
      totalBilled: double.tryParse(json['total_billed']?.toString() ?? '0') ?? 0,
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      outstandingAmount: double.tryParse(json['outstanding_amount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'Active',
    );
  }

  static List<ActiveBookingClient> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => ActiveBookingClient.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
