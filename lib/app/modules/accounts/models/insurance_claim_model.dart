import 'parse_utils.dart';

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
      id:             toInt(json['id']),
      bookingId:      toInt(json['booking_id']),
      userId:         toIntOrNull(json['user_id']),
      tpaName:        toStrOrNull(json['tpa_name']),
      policyNumber:   toStrOrNull(json['policy_number']),
      preAuthNumber:  toStrOrNull(json['pre_auth_number']),
      claimAmount:    toDoubleOrNull(json['claim_amount']),
      settledAmount:  toDoubleOrNull(json['settled_amount']),
      status:         toStr(json['status'], 'Pending'),
      remarks:        toStrOrNull(json['remarks']),
      submittedDate:  toStrOrNull(json['submitted_date']),
      settledDate:    toStrOrNull(json['settled_date']),
      clientName:     toStrOrNull(json['client_name']),
      clientMobile:   toStrOrNull(json['client_mobile']),
      patientName:    toStrOrNull(json['patient_name']),
      createdOn:      toStrOrNull(json['created_on']),
    );
  }

  static List<InsuranceClaimModel> listFromJson(List<dynamic> list) =>
      parseList(list, InsuranceClaimModel.fromJson);
}
