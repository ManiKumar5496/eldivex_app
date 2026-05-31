class ProvisionalReceipt {
  final int id;
  final String receiptNumber;
  final int bookingId;
  final int? invoiceDbId;   // FK to invoice — null if not linked to a specific invoice
  final String? invoiceId;  // human-readable e.g. "INV-123"
  final int userId;
  final String clientName;
  final String clientMobile;
  final String patientName;
  final String serviceName;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMode;
  final String? transactionId;
  final String? remarks;
  final DateTime receiptDate;
  final String periodFrom;
  final String periodTo;
  final String status;
  final DateTime? createdOn;
  final int? createdBy;

  const ProvisionalReceipt({
    required this.id,
    required this.receiptNumber,
    required this.bookingId,
    this.invoiceDbId,
    this.invoiceId,
    required this.userId,
    required this.clientName,
    required this.clientMobile,
    required this.patientName,
    required this.serviceName,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMode,
    this.transactionId,
    this.remarks,
    required this.receiptDate,
    required this.periodFrom,
    required this.periodTo,
    required this.status,
    this.createdOn,
    this.createdBy,
  });

  factory ProvisionalReceipt.fromJson(Map<String, dynamic> json) {
    return ProvisionalReceipt(
      id: (json['id'] as num?)?.toInt() ?? 0,
      receiptNumber: json['receipt_number']?.toString() ?? '',
      bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
      invoiceDbId: (json['invoice_db_id'] as num?)?.toInt(),
      invoiceId: json['invoice_id']?.toString(),
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      clientName: json['client_name']?.toString() ?? '',
      clientMobile: json['client_mobile']?.toString() ?? '',
      patientName: json['patient_name']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      paymentMode: json['payment_mode']?.toString() ?? '',
      transactionId: json['transaction_id'] as String?,
      remarks: json['remarks'] as String?,
      receiptDate: DateTime.tryParse(json['receipt_date']?.toString() ?? '') ?? DateTime.now(),
      periodFrom: json['period_from']?.toString() ?? '',
      periodTo: json['period_to']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdOn: DateTime.tryParse(json['created_on']?.toString() ?? ''),
      createdBy: (json['created_by'] as num?)?.toInt(),
    );
  }

  static List<ProvisionalReceipt> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => ProvisionalReceipt.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
