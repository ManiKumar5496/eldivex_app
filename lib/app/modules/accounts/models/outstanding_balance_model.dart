double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

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
      amount: _toDouble(json['amount']) ?? 0.0,
      count:  _toInt(json['count']) ?? 0,
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
    List<AgingBucket>? buckets;
    if (json['aging_buckets'] is List) {
      buckets = (json['aging_buckets'] as List)
          .map((e) => AgingBucket.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OutstandingBalanceModel(
      clientId:                  _toInt(json['client_id']),
      bookingId:                 _toInt(json['booking_id']),
      totalBilled:               _toDouble(json['total_billed']) ?? 0.0,
      totalPaid:                 _toDouble(json['total_paid']) ?? 0.0,
      totalWriteOff:             _toDouble(json['total_write_off']) ?? 0.0,
      totalCreditNoteIssued:     _toDouble(json['total_credit_note_issued']) ?? 0.0,
      totalCreditNoteApplied:    _toDouble(json['total_credit_note_applied']) ?? 0.0,
      totalRefunded:             _toDouble(json['total_refunded']) ?? 0.0,
      totalInternalTransferIn:   _toDouble(json['total_internal_transfer_in']) ?? 0.0,
      totalInternalTransferOut:  _toDouble(json['total_internal_transfer_out']) ?? 0.0,
      outstandingAmount:         _toDouble(json['outstanding_amount']) ?? 0.0,
      lastUpdated:               json['last_updated'] as String?,
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
