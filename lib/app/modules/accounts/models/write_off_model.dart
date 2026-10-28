import 'approval_history_model.dart';
import 'parse_utils.dart';

/// Row from GET /getWriteOffs (edx_write_offs + client/patient/service).
class WriteOffModel {
  final int id;
  final int bookingId;
  final int userId;
  final String clientName;
  final String clientMobile;
  final String patientName;
  final String serviceName;
  final double writeOffAmount;
  final String writeOffType;     // BAD_DEBT / ... (v2 write-offs only)
  final String? approvalLevel;   // L1 / L2 / L3 (v2 write-offs only)
  final List<int> invoiceIds;
  final String reason;
  final String? remarks;
  final String approvedBy;
  final String status;           // Pending / Approved / Rejected
  final DateTime? writeOffDate;
  final DateTime? createdOn;
  final int? createdBy;
  final List<ApprovalHistoryModel> approvalHistory;

  const WriteOffModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.clientName,
    required this.clientMobile,
    required this.patientName,
    required this.serviceName,
    required this.writeOffAmount,
    this.writeOffType = '',
    this.approvalLevel,
    this.invoiceIds = const [],
    required this.reason,
    this.remarks,
    required this.approvedBy,
    required this.status,
    this.writeOffDate,
    this.createdOn,
    this.createdBy,
    this.approvalHistory = const [],
  });

  factory WriteOffModel.fromJson(Map<String, dynamic> json) {
    final history = json['approval_history'];
    return WriteOffModel(
      id: toInt(json['id']),
      bookingId: toInt(json['booking_id']),
      userId: toInt(json['user_id']),
      clientName: toStr(json['client_name']),
      clientMobile: toStr(json['client_mobile']),
      patientName: toStr(json['patient_name']),
      serviceName: toStr(json['service_name']),
      writeOffAmount: toDouble(json['write_off_amount']),
      writeOffType: toStr(json['write_off_type']),
      approvalLevel: toStrOrNull(json['approval_level']),
      invoiceIds: toIntList(json['invoice_ids']) ?? const [],
      reason: toStr(json['reason']),
      remarks: toStrOrNull(json['remarks']),
      approvedBy: toStr(json['approved_by']),
      status: toStr(json['status'], 'Pending'),
      writeOffDate: toDate(json['write_off_date']),
      createdOn: toDate(json['created_on']),
      createdBy: toIntOrNull(json['created_by']),
      approvalHistory:
          history is List ? ApprovalHistoryModel.fromJsonList(history) : const [],
    );
  }

  static List<WriteOffModel> listFromJson(List<dynamic> jsonList) =>
      parseList(jsonList, WriteOffModel.fromJson);
}
