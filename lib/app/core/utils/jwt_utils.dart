import 'dart:convert';

/// True when [token] is a JWT whose `exp` claim is in the past (30s leeway).
/// Malformed tokens count as expired so stale garbage in storage can't keep a
/// dead session alive; tokens without an `exp` claim are left to the backend.
bool isJwtExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload['exp'];
    if (exp is! int) return false;
    return DateTime.now().millisecondsSinceEpoch >= (exp - 30) * 1000;
  } catch (_) {
    return true;
  }
}

/// A stored session token is usable only if it exists and hasn't expired.
bool isValidSessionToken(dynamic token) {
  final t = (token ?? '').toString();
  return t.isNotEmpty && !isJwtExpired(t);
}
