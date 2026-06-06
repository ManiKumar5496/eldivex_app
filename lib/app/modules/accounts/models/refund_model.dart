import 'dart:convert';

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

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
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    // Parse receipt_ids — may arrive as a JSON string or a List
    List<int>? receiptIds;
    final rawReceipts = json['receipt_ids'];
    if (rawReceipts is String) {
      final decoded = jsonDecode(rawReceipts);
      if (decoded is List) {
        receiptIds = decoded.map((e) => (e as num).toInt()).toList();
      }
    } else if (rawReceipts is List) {
      receiptIds = rawReceipts.map((e) => (e as num).toInt()).toList();
    }

    // Parse channelDetails — may arrive as a JSON string or a Map
    Map<String, dynamic>? channelDetails;
    final rawChannel = json['channel_details'];
    if (rawChannel is String) {
      final decoded = jsonDecode(rawChannel);
      if (decoded is Map) channelDetails = Map<String, dynamic>.from(decoded);
    } else if (rawChannel is Map) {
      channelDetails = Map<String, dynamic>.from(rawChannel);
    }

    // Parse dispatchDetails — may arrive as a JSON string or a Map
    Map<String, dynamic>? dispatchDetails;
    final rawDispatch = json['dispatch_details'];
    if (rawDispatch is String) {
      final decoded = jsonDecode(rawDispatch);
      if (decoded is Map) dispatchDetails = Map<String, dynamic>.from(decoded);
    } else if (rawDispatch is Map) {
      dispatchDetails = Map<String, dynamic>.from(rawDispatch);
    }

    return RefundModel(
      id:                   _toInt(json['id']) ?? 0,
      orgId:                _toInt(json['org_id']) ?? 0,
      clientId:             _toInt(json['client_id']) ?? 0,
      bookingId:            _toInt(json['booking_id']) ?? 0,
      invoiceId:            _toInt(json['invoice_id']),
      transactionEntryId:   _toInt(json['transaction_entry_id']),
      requestedBy:          _toInt(json['requested_by']),
      approvedBy:           _toInt(json['approved_by']),
      processedBy:          _toInt(json['processed_by']),
      reversedBy:           _toInt(json['reversed_by']),
      refundAmount:         _toDouble(json['refund_amount']) ?? 0.0,
      refundChannel:        json['refund_channel']?.toString() ?? '',
      refundReason:         json['refund_reason']?.toString() ?? '',
      status:               json['status']?.toString() ?? '',
      approvalLevel:        json['approval_level'] as String?,
      approvedAt:           json['approved_at'] as String?,
      processedAt:          json['processed_at'] as String?,
      reversedAt:           json['reversed_at'] as String?,
      reversalReason:       json['reversal_reason'] as String?,
      notes:                json['notes'] as String?,
      createdOn:            json['created_on'] as String?,
      updatedOn:            json['updated_on'] as String?,
      requestedByName:      json['requested_by_name'] as String?,
      approvedByName:       json['approved_by_name'] as String?,
      clientName:           json['client_name'] as String?,
      bookingRef:           json['booking_ref'] as String?,
      receiptIds:           receiptIds,
      channelDetails:       channelDetails,
      dispatchDetails:      dispatchDetails,
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
      list.map((e) => RefundModel.fromJson(e as Map<String, dynamic>)).toList();
}
