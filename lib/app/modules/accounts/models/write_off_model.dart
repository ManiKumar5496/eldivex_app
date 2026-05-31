class WriteOffModel {
  final int id;
  final int bookingId;
  final int userId;
  final String clientName;
  final String clientMobile;
  final String patientName;
  final String serviceName;
  final double writeOffAmount;
  final String reason;
  final String? remarks;
  final String approvedBy;
  final String status;
  final DateTime writeOffDate;
  final DateTime? createdOn;
  final int? createdBy;

  const WriteOffModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.clientName,
    required this.clientMobile,
    required this.patientName,
    required this.serviceName,
    required this.writeOffAmount,
    required this.reason,
    this.remarks,
    required this.approvedBy,
    required this.status,
    required this.writeOffDate,
    this.createdOn,
    this.createdBy,
  });

  factory WriteOffModel.fromJson(Map<String, dynamic> json) {
    return WriteOffModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      clientName: json['client_name']?.toString() ?? '',
      clientMobile: json['client_mobile']?.toString() ?? '',
      patientName: json['patient_name']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      writeOffAmount: double.tryParse(json['write_off_amount']?.toString() ?? '0') ?? 0,
      reason: json['reason']?.toString() ?? '',
      remarks: json['remarks'] as String?,
      approvedBy: json['approved_by']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      writeOffDate: DateTime.tryParse(json['write_off_date']?.toString() ?? '') ?? DateTime.now(),
      createdOn: DateTime.tryParse(json['created_on']?.toString() ?? ''),
      createdBy: (json['created_by'] as num?)?.toInt(),
    );
  }

  static List<WriteOffModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => WriteOffModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
