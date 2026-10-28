import 'parse_utils.dart';

/// CreditNoteModel — row from GET /getCreditNotes (edx_credit_notes + client/patient).
class CreditNoteModel {
  final int id;
  final int bookingId;
  final int? invoiceId;
  final String creditType;    // Hold / Cancellation / Overpayment / Other
  final double amount;
  final double? remainingAmount;
  final double? usedAmount;
  final String? reason;
  final String status;        // Pending / Approved / Rejected
  final String? extendedStatus; // PARTIALLY_APPLIED / FULLY_APPLIED
  final String? creditDate;
  final String? clientName;
  final String? clientMobile;
  final String? patientName;
  final String? createdOn;

  CreditNoteModel({
    required this.id,
    required this.bookingId,
    this.invoiceId,
    required this.creditType,
    required this.amount,
    this.remainingAmount,
    this.usedAmount,
    this.reason,
    required this.status,
    this.extendedStatus,
    this.creditDate,
    this.clientName,
    this.clientMobile,
    this.patientName,
    this.createdOn,
  });

  /// Balance still available to apply (backend falls back to `amount`).
  double get available => remainingAmount ?? amount;

  bool get isApproved => status == 'Approved';

  /// Approved notes with a positive balance can be applied to an invoice.
  bool get canApply => isApproved && available > 0;

  /// Status shown in lists: application progress once approved.
  String get displayStatus =>
      isApproved && (extendedStatus ?? '').isNotEmpty ? extendedStatus! : status;

  factory CreditNoteModel.fromJson(Map<String, dynamic> json) {
    return CreditNoteModel(
      id:              toInt(json['id']),
      bookingId:       toInt(json['booking_id']),
      invoiceId:       toIntOrNull(json['invoice_id']),
      creditType:      toStr(json['credit_type'], 'Hold'),
      amount:          toDouble(json['amount']),
      remainingAmount: toDoubleOrNull(json['remaining_amount']),
      usedAmount:      toDoubleOrNull(json['used_amount']),
      reason:          toStrOrNull(json['reason']),
      status:          toStr(json['status'], 'Pending'),
      extendedStatus:  toStrOrNull(json['extended_status']),
      creditDate:      toStrOrNull(json['credit_date']),
      clientName:      toStrOrNull(json['client_name']),
      clientMobile:    toStrOrNull(json['client_mobile']),
      patientName:     toStrOrNull(json['patient_name']),
      createdOn:       toStrOrNull(json['created_on']),
    );
  }

  static List<CreditNoteModel> listFromJson(List<dynamic> list) =>
      parseList(list, CreditNoteModel.fromJson);
}
