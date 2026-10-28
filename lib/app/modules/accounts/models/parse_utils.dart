import 'dart:convert';

/// Defensive JSON helpers shared by the accounts models and views.
///
/// The backend stores loosely typed values ('NA', numeric strings, ints for
/// money, nulls) so every field is parsed tolerantly instead of with `as` casts.

int? toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    return int.tryParse(s) ?? double.tryParse(s)?.toInt();
  }
  return null;
}

int toInt(dynamic v, [int fallback = 0]) => toIntOrNull(v) ?? fallback;

double? toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

double toDouble(dynamic v, [double fallback = 0.0]) =>
    toDoubleOrNull(v) ?? fallback;

/// Null / empty / 'NA' / 'null' become null.
String? toStrOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s == 'NA' || s == 'null') return null;
  return s;
}

String toStr(dynamic v, [String fallback = '']) => toStrOrNull(v) ?? fallback;

/// Missing or unparseable dates are null — never `DateTime.now()`.
DateTime? toDate(dynamic v) {
  final s = toStrOrNull(v);
  if (s == null) return null;
  return DateTime.tryParse(s);
}

/// Reads [key] from a loosely typed row (Map or anything else).
dynamic field(dynamic row, String key) => row is Map ? row[key] : null;

/// Decodes a column that may arrive as a JSON string or already decoded.
dynamic decodeJsonField(dynamic v) {
  if (v is String) {
    if (v.trim().isEmpty) return null;
    try {
      return jsonDecode(v);
    } catch (_) {
      return null;
    }
  }
  return v;
}

Map<String, dynamic>? toJsonMap(dynamic v) {
  final d = decodeJsonField(v);
  return d is Map ? Map<String, dynamic>.from(d) : null;
}

List<int>? toIntList(dynamic v) {
  final d = decodeJsonField(v);
  if (d is! List) return null;
  return d.map(toIntOrNull).whereType<int>().toList();
}

/// Parses a list of rows, skipping (instead of throwing on) malformed ones.
List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is! List) return <T>[];
  final out = <T>[];
  for (final row in data) {
    if (row is! Map) continue;
    try {
      out.add(fromJson(Map<String, dynamic>.from(row)));
    } catch (_) {
      // Skip the bad row; one malformed record must not blank the list.
    }
  }
  return out;
}

/// Extracts the human-readable error from a backend response body.
String? apiErrorMessage(dynamic data) {
  if (data is Map) {
    final msg = data['error'] ?? data['message'];
    if (msg != null && msg.toString().trim().isNotEmpty) return msg.toString();
  }
  return null;
}
