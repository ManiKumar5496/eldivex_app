class GetAllSupportTickets {
  final int id;
  final String userId;           // stored as int or 'NA' — kept as String to be safe
  final String supportTypeId;    // same
  final String bookingDetails;
  final DateTime? dueDate;       // nullable — may be 'NA' or missing
  final String startDate;
  final String endDate;
  final String title;
  final String description;
  final String comments;
  final String conversionlogDetails;
  final String createdByEmployee; // may be 'NA'
  final DateTime? createdOn;
  final String createdBy;
  final DateTime? updatedOn;
  final String updatedBy;
  final int status;               // always a real int (0/1/2/3)

  GetAllSupportTickets({
    required this.id,
    required this.userId,
    required this.supportTypeId,
    required this.bookingDetails,
    this.dueDate,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.description,
    required this.comments,
    required this.conversionlogDetails,
    required this.createdByEmployee,
    this.createdOn,
    required this.createdBy,
    this.updatedOn,
    required this.updatedBy,
    required this.status,
  });

  // ── Safe parsers ────────────────────────────────────────────────────────────

  static int _safeInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static String _safeStr(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  static DateTime? _safeDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s == 'NA') return null;
    return DateTime.tryParse(s);
  }

  // ── fromJson ────────────────────────────────────────────────────────────────

  factory GetAllSupportTickets.fromJson(Map<String, dynamic> json) {
    return GetAllSupportTickets(
      id:                   _safeInt(json['id']),
      userId:               _safeStr(json['user_id']),
      supportTypeId:        _safeStr(json['support_type_id']),
      bookingDetails:       _safeStr(json['booking_details']),
      dueDate:              _safeDate(json['due_date']),
      startDate:            _safeStr(json['start_date']),
      endDate:              _safeStr(json['end_date']),
      title:                _safeStr(json['title']),
      description:          _safeStr(json['description']),
      comments:             _safeStr(json['comments']),
      conversionlogDetails: _safeStr(json['conversionlog_details']),
      createdByEmployee:    _safeStr(json['created_by_employee']),
      createdOn:            _safeDate(json['created_on']),
      createdBy:            _safeStr(json['created_by']),
      updatedOn:            _safeDate(json['updated_on']),
      updatedBy:            _safeStr(json['updated_by']),
      status:               _safeInt(json['status']),
    );
  }

  // ── toJson ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id':                       id,
      'user_id':                  userId,
      'support_type_id':          supportTypeId,
      'booking_details':          bookingDetails,
      'due_date':                 dueDate?.toIso8601String(),
      'start_date':               startDate,
      'end_date':                 endDate,
      'title':                    title,
      'description':              description,
      'comments':                 comments,
      'conversionlog_details':    conversionlogDetails,
      'created_by_employee':      createdByEmployee,
      'created_on':               createdOn?.toIso8601String(),
      'created_by':               createdBy,
      'updated_on':               updatedOn?.toIso8601String(),
      'updated_by':               updatedBy,
      'status':                   status,
    };
  }
}
