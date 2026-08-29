import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// Thin wrapper around [Dio] that:
///  * targets the PitchTZ base URL,
///  * unwraps the `{ success, data, message }` response envelope,
///  * converts every failure into a typed [ApiException].
///
/// ViewModels never see Dio directly — they get plain `data` or an exception.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: {'Accept': 'application/json'},
              // We validate the envelope ourselves, so accept any status.
              validateStatus: (_) => true,
            )) {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (o) => debugPrint('[api] $o'),
      ));
    }
  }

  final Dio _dio;

  /// GET returning the envelope's `data` as a `Map`.
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = await _get(path, query);
    if (data is Map<String, dynamic>) return data;
    throw ApiException('Unexpected response shape for $path');
  }

  /// GET returning the envelope's `data` as a `List`.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = await _get(path, query);
    if (data is List) return data;
    // Some list endpoints may wrap items under `data.items`.
    if (data is Map && data['items'] is List) return data['items'] as List;
    throw ApiException('Expected a list for $path');
  }

  /// POST returning the envelope's `data` (Map or null).
  Future<dynamic> post(String path, {Object? body}) async {
    try {
      final res = await _dio.post(path, data: body);
      return _unwrap(res);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<dynamic> _get(String path, Map<String, dynamic>? query) async {
    try {
      final res = await _dio.get(path,
          queryParameters: query?..removeWhere((_, v) => v == null));
      return _unwrap(res);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  /// Validates the envelope and returns `data`, or throws [ApiException].
  dynamic _unwrap(Response res) {
    final status = res.statusCode ?? 0;
    final body = res.data;

    if (body is Map<String, dynamic>) {
      final success = body['success'] == true;
      if (success && status >= 200 && status < 300) {
        return body['data'];
      }
      // Structured error envelope.
      final err = body['error'];
      if (err is Map) {
        throw ApiException(
          (err['message'] ?? '').toString(),
          code: err['code']?.toString(),
          statusCode: status,
        );
      }
    }

    // Non-enveloped or unexpected — still surface a useful status.
    throw ApiException(
      'Request failed (${status == 0 ? 'no status' : status}).',
      statusCode: status == 0 ? null : status,
    );
  }

  ApiException _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const ApiException('Connection timed out.', isNetwork: true);
      default:
        // If the server did send an envelope on the error response, reuse it.
        final res = e.response;
        if (res != null) {
          try {
            _unwrap(res);
          } on ApiException catch (api) {
            return api;
          }
        }
        return ApiException(e.message ?? 'Network error', isNetwork: true);
    }
  }
}
