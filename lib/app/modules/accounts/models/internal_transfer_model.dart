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

class InternalTransferModel {
  final int id;
  final int orgId;
  final int clientId;
  final int sourceBookingId;
  final int targetBookingId;
  final double transferAmount;
  final String transferType;
  final String reason;
  final String status;
  final String? notes;
  final String? approvedAt;
  final String? createdOn;
  final String? updatedOn;
  final String? reversedAt;
  final String? reversalReason;
  final int? sourceTransactionEntryId;
  final int? targetTransactionEntryId;
  final int? requestedBy;
  final int? approvedBy;
  final int? reversedBy;
  final String? requestedByName;
  final String? approvedByName;
  final String? sourceBookingRef;
  final String? targetBookingRef;
  final String? clientName;
  final double? sourceBookingBalance;
  final double? targetBookingBalance;

  InternalTransferModel({
    required this.id,
    required this.orgId,
    required this.clientId,
    required this.sourceBookingId,
    required this.targetBookingId,
    required this.transferAmount,
    required this.transferType,
    required this.reason,
    required this.status,
    this.notes,
    this.approvedAt,
    this.createdOn,
    this.updatedOn,
    this.reversedAt,
    this.reversalReason,
    this.sourceTransactionEntryId,
    this.targetTransactionEntryId,
    this.requestedBy,
    this.approvedBy,
    this.reversedBy,
    this.requestedByName,
    this.approvedByName,
    this.sourceBookingRef,
    this.targetBookingRef,
    this.clientName,
    this.sourceBookingBalance,
    this.targetBookingBalance,
  });

  factory InternalTransferModel.fromJson(Map<String, dynamic> json) {
    return InternalTransferModel(
      id:                         _toInt(json['id']) ?? 0,
      orgId:                      _toInt(json['org_id']) ?? 0,
      clientId:                   _toInt(json['client_id']) ?? 0,
      sourceBookingId:            _toInt(json['source_booking_id']) ?? 0,
      targetBookingId:            _toInt(json['target_booking_id']) ?? 0,
      transferAmount:             _toDouble(json['transfer_amount']) ?? 0.0,
      transferType:               json['transfer_type']?.toString() ?? '',
      reason:                     json['reason']?.toString() ?? '',
      status:                     json['status']?.toString() ?? '',
      notes:                      json['notes'] as String?,
      approvedAt:                 json['approved_at'] as String?,
      createdOn:                  json['created_on'] as String?,
      updatedOn:                  json['updated_on'] as String?,
      reversedAt:                 json['reversed_at'] as String?,
      reversalReason:             json['reversal_reason'] as String?,
      sourceTransactionEntryId:   _toInt(json['source_transaction_entry_id']),
      targetTransactionEntryId:   _toInt(json['target_transaction_entry_id']),
      requestedBy:                _toInt(json['requested_by']),
      approvedBy:                 _toInt(json['approved_by']),
      reversedBy:                 _toInt(json['reversed_by']),
      requestedByName:            json['requested_by_name'] as String?,
      approvedByName:             json['approved_by_name'] as String?,
      sourceBookingRef:           json['source_booking_ref'] as String?,
      targetBookingRef:           json['target_booking_ref'] as String?,
      clientName:                 json['client_name'] as String?,
      sourceBookingBalance:       _toDouble(json['source_booking_balance']),
      targetBookingBalance:       _toDouble(json['target_booking_balance']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                           id,
    'org_id':                       orgId,
    'client_id':                    clientId,
    'source_booking_id':            sourceBookingId,
    'target_booking_id':            targetBookingId,
    'transfer_amount':              transferAmount,
    'transfer_type':                transferType,
    'reason':                       reason,
    'status':                       status,
    'notes':                        notes,
    'approved_at':                  approvedAt,
    'created_on':                   createdOn,
    'updated_on':                   updatedOn,
    'reversed_at':                  reversedAt,
    'reversal_reason':              reversalReason,
    'source_transaction_entry_id':  sourceTransactionEntryId,
    'target_transaction_entry_id':  targetTransactionEntryId,
    'requested_by':                 requestedBy,
    'approved_by':                  approvedBy,
    'reversed_by':                  reversedBy,
    'requested_by_name':            requestedByName,
    'approved_by_name':             approvedByName,
    'source_booking_ref':           sourceBookingRef,
    'target_booking_ref':           targetBookingRef,
    'client_name':                  clientName,
    'source_booking_balance':       sourceBookingBalance,
    'target_booking_balance':       targetBookingBalance,
  };

  static List<InternalTransferModel> fromJsonList(List list) =>
      list.map((e) => InternalTransferModel.fromJson(e as Map<String, dynamic>)).toList();
}
