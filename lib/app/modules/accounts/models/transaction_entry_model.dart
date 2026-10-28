import 'parse_utils.dart';

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
      id:                     toIntOrNull(json['id']) ?? 0,
      orgId:                  toIntOrNull(json['org_id']) ?? 0,
      clientId:               toIntOrNull(json['client_id']) ?? 0,
      bookingId:              toIntOrNull(json['booking_id']),
      invoiceId:              toIntOrNull(json['invoice_id']),
      transactionType:        json['transaction_type']?.toString() ?? '',
      direction:              json['direction']?.toString() ?? '',
      status:                 json['status']?.toString() ?? '',
      amount:                 toDoubleOrNull(json['amount']) ?? 0.0,
      referenceId:            toIntOrNull(json['reference_id']),
      referenceType:          toStrOrNull(json['reference_type']),
      description:            toStrOrNull(json['description']),
      notes:                  toStrOrNull(json['notes']),
      createdOn:              toStrOrNull(json['created_on']),
      reversedAt:             toStrOrNull(json['reversed_at']),
      reversalReason:         toStrOrNull(json['reversal_reason']),
      runningBalanceClient:   toDoubleOrNull(json['running_balance_client']),
      runningBalanceBooking:  toDoubleOrNull(json['running_balance_booking']),
      createdBy:              toIntOrNull(json['created_by']),
      reversedBy:             toIntOrNull(json['reversed_by']),
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
      parseList(list, TransactionEntryModel.fromJson);
}
