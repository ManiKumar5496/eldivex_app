import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart' hide Response;
import '../../main.dart';
import '../routes/app_pages.dart';
import '../modules/role/controllers/role_controller.dart';
import '../widgets/helper_ui.dart';
import 'api_constant_url.dart';

/// Central HTTP service. All methods log 4xx/5xx responses so issues are
/// visible in debug output without leaking to production analytics.
class ApiService {
  /// One Dio for the whole app — every ApiService shares it, so the
  /// interceptor is installed once. Auth headers are set per request.
  static final Dio _sharedDio = _buildDio();

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseURL,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          _handleOrgSuspended(response);
          _handleUnauthorized(response);
          _handleModuleForbidden(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _handleOrgSuspended(error.response);
          _handleUnauthorized(error.response);
          _handleModuleForbidden(error.response);
          handler.next(error);
        },
      ),
    );
    return dio;
  }

  Dio get _dio => _sharedDio;

  /// Backend `error` / `message` from the most recent failed request (null
  /// after a successful one). Lets callers of the null-returning methods show
  /// the real reason instead of a generic message.
  static String? lastError;

  /// True for a 2xx response.
  static bool isOk(Response? r) =>
      r != null && r.statusCode != null && r.statusCode! >= 200 && r.statusCode! < 300;

  static bool _onLoginRoute() {
    final currentPath = Get.currentRoute.split('?').first;
    return currentPath == Routes.LOGIN ||
        currentPath == Routes.HP_LOGIN ||
        currentPath == Routes.CLIENT_LOGIN;
  }

  /// Clears the active session's keys and returns its login route.
  static String _clearActiveSession() {
    final session = box.read('active_session') ?? 'admin';
    if (session == 'hp') {
      for (final k in ['hp_token', 'hp_id', 'hp_org_id', 'hp_name', 'active_session']) {
        box.remove(k);
      }
      return Routes.HP_LOGIN;
    }
    if (session == 'client') {
      for (final k in ['client_token', 'client_id', 'client_org_id', 'client_name', 'active_session']) {
        box.remove(k);
      }
      return Routes.CLIENT_LOGIN;
    }
    if (Get.isRegistered<RoleController>()) {
      Get.find<RoleController>().clearAuth();
    } else {
      for (final k in ['user_token', 'role_id', 'org_id', 'user', 'selected_page_index']) {
        box.remove(k);
      }
    }
    return Routes.LOGIN;
  }

  /// Debounce so a burst of parallel 403s triggers the logout only once.
  static bool _handlingSuspension = false;

  /// When the owner platform suspends this organisation, the backend rejects
  /// every request with 403 {code: 'ORG_SUSPENDED'}. Clear the active session
  /// and send the user back to its login screen with an explanation.
  static void _handleOrgSuspended(Response? response) {
    if (response == null || response.statusCode != 403) return;
    final raw = response.data;
    final data = raw is List<int> ? decodeJsonBytes(raw) : raw;
    if (data is! Map || data['code'] != 'ORG_SUSPENDED') return;
    // Not logged in (e.g. a rejected login attempt) — the login screen shows
    // the backend message itself; nothing to clear or redirect.
    if (activeToken().isEmpty) return;
    // A rejected attempt on a login screen (possibly against another portal's
    // session) — the screen shows the message; never clear or redirect.
    if (_onLoginRoute()) return;
    if (_handlingSuspension) return;
    _handlingSuspension = true;

    final loginRoute = _clearActiveSession();
    Get.offAllNamed(loginRoute);
    HelperUi.showToast(
      message: data['message']?.toString() ??
          "Your organisation's account has been suspended. Contact support.",
      backgroundColor: Colors.red,
    );
    Future.delayed(const Duration(seconds: 3), () => _handlingSuspension = false);
  }

  /// Debounce so a burst of parallel 401s triggers the logout only once.
  static bool _handlingUnauthorized = false;

  /// The backend rejected the active session token (expired or invalid).
  /// Clear the stale session and send the user back to its login screen —
  /// otherwise protected pages render dead-end empty states ("No Access
  /// Assigned") instead of redirecting.
  static void _handleUnauthorized(Response? response) {
    if (response == null || response.statusCode != 401) return;
    // A 401 with no stored token is a failed login attempt — the login
    // screen shows the backend message itself; nothing to clear or redirect.
    if (activeToken().isEmpty) return;
    // A 401 on a login screen is also a failed attempt (possibly against a
    // different portal's session) — never clear or redirect from there.
    if (_onLoginRoute()) return;
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;

    final loginRoute = _clearActiveSession();
    Get.offAllNamed(loginRoute);
    HelperUi.showToast(
      message: "Your session has expired. Please log in again.",
      backgroundColor: Colors.red,
    );
    Future.delayed(const Duration(seconds: 3), () => _handlingUnauthorized = false);
  }

  static bool _handlingForbidden = false;

  /// 403 {code: 'MODULE_FORBIDDEN'}: the user's role lacks the module this
  /// endpoint belongs to. Tell them once per burst; callers handle the null.
  static void _handleModuleForbidden(Response? response) {
    if (response == null || response.statusCode != 403) return;
    final raw = response.data;
    final data = raw is List<int> ? decodeJsonBytes(raw) : raw;
    if (data is! Map || data['code'] != 'MODULE_FORBIDDEN') return;
    if (_handlingForbidden) return;
    _handlingForbidden = true;
    HelperUi.showToast(
      message: (data['error'] ?? "You do not have access to this feature").toString(),
      backgroundColor: Colors.red,
    );
    Future.delayed(const Duration(seconds: 3), () => _handlingForbidden = false);
  }

  /// Bearer token for the active session. The caregiver portal sets
  /// `active_session = 'hp'` on login so its requests carry `hp_token`;
  /// the admin app sets it to 'admin' and uses `user_token`. This keeps the
  /// sessions isolated within the same app instance.
  static String activeToken() {
    final session = box.read('active_session') ?? 'admin';
    final key = session == 'hp'
        ? 'hp_token'
        : session == 'client'
            ? 'client_token'
            : 'user_token';
    return (box.read(key) ?? '').toString();
  }

  /// Bearer header for the active session, for callers that must use their
  /// own request (e.g. binary downloads).
  static Map<String, String> authHeader() =>
      {'authorization': "Bearer ${ApiService.activeToken()}"};

  // ── Shared helpers ──────────────────────────────────────────────────────────

  Map<String, String> get _authHeaders => {
        'authorization': "Bearer ${ApiService.activeToken()}",
        "Content-Type": "application/json",
      };

  /// Log unexpected (4xx / 5xx) responses in debug builds.
  void _logBadResponse(String method, String endpoint, Response response) {
    if (response.statusCode != null && response.statusCode! >= 400) {
      debugPrint(
        "⚠️  $method $endpoint → ${response.statusCode} "
        "| body: ${response.data}",
      );
    }
  }

  void _logError(String method, String endpoint, Object e) {
    debugPrint("❌ $method $endpoint error: $e");
    lastError = _messageOf(e is DioException ? e.response?.data : null) ??
        (e is DioException && e.response == null
            ? "Unable to connect. Please check your internet connection."
            : "Something went wrong. Please try again.");
  }

  static String? _messageOf(dynamic data) {
    if (data is! Map) return null;
    final msg = data['error'] ?? data['message'];
    return msg?.toString();
  }

  /// Record the outcome of a request that did not throw.
  void _track(Response response) {
    lastError = isOk(response) ? null : (_messageOf(response.data) ?? "Request failed (${response.statusCode}).");
  }

  // ── GET Raw (returns full Response) ────────────────────────────────────────
  Future<Response?> getRaw(String endpoint) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('GET', endpoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('GET', endpoint, e);
      return null;
    }
  }

  /// Decodes a JSON body received as bytes; null if it isn't JSON.
  static dynamic decodeJsonBytes(List<int> raw) {
    try {
      return jsonDecode(utf8.decode(raw));
    } catch (_) {
      return null;
    }
  }

  // ── GET binary (file downloads) ─────────────────────────────────────────────
  /// Fetches [endpoint] as raw bytes with the session's auth header. Returns
  /// the Response (including error responses, whose body is decoded to a Map
  /// when it is JSON) or null on a connection error.
  Future<Response?> getBytes(String endpoint) async {
    try {
      final response = await _dio.get<List<int>>(
        endpoint,
        options: Options(
          headers: _authHeaders,
          responseType: ResponseType.bytes,
        ),
      );
      _track(response);
      return response;
    } catch (e) {
      _logError('GET', endpoint, e);
      if (e is DioException && e.response != null) {
        final r = e.response!;
        final raw = r.data;
        if (raw is List<int>) {
          r.data = decodeJsonBytes(raw) ?? raw;
        }
        lastError = _messageOf(r.data) ?? lastError;
        return r;
      }
      return null;
    }
  }

  // ── GET single object ───────────────────────────────────────────────────────
  Future<T?> get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('GET', endpoint, response);
      _track(response);
      return fromJson(response.data);
    } catch (e) {
      _logError('GET', endpoint, e);
      return null;
    }
  }

  // ── GET list ────────────────────────────────────────────────────────────────
  Future<List<T>?> getList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('GET', endpoint, response);
      _track(response);
      final data = response.data;
      if (data is List) {
        // Parse row by row: one malformed row is skipped and logged instead
        // of blanking the whole list.
        final out = <T>[];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          try {
            out.add(fromJson(Map<String, dynamic>.from(item as Map)));
          } catch (e) {
            debugPrint("⚠️  GET $endpoint row $i skipped: $e | row: $item");
          }
        }
        return out;
      }
      throw Exception('Expected a list but got: ${data.runtimeType}');
    } catch (e) {
      _logError('GET', endpoint, e);
      return null;
    }
  }

  // ── POST typed ──────────────────────────────────────────────────────────────
  Future<T?> post<T>(
    String endpoint,
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('POST', endpoint, response);
      _track(response);
      return fromJson(response.data);
    } catch (e) {
      _logError('POST', endpoint, e);
      return null;
    }
  }

  // ── POST raw JSON ───────────────────────────────────────────────────────────
  Future<Response?> postRaw(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: jsonEncode(data),
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('POST', endpoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('POST', endpoint, e);
      // Return the HTTP error response (401, 404, 429…) so callers can read
      // the status code and backend message. Only null for connection errors.
      if (e is DioException && e.response != null) {
        return e.response;
      }
      return null;
    }
  }

  // ── POST dynamic list ───────────────────────────────────────────────────────
  Future<Response?> postDynamic(
    String endPoint,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final response = await _dio.post(
        endPoint,
        data: jsonEncode(data),
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('POST', endPoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('POST', endPoint, e);
      return null;
    }
  }

  // ── POST multipart form ─────────────────────────────────────────────────────
  Future<Response?> postForm(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: {
          'authorization': "Bearer ${ApiService.activeToken()}",
          "Content-Type": "multipart/form-data",
        }),
      );
      _logBadResponse('POST', endpoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('POST', endpoint, e);
      if (e is DioException && e.response != null) {
        return e.response;
      }
      return null;
    }
  }

  // ── PUT multipart form ──────────────────────────────────────────────────────
  Future<Response?> putForm(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: {
          'authorization': "Bearer ${ApiService.activeToken()}",
          "Content-Type": "multipart/form-data",
        }),
      );
      _logBadResponse('PUT', endpoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('PUT', endpoint, e);
      if (e is DioException && e.response != null) {
        return e.response;
      }
      return null;
    }
  }

  // ── PUT raw JSON ────────────────────────────────────────────────────────────
  Future<Response?> putRaw(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('PUT', endpoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('PUT', endpoint, e);
      return null;
    }
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────
  Future<bool> delete(String endpoint) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('DELETE', endpoint, response);
      _track(response);
      return true;
    } catch (e) {
      _logError('DELETE', endpoint, e);
      return false;
    }
  }

  // ── PATCH (no body) ─────────────────────────────────────────────────────────
  Future<Response?> patchApi(String endpoint) async {
    try {
      final response = await _dio.patch(
        endpoint,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('PATCH', endpoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('PATCH', endpoint, e);
      return null;
    }
  }

  // ── PATCH with JSON body ─────────────────────────────────────────────────────
  Future<Response?> patchRaw(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: jsonEncode(data),
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('PATCH', endpoint, response);
      _track(response);
      return response;
    } catch (e) {
      _logError('PATCH', endpoint, e);
      return null;
    }
  }
}
