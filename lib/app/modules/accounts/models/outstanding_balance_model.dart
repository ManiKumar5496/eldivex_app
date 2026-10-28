import 'parse_utils.dart';

class AgingBucket {
  final String label;
  final double amount;
  final int count;

  AgingBucket({
    required this.label,
    required this.amount,
    required this.count,
  });

  factory AgingBucket.fromJson(Map<String, dynamic> json) {
    return AgingBucket(
      label:  json['label']?.toString() ?? '',
      amount: toDoubleOrNull(json['amount']) ?? 0.0,
      count:  toIntOrNull(json['count']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'label':  label,
    'amount': amount,
    'count':  count,
  };
}

class OutstandingBalanceModel {
  final int? clientId;
  final int? bookingId;
  final double totalBilled;
  final double totalPaid;
  final double totalWriteOff;
  final double totalCreditNoteIssued;
  final double totalCreditNoteApplied;
  final double totalRefunded;
  final double totalInternalTransferIn;
  final double totalInternalTransferOut;
  final double outstandingAmount;
  final String? lastUpdated;
  final List<AgingBucket>? agingBuckets;

  OutstandingBalanceModel({
    this.clientId,
    this.bookingId,
    required this.totalBilled,
    required this.totalPaid,
    required this.totalWriteOff,
    required this.totalCreditNoteIssued,
    required this.totalCreditNoteApplied,
    required this.totalRefunded,
    required this.totalInternalTransferIn,
    required this.totalInternalTransferOut,
    required this.outstandingAmount,
    this.lastUpdated,
    this.agingBuckets,
  });

  factory OutstandingBalanceModel.fromJson(Map<String, dynamic> json) {
    final buckets = json['aging_buckets'] is List
        ? parseList(json['aging_buckets'], AgingBucket.fromJson)
        : null;
    // getClientOutstanding / getBookingOutstanding answer in camelCase
    // (totalBilled, outstandingAmount, …); older payloads used snake_case.
    double amt(String snake, String camel) =>
        toDoubleOrNull(json[camel]) ?? toDoubleOrNull(json[snake]) ?? 0.0;

    return OutstandingBalanceModel(
      clientId:                  toIntOrNull(json['clientId'] ?? json['client_id']),
      bookingId:                 toIntOrNull(json['bookingId'] ?? json['booking_id']),
      totalBilled:               amt('total_billed', 'totalBilled'),
      totalPaid:                 amt('total_paid', 'totalPaid'),
      totalWriteOff:             amt('total_write_off', 'totalWriteOff'),
      totalCreditNoteIssued:     amt('total_credit_note_issued', 'totalCreditNoteIssued'),
      totalCreditNoteApplied:    amt('total_credit_note_applied', 'totalCreditNoteApplied'),
      totalRefunded:             amt('total_refunded', 'totalRefunded'),
      totalInternalTransferIn:   amt('total_internal_transfer_in', 'totalInternalTransferIn'),
      totalInternalTransferOut:  amt('total_internal_transfer_out', 'totalInternalTransferOut'),
      outstandingAmount:         amt('outstanding_amount', 'outstandingAmount'),
      lastUpdated:               toStrOrNull(json['last_updated']),
      agingBuckets:              buckets,
    );
  }

  Map<String, dynamic> toJson() => {
    'client_id':                  clientId,
    'booking_id':                 bookingId,
    'total_billed':               totalBilled,
    'total_paid':                 totalPaid,
    'total_write_off':            totalWriteOff,
    'total_credit_note_issued':   totalCreditNoteIssued,
    'total_credit_note_applied':  totalCreditNoteApplied,
    'total_refunded':             totalRefunded,
    'total_internal_transfer_in':  totalInternalTransferIn,
    'total_internal_transfer_out': totalInternalTransferOut,
    'outstanding_amount':          outstandingAmount,
    'last_updated':                lastUpdated,
    'aging_buckets':               agingBuckets?.map((e) => e.toJson()).toList(),
  };
}
