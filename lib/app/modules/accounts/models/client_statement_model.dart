import 'parse_utils.dart';

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
      id: toInt(json['id']),
      userId: toInt(json['user_id']),
      bookingId: toInt(json['booking_id']),
      clientName: toStr(json['client_name']),
      clientMobile: toStr(json['client_mobile']),
      patientName: toStr(json['patient_name']),
      serviceName: toStr(json['service_name']),
      transactions: parseList(json['transactions'], StatementTransaction.fromJson),
      totalBilled: toDouble(json['total_billed']),
      totalReceived: toDouble(json['total_received']),
      totalWriteOff: toDouble(json['total_write_off']),
      closingBalance: toDouble(json['closing_balance']),
    );
  }

  static List<ClientStatement> listFromJson(List<dynamic> jsonList) {
    return parseList(jsonList, ClientStatement.fromJson);
  }
}

class StatementTransaction {
  final int id;
  final int bookingId;
  final DateTime? date;
  final String description;
  final String type;
  final double debit;
  final double credit;
  final double balance;
  final String? referenceNumber;

  const StatementTransaction({
    required this.id,
    required this.bookingId,
    this.date,
    required this.description,
    required this.type,
    required this.debit,
    required this.credit,
    required this.balance,
    this.referenceNumber,
  });

  factory StatementTransaction.fromJson(Map<String, dynamic> json) {
    return StatementTransaction(
      id:              toInt(json['id']),
      bookingId:       toInt(json['booking_id']),
      date:            toDate(json['date']),
      description:     toStr(json['description']),
      type:            toStr(json['type']),
      debit:           toDouble(json['debit']),
      credit:          toDouble(json['credit']),
      balance:         toDouble(json['balance']),
      referenceNumber: toStrOrNull(json['reference_number']),
    );
  }
}
