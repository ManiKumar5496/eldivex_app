class SaasBillingInvoiceModel {
  final int id;
  final int orgId;
  final String orgName;
  final String planName;
  final int periodMonth;
  final int periodYear;
  final double amount;
  final String status;
  final String? dueDate;
  final String? paidAt;
  final String? transactionRef;
  final String createdOn;

  SaasBillingInvoiceModel({
    required this.id,
    required this.orgId,
    required this.orgName,
    required this.planName,
    required this.periodMonth,
    required this.periodYear,
    required this.amount,
    required this.status,
    this.dueDate,
    this.paidAt,
    this.transactionRef,
    required this.createdOn,
  });

  factory SaasBillingInvoiceModel.fromJson(Map<String, dynamic> json) =>
      SaasBillingInvoiceModel(
        id:             json['id'] as int? ?? 0,
        orgId:          json['org_id'] as int? ?? 0,
        orgName:        json['org_name']?.toString()  ?? '',
        planName:       json['plan_name']?.toString() ?? '',
        periodMonth:    (json['period_month'] as num?)?.toInt() ?? 0,
        periodYear:     (json['period_year']  as num?)?.toInt() ?? 0,
        amount:         (json['amount'] as num?)?.toDouble()    ?? 0,
        status:         json['status']?.toString()    ?? '',
        dueDate:        json['due_date']?.toString(),
        paidAt:         json['paid_at']?.toString(),
        transactionRef: json['transaction_ref']?.toString(),
        createdOn:      json['created_on']?.toString() ?? '',
      );

  static List<SaasBillingInvoiceModel> listFromJson(List<dynamic> list) =>
      list
          .map((e) => SaasBillingInvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

  String get periodLabel {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[periodMonth]} $periodYear';
  }
}
