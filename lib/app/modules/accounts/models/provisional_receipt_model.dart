import 'parse_utils.dart';

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
  final DateTime? receiptDate;
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
    this.receiptDate,
    required this.periodFrom,
    required this.periodTo,
    required this.status,
    this.createdOn,
    this.createdBy,
  });

  factory ProvisionalReceipt.fromJson(Map<String, dynamic> json) {
    return ProvisionalReceipt(
      id: toInt(json['id']),
      receiptNumber: toStr(json['receipt_number']),
      bookingId: toInt(json['booking_id']),
      invoiceDbId: toIntOrNull(json['invoice_db_id']),
      invoiceId: toStrOrNull(json['invoice_id']),
      userId: toInt(json['user_id']),
      clientName: toStr(json['client_name']),
      clientMobile: toStr(json['client_mobile']),
      patientName: toStr(json['patient_name']),
      serviceName: toStr(json['service_name']),
      amount: toDouble(json['amount']),
      taxAmount: toDouble(json['tax_amount']),
      totalAmount: toDouble(json['total_amount']),
      paymentMode: toStr(json['payment_mode']),
      transactionId: toStrOrNull(json['transaction_id']),
      remarks: toStrOrNull(json['remarks']),
      receiptDate: toDate(json['receipt_date']),
      periodFrom: toStr(json['period_from']),
      periodTo: toStr(json['period_to']),
      status: toStr(json['status'], 'Pending'),
      createdOn: toDate(json['created_on']),
      createdBy: toIntOrNull(json['created_by']),
    );
  }

  static List<ProvisionalReceipt> listFromJson(List<dynamic> jsonList) {
    return parseList(jsonList, ProvisionalReceipt.fromJson);
  }
}
