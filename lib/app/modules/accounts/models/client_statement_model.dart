class ClientStatement {
  final int id;
  final int userId;
  final int bookingId;
  final String clientName;
  final String clientMobile;
  final String patientName;
  final String serviceName;
  final List<StatementTransaction> transactions;
  final double totalBilled;
  final double totalReceived;
  final double totalWriteOff;
  final double closingBalance;

  const ClientStatement({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.clientName,
    required this.clientMobile,
    required this.patientName,
    required this.serviceName,
    required this.transactions,
    required this.totalBilled,
    required this.totalReceived,
    required this.totalWriteOff,
    required this.closingBalance,
  });

  factory ClientStatement.fromJson(Map<String, dynamic> json) {
    return ClientStatement(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
      clientName: json['client_name']?.toString() ?? '',
      clientMobile: json['client_mobile']?.toString() ?? '',
      patientName: json['patient_name']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => StatementTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalBilled: double.tryParse(json['total_billed']?.toString() ?? '0') ?? 0,
      totalReceived: double.tryParse(json['total_received']?.toString() ?? '0') ?? 0,
      totalWriteOff: double.tryParse(json['total_write_off']?.toString() ?? '0') ?? 0,
      closingBalance: double.tryParse(json['closing_balance']?.toString() ?? '0') ?? 0,
    );
  }

  static List<ClientStatement> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => ClientStatement.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class StatementTransaction {
  final int id;
  final int bookingId;
  final DateTime date;
  final String description;
  final String type;
  final double debit;
  final double credit;
  final double balance;
  final String? referenceNumber;

  const StatementTransaction({
    required this.id,
    required this.bookingId,
    required this.date,
    required this.description,
    required this.type,
    required this.debit,
    required this.credit,
    required this.balance,
    this.referenceNumber,
  });

  factory StatementTransaction.fromJson(Map<String, dynamic> json) {
    return StatementTransaction(
      id:              (json['id'] as num?)?.toInt() ?? 0,
      bookingId:       (json['booking_id'] as num?)?.toInt() ?? 0,
      date:            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      description:     json['description']?.toString() ?? '',
      type:            json['type']?.toString() ?? '',
      debit:           double.tryParse(json['debit']?.toString() ?? '0') ?? 0,
      credit:          double.tryParse(json['credit']?.toString() ?? '0') ?? 0,
      balance:         double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      referenceNumber: json['reference_number'] as String?,
    );
  }
}
