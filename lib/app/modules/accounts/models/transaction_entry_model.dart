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

class TransactionEntryModel {
  final int id;
  final int orgId;
  final int clientId;
  final int? bookingId;
  final int? invoiceId;
  final String transactionType;
  final String direction;
  final String status;
  final double amount;
  final int? referenceId;
  final String? referenceType;
  final String? description;
  final String? notes;
  final String? createdOn;
  final String? reversedAt;
  final String? reversalReason;
  final double? runningBalanceClient;
  final double? runningBalanceBooking;
  final int? createdBy;
  final int? reversedBy;

  TransactionEntryModel({
    required this.id,
    required this.orgId,
    required this.clientId,
    this.bookingId,
    this.invoiceId,
    required this.transactionType,
    required this.direction,
    required this.status,
    required this.amount,
    this.referenceId,
    this.referenceType,
    this.description,
    this.notes,
    this.createdOn,
    this.reversedAt,
    this.reversalReason,
    this.runningBalanceClient,
    this.runningBalanceBooking,
    this.createdBy,
    this.reversedBy,
  });

  factory TransactionEntryModel.fromJson(Map<String, dynamic> json) {
    return TransactionEntryModel(
      id:                     _toInt(json['id']) ?? 0,
      orgId:                  _toInt(json['org_id']) ?? 0,
      clientId:               _toInt(json['client_id']) ?? 0,
      bookingId:              _toInt(json['booking_id']),
      invoiceId:              _toInt(json['invoice_id']),
      transactionType:        json['transaction_type']?.toString() ?? '',
      direction:              json['direction']?.toString() ?? '',
      status:                 json['status']?.toString() ?? '',
      amount:                 _toDouble(json['amount']) ?? 0.0,
      referenceId:            _toInt(json['reference_id']),
      referenceType:          json['reference_type'] as String?,
      description:            json['description'] as String?,
      notes:                  json['notes'] as String?,
      createdOn:              json['created_on'] as String?,
      reversedAt:             json['reversed_at'] as String?,
      reversalReason:         json['reversal_reason'] as String?,
      runningBalanceClient:   _toDouble(json['running_balance_client']),
      runningBalanceBooking:  _toDouble(json['running_balance_booking']),
      createdBy:              _toInt(json['created_by']),
      reversedBy:             _toInt(json['reversed_by']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                       id,
    'org_id':                   orgId,
    'client_id':                clientId,
    'booking_id':               bookingId,
    'invoice_id':               invoiceId,
    'transaction_type':         transactionType,
    'direction':                direction,
    'status':                   status,
    'amount':                   amount,
    'reference_id':             referenceId,
    'reference_type':           referenceType,
    'description':              description,
    'notes':                    notes,
    'created_on':               createdOn,
    'reversed_at':              reversedAt,
    'reversal_reason':          reversalReason,
    'running_balance_client':   runningBalanceClient,
    'running_balance_booking':  runningBalanceBooking,
    'created_by':               createdBy,
    'reversed_by':              reversedBy,
  };

  static List<TransactionEntryModel> fromJsonList(List list) =>
      list.map((e) => TransactionEntryModel.fromJson(e as Map<String, dynamic>)).toList();
}
