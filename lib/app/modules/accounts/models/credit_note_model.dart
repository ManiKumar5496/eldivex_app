/// CreditNoteModel — auto-generated on hold or cancellation events.
class CreditNoteModel {
  final int id;
  final int bookingId;
  final int? invoiceId;
  final String creditType;    // Hold / Cancellation / Overpayment / Other
  final double amount;
  final String? reason;
  final String status;        // Pending / Approved / Rejected
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
    this.reason,
    required this.status,
    this.creditDate,
    this.clientName,
    this.clientMobile,
    this.patientName,
    this.createdOn,
  });

  factory CreditNoteModel.fromJson(Map<String, dynamic> json) {
    return CreditNoteModel(
      id:           (json['id'] as num?)?.toInt() ?? 0,
      bookingId:    (json['booking_id'] as num?)?.toInt() ?? 0,
      invoiceId:    json['invoice_id'],
      creditType:   json['credit_type']   ?? 'Hold',
      amount:       double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      reason:       json['reason'],
      status:       json['status'] ?? 'Pending',
      creditDate:   json['credit_date'],
      clientName:   json['client_name'],
      clientMobile: json['client_mobile'],
      patientName:  json['patient_name'],
      createdOn:    json['created_on'],
    );
  }

  static List<CreditNoteModel> listFromJson(List<dynamic> list) =>
      list.map((e) => CreditNoteModel.fromJson(e as Map<String, dynamic>)).toList();
}
