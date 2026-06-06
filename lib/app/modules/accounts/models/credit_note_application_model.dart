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

class CreditNoteApplicationModel {
  final int id;
  final int orgId;
  final int creditNoteId;
  final int targetBookingId;
  final int targetInvoiceId;
  final double amountApplied;
  final String status;
  final int? appliedBy;
  final int? reversedBy;
  final int? ledgerEntryId;
  final String? appliedAt;
  final String? notes;
  final String? reversedAt;
  final String? reversalReason;
  final String? appliedByName;
  final String? targetBookingRef;
  final String? targetInvoiceRef;

  CreditNoteApplicationModel({
    required this.id,
    required this.orgId,
    required this.creditNoteId,
    required this.targetBookingId,
    required this.targetInvoiceId,
    required this.amountApplied,
    required this.status,
    this.appliedBy,
    this.reversedBy,
    this.ledgerEntryId,
    this.appliedAt,
    this.notes,
    this.reversedAt,
    this.reversalReason,
    this.appliedByName,
    this.targetBookingRef,
    this.targetInvoiceRef,
  });

  factory CreditNoteApplicationModel.fromJson(Map<String, dynamic> json) {
    return CreditNoteApplicationModel(
      id:               _toInt(json['id']) ?? 0,
      orgId:            _toInt(json['org_id']) ?? 0,
      creditNoteId:     _toInt(json['credit_note_id']) ?? 0,
      targetBookingId:  _toInt(json['target_booking_id']) ?? 0,
      targetInvoiceId:  _toInt(json['target_invoice_id']) ?? 0,
      amountApplied:    _toDouble(json['amount_applied']) ?? 0.0,
      status:           json['status']?.toString() ?? '',
      appliedBy:        _toInt(json['applied_by']),
      reversedBy:       _toInt(json['reversed_by']),
      ledgerEntryId:    _toInt(json['ledger_entry_id']),
      appliedAt:        json['applied_at'] as String?,
      notes:            json['notes'] as String?,
      reversedAt:       json['reversed_at'] as String?,
      reversalReason:   json['reversal_reason'] as String?,
      appliedByName:    json['applied_by_name'] as String?,
      targetBookingRef: json['target_booking_ref'] as String?,
      targetInvoiceRef: json['target_invoice_ref'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'org_id':             orgId,
    'credit_note_id':     creditNoteId,
    'target_booking_id':  targetBookingId,
    'target_invoice_id':  targetInvoiceId,
    'amount_applied':     amountApplied,
    'status':             status,
    'applied_by':         appliedBy,
    'reversed_by':        reversedBy,
    'ledger_entry_id':    ledgerEntryId,
    'applied_at':         appliedAt,
    'notes':              notes,
    'reversed_at':        reversedAt,
    'reversal_reason':    reversalReason,
    'applied_by_name':    appliedByName,
    'target_booking_ref': targetBookingRef,
    'target_invoice_ref': targetInvoiceRef,
  };

  static List<CreditNoteApplicationModel> fromJsonList(List list) =>
      list.map((e) => CreditNoteApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
}
