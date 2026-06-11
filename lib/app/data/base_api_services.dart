import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart' hide Response;
import '../../main.dart';
import '../routes/app_pages.dart';
import '../widgets/helper_ui.dart';
import 'api_constant_url.dart';

/// Central HTTP service. All methods log 4xx/5xx responses so issues are
/// visible in debug output without leaking to production analytics.
class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseURL,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'authorization': "Bearer ${ApiService.activeToken()}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          _handleOrgSuspended(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _handleOrgSuspended(error.response);
          handler.next(error);
        },
      ),
    );
  }

  /// Debounce so a burst of parallel 403s triggers the logout only once.
  static bool _handlingSuspension = false;

  /// When the owner platform suspends this organisation, the backend rejects
  /// every request with 403 {code: 'ORG_SUSPENDED'}. Clear the active session
  /// and send the user back to its login screen with an explanation.
  static void _handleOrgSuspended(Response? response) {
    if (response == null || response.statusCode != 403) return;
    final data = response.data;
    if (data is! Map || data['code'] != 'ORG_SUSPENDED') return;
    // Not logged in (e.g. a rejected login attempt) — the login screen shows
    // the backend message itself; nothing to clear or redirect.
    if (activeToken().isEmpty) return;
    if (_handlingSuspension) return;
    _handlingSuspension = true;

    final session = box.read('active_session') ?? 'admin';
    final String loginRoute;
    if (session == 'hp') {
      for (final k in ['hp_token', 'hp_id', 'hp_org_id', 'hp_name', 'active_session']) {
        box.remove(k);
      }
      loginRoute = Routes.HP_LOGIN;
    } else if (session == 'client') {
      for (final k in ['client_token', 'client_id', 'client_org_id', 'client_name', 'active_session']) {
        box.remove(k);
      }
      loginRoute = Routes.CLIENT_LOGIN;
    } else {
      for (final k in ['user_token', 'role_id', 'org_id', 'user', 'selected_page_index']) {
        box.remove(k);
      }
      loginRoute = Routes.LOGIN;
    }

    Get.offAllNamed(loginRoute);
    HelperUi.showToast(
      message: data['message']?.toString() ??
          "Your organisation's account has been suspended. Contact support.",
      backgroundColor: Colors.red,
    );
    Future.delayed(const Duration(seconds: 3), () => _handlingSuspension = false);
  }

  /// Bearer token for the active session. The caregiver portal sets
  /// `active_session = 'hp'` on login so its requests carry `hp_token`;
  /// the admin app leaves it unset and keeps using `user_token`. This keeps the
  /// two sessions isolated within the same app instance.
  static String activeToken() {
    final session = box.read('active_session') ?? 'admin';
    final key = session == 'hp'
        ? 'hp_token'
        : session == 'client'
            ? 'client_token'
            : 'user_token';
    return (box.read(key) ?? '').toString();
  }

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
  }

  // ── GET Raw (returns full Response) ────────────────────────────────────────
  Future<Response?> getRaw(String endpoint) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: _authHeaders),
      );
      _logBadResponse('GET', endpoint, response);
      return response;
    } catch (e) {
      _logError('GET', endpoint, e);
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
      final data = response.data;
      if (data is List) {
        return data.map((item) => fromJson(item)).toList();
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
      return response;
    } catch (e) {
      _logError('PUT', endpoint, e);
      return null;
    }
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────
  Future<bool> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      _logBadResponse('DELETE', endpoint, response);
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
      return response;
    } catch (e) {
      _logError('PATCH', endpoint, e);
      return null;
    }
  }
}
