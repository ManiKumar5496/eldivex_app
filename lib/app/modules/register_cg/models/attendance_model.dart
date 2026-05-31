// ignore: depend_on_referenced_packages
import 'dart:convert';

class AttendanceDetails {
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String shiftType;
  final double workingHours;
  final String notes;

  const AttendanceDetails({
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.shiftType,
    this.workingHours = 0.0,
    this.notes = '',
  });

  factory AttendanceDetails.fromJson(Map<String, dynamic> json) {
    return AttendanceDetails(
      checkIn:      json['check_in']?.toString(),
      checkOut:     json['check_out']?.toString(),
      status:       json['status']?.toString() ?? 'not_marked',
      shiftType:    json['shift_type']?.toString() ?? 'live_out',
      workingHours: (json['working_hours'] as num?)?.toDouble() ?? 0.0,
      notes:        json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'check_in':      checkIn,
    'check_out':     checkOut,
    'status':        status,
    'shift_type':    shiftType,
    'working_hours': workingHours,
    'notes':         notes,
  };
}

class AttendanceModel {
  final int id;
  final int bookingId;
  final int? invId;
  final String fromDate;
  final AttendanceDetails attDetails;
  final int hpId;
  final String hpName;
  final String? hpPhone;
  final String createdOn;

  const AttendanceModel({
    required this.id,
    required this.bookingId,
    this.invId,
    required this.fromDate,
    required this.attDetails,
    required this.hpId,
    required this.hpName,
    this.hpPhone,
    required this.createdOn,
  });

  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> details = {};
    final raw = json['att_details'];
    if (raw is Map<String, dynamic>) {
      details = raw;
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map<String, dynamic>) details = parsed;
      } catch (_) {}
    }

    return AttendanceModel(
      id:        _parseInt(json['id']),
      bookingId: _parseInt(json['booking_id']),
      invId:     json['inv_id'] != null ? _parseInt(json['inv_id']) : null,
      fromDate:  json['from_date']?.toString() ?? '',
      attDetails: AttendanceDetails.fromJson(details),
      hpId:      _parseInt(json['hp_id']),
      hpName:    (json['hp_name']?.toString() ?? '').trim(),
      hpPhone:   json['hp_reg_phone_number']?.toString(),
      createdOn: json['created_on']?.toString() ?? '',
    );
  }

  static List<AttendanceModel> listFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(AttendanceModel.fromJson)
        .toList();
  }
}
