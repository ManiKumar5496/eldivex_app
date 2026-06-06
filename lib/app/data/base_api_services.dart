import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../main.dart';
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
        'authorization': "Bearer ${box.read("user_token")}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  // ── Shared helpers ──────────────────────────────────────────────────────────

  Map<String, String> get _authHeaders => {
        'authorization': "Bearer ${box.read("user_token")}",
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
      final response = await _dio.post(endpoint, data: data);
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
          'authorization': "Bearer ${box.read("user_token")}",
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
          'authorization': "Bearer ${box.read("user_token")}",
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
