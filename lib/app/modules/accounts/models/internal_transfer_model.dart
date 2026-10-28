import 'parse_utils.dart';

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
      id:                         toIntOrNull(json['id']) ?? 0,
      orgId:                      toIntOrNull(json['org_id']) ?? 0,
      clientId:                   toIntOrNull(json['client_id']) ?? 0,
      sourceBookingId:            toIntOrNull(json['source_booking_id']) ?? 0,
      targetBookingId:            toIntOrNull(json['target_booking_id']) ?? 0,
      transferAmount:             toDoubleOrNull(json['transfer_amount']) ?? 0.0,
      transferType:               json['transfer_type']?.toString() ?? '',
      reason:                     json['reason']?.toString() ?? '',
      status:                     json['status']?.toString() ?? '',
      notes:                      toStrOrNull(json['notes']),
      approvedAt:                 toStrOrNull(json['approved_at']),
      createdOn:                  toStrOrNull(json['created_on']),
      updatedOn:                  toStrOrNull(json['updated_on']),
      reversedAt:                 toStrOrNull(json['reversed_at']),
      reversalReason:             toStrOrNull(json['reversal_reason']),
      sourceTransactionEntryId:   toIntOrNull(json['source_transaction_entry_id']),
      targetTransactionEntryId:   toIntOrNull(json['target_transaction_entry_id']),
      requestedBy:                toIntOrNull(json['requested_by']),
      approvedBy:                 toIntOrNull(json['approved_by']),
      reversedBy:                 toIntOrNull(json['reversed_by']),
      requestedByName:            toStrOrNull(json['requested_by_name']),
      approvedByName:             toStrOrNull(json['approved_by_name']),
      sourceBookingRef:           toStrOrNull(json['source_booking_ref']),
      targetBookingRef:           toStrOrNull(json['target_booking_ref']),
      clientName:                 toStrOrNull(json['client_name']),
      sourceBookingBalance:       toDoubleOrNull(json['source_booking_balance']),
      targetBookingBalance:       toDoubleOrNull(json['target_booking_balance']),
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
      parseList(list, InternalTransferModel.fromJson);
}
