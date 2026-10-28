import 'dart:convert';

/// One row of the admin bell feed (edx_notifications).
///
/// Parsing is defensive throughout — the backend stores loosely-typed values
/// ('NA', numeric strings, JSON-as-text), and a single bad row must never
/// blank the whole panel.
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String createdOn;
  bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdOn,
    required this.read,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _toInt(json['id']),
      type: _toStr(json['type'], fallback: 'system'),
      title: _toStr(json['title']),
      body: _toStr(json['body']),
      data: _toMap(json['data']),
      createdOn: _toStr(json['created_on']),
      read: _toInt(json['read_flag']) == 1 || json['read_flag'] == true,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String _toStr(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    final s = v.toString();
    return (s.isEmpty || s == 'NA' || s == 'null') ? fallback : s;
  }

  static Map<String, dynamic> _toMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is String && v.isNotEmpty) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  DateTime? get createdAt => DateTime.tryParse(createdOn.replaceFirst(' ', 'T'));

  /// "Just now" / "5m ago" / "3h ago" / "2d ago" / "12 Jun".
  String get timeAgo {
    final dt = createdAt;
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
