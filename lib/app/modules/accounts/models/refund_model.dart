import 'approval_history_model.dart';
import 'parse_utils.dart';

class RefundModel {
  final int id;
  final int orgId;
  final int clientId;
  final int bookingId;
  final int? invoiceId;
  final int? transactionEntryId;
  final int? requestedBy;
  final int? approvedBy;
  final int? processedBy;
  final int? reversedBy;
  final double refundAmount;
  final String refundChannel;
  final String refundReason;
  final String status;
  final String? approvalLevel;
  final String? approvedAt;
  final String? processedAt;
  final String? reversedAt;
  final String? reversalReason;
  final String? notes;
  final String? createdOn;
  final String? updatedOn;
  final String? requestedByName;
  final String? approvedByName;
  final String? clientName;
  final String? bookingRef;
  final List<int>? receiptIds;
  final Map<String, dynamic>? channelDetails;
  final Map<String, dynamic>? dispatchDetails;
  final List<ApprovalHistoryModel> approvalHistory;

  RefundModel({
    required this.id,
    required this.orgId,
    required this.clientId,
    required this.bookingId,
    this.invoiceId,
    this.transactionEntryId,
    this.requestedBy,
    this.approvedBy,
    this.processedBy,
    this.reversedBy,
    required this.refundAmount,
    required this.refundChannel,
    required this.refundReason,
    required this.status,
    this.approvalLevel,
    this.approvedAt,
    this.processedAt,
    this.reversedAt,
    this.reversalReason,
    this.notes,
    this.createdOn,
    this.updatedOn,
    this.requestedByName,
    this.approvedByName,
    this.clientName,
    this.bookingRef,
    this.receiptIds,
    this.channelDetails,
    this.dispatchDetails,
    this.approvalHistory = const [],
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id:                   toIntOrNull(json['id']) ?? 0,
      orgId:                toIntOrNull(json['org_id']) ?? 0,
      clientId:             toIntOrNull(json['client_id']) ?? 0,
      bookingId:            toIntOrNull(json['booking_id']) ?? 0,
      invoiceId:            toIntOrNull(json['invoice_id']),
      transactionEntryId:   toIntOrNull(json['transaction_entry_id']),
      requestedBy:          toIntOrNull(json['requested_by']),
      approvedBy:           toIntOrNull(json['approved_by']),
      processedBy:          toIntOrNull(json['processed_by']),
      reversedBy:           toIntOrNull(json['reversed_by']),
      refundAmount:         toDoubleOrNull(json['refund_amount']) ?? 0.0,
      refundChannel:        json['refund_channel']?.toString() ?? '',
      refundReason:         json['refund_reason']?.toString() ?? '',
      status:               json['status']?.toString() ?? '',
      approvalLevel:        toStrOrNull(json['approval_level']),
      approvedAt:           toStrOrNull(json['approved_at']),
      processedAt:          toStrOrNull(json['processed_at']),
      reversedAt:           toStrOrNull(json['reversed_at']),
      reversalReason:       toStrOrNull(json['reversal_reason']),
      notes:                toStrOrNull(json['notes']),
      createdOn:            toStrOrNull(json['created_on']),
      updatedOn:            toStrOrNull(json['updated_on']),
      requestedByName:      toStrOrNull(json['requested_by_name']),
      approvedByName:       toStrOrNull(json['approved_by_name']),
      clientName:           toStrOrNull(json['client_name']),
      bookingRef:           toStrOrNull(json['booking_ref']),
      receiptIds:           toIntList(json['receipt_ids']),
      channelDetails:       toJsonMap(json['channel_details']),
      dispatchDetails:      toJsonMap(json['dispatch_details']),
      approvalHistory:      json['approval_history'] is List
          ? ApprovalHistoryModel.fromJsonList(json['approval_history'] as List)
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                     id,
    'org_id':                 orgId,
    'client_id':              clientId,
    'booking_id':             bookingId,
    'invoice_id':             invoiceId,
    'transaction_entry_id':   transactionEntryId,
    'requested_by':           requestedBy,
    'approved_by':            approvedBy,
    'processed_by':           processedBy,
    'reversed_by':            reversedBy,
    'refund_amount':          refundAmount,
    'refund_channel':         refundChannel,
    'refund_reason':          refundReason,
    'status':                 status,
    'approval_level':         approvalLevel,
    'approved_at':            approvedAt,
    'processed_at':           processedAt,
    'reversed_at':            reversedAt,
    'reversal_reason':        reversalReason,
    'notes':                  notes,
    'created_on':             createdOn,
    'updated_on':             updatedOn,
    'requested_by_name':      requestedByName,
    'approved_by_name':       approvedByName,
    'client_name':            clientName,
    'booking_ref':            bookingRef,
    'receipt_ids':            receiptIds,
    'channel_details':        channelDetails,
    'dispatch_details':       dispatchDetails,
  };

  static List<RefundModel> fromJsonList(List list) =>
      parseList(list, RefundModel.fromJson);
}
