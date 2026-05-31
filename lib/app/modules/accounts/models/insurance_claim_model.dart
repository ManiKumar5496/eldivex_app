/// InsuranceClaimModel — TPA/insurance claim linked to a booking.
class InsuranceClaimModel {
  final int id;
  final int bookingId;
  final int? userId;
  final String? tpaName;
  final String? policyNumber;
  final String? preAuthNumber;
  final double? claimAmount;
  final double? settledAmount;
  final String status;         // Pending / Submitted / Approved / Rejected / Settled
  final String? remarks;
  final String? submittedDate;
  final String? settledDate;
  final String? clientName;
  final String? clientMobile;
  final String? patientName;
  final String? createdOn;

  InsuranceClaimModel({
    required this.id,
    required this.bookingId,
    this.userId,
    this.tpaName,
    this.policyNumber,
    this.preAuthNumber,
    this.claimAmount,
    this.settledAmount,
    required this.status,
    this.remarks,
    this.submittedDate,
    this.settledDate,
    this.clientName,
    this.clientMobile,
    this.patientName,
    this.createdOn,
  });

  factory InsuranceClaimModel.fromJson(Map<String, dynamic> json) {
    return InsuranceClaimModel(
      id:             (json['id'] as num?)?.toInt() ?? 0,
      bookingId:      (json['booking_id'] as num?)?.toInt() ?? 0,
      userId:         json['user_id'],
      tpaName:        json['tpa_name'],
      policyNumber:   json['policy_number'],
      preAuthNumber:  json['pre_auth_number'],
      claimAmount:    json['claim_amount'] != null ? double.tryParse(json['claim_amount'].toString()) : null,
      settledAmount:  json['settled_amount'] != null ? double.tryParse(json['settled_amount'].toString()) : null,
      status:         json['status'] ?? 'Pending',
      remarks:        json['remarks'],
      submittedDate:  json['submitted_date'],
      settledDate:    json['settled_date'],
      clientName:     json['client_name'],
      clientMobile:   json['client_mobile'],
      patientName:    json['patient_name'],
      createdOn:      json['created_on'],
    );
  }

  static List<InsuranceClaimModel> listFromJson(List<dynamic> list) =>
      list.map((e) => InsuranceClaimModel.fromJson(e as Map<String, dynamic>)).toList();
}
