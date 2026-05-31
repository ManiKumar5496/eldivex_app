class ShiftBreakdown {
  final String shiftType;
  final int fullDays;
  final int halfDays;
  final double rate;
  final double subtotal;

  const ShiftBreakdown({
    required this.shiftType,
    required this.fullDays,
    required this.halfDays,
    required this.rate,
    required this.subtotal,
  });

  String get label => shiftType == 'live_in' ? 'Live-In' : 'Live-Out';
}

class CgPaymentSummary {
  final int hpId;
  final String hpName;
  final String periodFrom;
  final String periodTo;
  final int totalDays;
  final int liveInDays;
  final int liveOutDays;
  final int halfDays;
  final int absentDays;
  final int leaveDays;
  final List<ShiftBreakdown> breakdowns;
  final double totalPay;

  const CgPaymentSummary({
    required this.hpId,
    required this.hpName,
    required this.periodFrom,
    required this.periodTo,
    required this.totalDays,
    required this.liveInDays,
    required this.liveOutDays,
    required this.halfDays,
    required this.absentDays,
    required this.leaveDays,
    required this.breakdowns,
    required this.totalPay,
  });
}
