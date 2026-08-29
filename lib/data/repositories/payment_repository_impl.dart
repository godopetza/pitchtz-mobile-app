import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/malipo_operator.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/mock_data.dart';

/// Fallback operators shown when the Malipo network call fails.
const _kFallbackOperators = [
  MalipoOperator(
    id: 'MPESA_TZA',
    name: 'M-Pesa',
    logoUrl: null,
    color: 0xFF3FA34D,
  ),
  MalipoOperator(
    id: 'AIRTEL_TZA',
    name: 'Airtel Money',
    logoUrl: null,
    color: 0xFFD9403A,
  ),
  MalipoOperator(
    id: 'TIGOPESA_TZA',
    name: 'Tigo Pesa',
    logoUrl: null,
    color: 0xFF0066CC,
  ),
];

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl() : _dio = _buildDio();

  final Dio _dio;

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.malipo.flutterai.dev/v1/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
        validateStatus: (_) => true,
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[malipo] $o'),
      ));
    }
    return dio;
  }

  // ---------------------------------------------------------------------------
  // PaymentRepository
  // ---------------------------------------------------------------------------

  /// Returns the 5 static saved-payment-method entries (mock data).
  @override
  List<PaymentMethod> getMethods() => MockData.paymentMethods;

  /// Fetches active operators from Malipo.
  /// On any failure returns [_kFallbackOperators].
  @override
  Future<List<MalipoOperator>> getOperators() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('providers/active');
      final body = res.data;

      if (body == null ||
          body['success'] != true ||
          body['data'] is! List) {
        debugPrint('[malipo] Unexpected envelope — using fallback operators');
        return _kFallbackOperators;
      }

      final rawList = body['data'] as List<dynamic>;
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(_operatorFromJson)
          .toList();
    } catch (e, st) {
      debugPrint('[malipo] getOperators failed: $e\n$st');
      return _kFallbackOperators;
    }
  }

  // ---------------------------------------------------------------------------
  // JSON mapping
  // ---------------------------------------------------------------------------

  static MalipoOperator _operatorFromJson(Map<String, dynamic> json) {
    // Parse optional hex color string, e.g. "#3FA34D" → 0xFF3FA34D.
    int color = 0xFF888888; // neutral grey default
    final rawColor = json['color'];
    if (rawColor is String && rawColor.isNotEmpty) {
      final hex = rawColor.replaceFirst('#', '');
      final parsed = int.tryParse(
        hex.length == 6 ? 'FF$hex' : hex,
        radix: 16,
      );
      if (parsed != null) color = parsed;
    } else if (rawColor is int) {
      color = rawColor;
    }

    return MalipoOperator(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      logoUrl: json['logo_url'] as String?,
      color: color,
    );
  }
}
