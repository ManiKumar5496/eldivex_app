import 'parse_utils.dart';

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
      id:               toIntOrNull(json['id']) ?? 0,
      orgId:            toIntOrNull(json['org_id']) ?? 0,
      creditNoteId:     toIntOrNull(json['credit_note_id']) ?? 0,
      targetBookingId:  toIntOrNull(json['target_booking_id']) ?? 0,
      targetInvoiceId:  toIntOrNull(json['target_invoice_id']) ?? 0,
      amountApplied:    toDoubleOrNull(json['amount_applied']) ?? 0.0,
      status:           json['status']?.toString() ?? '',
      appliedBy:        toIntOrNull(json['applied_by']),
      reversedBy:       toIntOrNull(json['reversed_by']),
      ledgerEntryId:    toIntOrNull(json['ledger_entry_id']),
      appliedAt:        toStrOrNull(json['applied_at']),
      notes:            toStrOrNull(json['notes']),
      reversedAt:       toStrOrNull(json['reversed_at']),
      reversalReason:   toStrOrNull(json['reversal_reason']),
      appliedByName:    toStrOrNull(json['applied_by_name']),
      targetBookingRef: toStrOrNull(json['target_booking_ref']),
      targetInvoiceRef: toStrOrNull(json['target_invoice_ref']),
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
      parseList(list, CreditNoteApplicationModel.fromJson);
}
