import 'parse_utils.dart';

/// InvoiceModel — clean, amount-only invoice.
/// No tax fields — invoice amount = total_days × daily_rate.
class InvoiceModel {
  final int invoiceDbId;
  final String invoiceId;       // "INV-123"
  final int bookingId;
  final String clientName;
  final String clientMobile;
  final String patientName;
  final String? serviceName;
  final String? branchName;
  final String periodFrom;      // inv_start
  final String periodTo;        // inv_end
  final String? invoiceDate;
  final String? dueDate;
  final double totalAmount;     // inv_raised_amnt
  final double paidAmount;      // sum of approved receipts
  final double dailyRate;       // final_rate from booking
  final String status;          // Paid / Partially Paid / Overdue / Pending
  final String? invoiceType;    // Regular / Credit Note / Advance

  InvoiceModel({
    required this.invoiceDbId,
    required this.invoiceId,
    required this.bookingId,
    required this.clientName,
    required this.clientMobile,
    required this.patientName,
    this.serviceName,
    this.branchName,
    required this.periodFrom,
    required this.periodTo,
    this.invoiceDate,
    this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.dailyRate,
    required this.status,
    this.invoiceType,
  });

  double get balanceDue => totalAmount - paidAmount;

  /// Derived: number of service days (period_to - period_from + 1)
  int get totalDays {
    try {
      final s = DateTime.parse(periodFrom);
      final e = DateTime.parse(periodTo);
      return e.difference(s).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceDbId:  toInt(json['invoice_db_id']),
      invoiceId:    toStr(json['invoice_id'], 'INV-0'),
      bookingId:    toInt(json['booking_id']),
      clientName:   toStr(json['client_name']),
      clientMobile: toStr(json['client_mobile']),
      patientName:  toStr(json['patient_name']),
      serviceName:  toStrOrNull(json['service_name']),
      branchName:   toStrOrNull(json['branch_name']),
      periodFrom:   toStr(json['period_from']),
      periodTo:     toStr(json['period_to']),
      invoiceDate:  toStrOrNull(json['invoice_date']),
      dueDate:      toStrOrNull(json['due_date']),
      totalAmount:  toDouble(json['total_amount']),
      paidAmount:   toDouble(json['paid_amount']),
      dailyRate:    toDouble(json['daily_rate']),
      status:       toStr(json['status'], 'Pending'),
      invoiceType:  toStrOrNull(json['invoice_type']),
    );
  }

  static List<InvoiceModel> listFromJson(List<dynamic> list) =>
      parseList(list, InvoiceModel.fromJson);
}
