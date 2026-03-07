import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../datasources/local/preferences_helper.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// ── Api client ────────────────────────────────────────────────────────────────

class ApiClient {
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl:        AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader:      'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;

  // ── Mosque API ──────────────────────────────────────────────────────────────

  /// Fetch mosques near [lat]/[lng] within [radiusKm] km.
  Future<List<Map<String, dynamic>>> getMosquesNearby({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/mosques/',
      queryParameters: {
        'lat':    lat,
        'lng':    lng,
        'radius': radiusKm,
      },
    );
    final results = response.data?['results'] as List<dynamic>? ?? [];
    return results.cast<Map<String, dynamic>>();
  }

  /// Submit a new mosque (community contribution). Requires auth.
  Future<void> submitMosque(Map<String, dynamic> mosqueData) async {
    await _dio.post<void>('/api/v1/mosques/', data: mosqueData);
  }

  /// Update jamat times for a mosque. Requires auth.
  Future<void> updateJamatTimes(int mosqueId, Map<String, dynamic> times) async {
    await _dio.patch<void>('/api/v1/mosques/$mosqueId/jamat/', data: times);
  }

  // ── Prayer times API ────────────────────────────────────────────────────────

  /// Fetch prayer times for [lat]/[lng] on [date].
  Future<Map<String, dynamic>> getPrayerTimes({
    required double lat,
    required double lng,
    required DateTime date,
    String method = 'karachi',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/prayer-times/',
      queryParameters: {
        'lat':    lat,
        'lng':    lng,
        'date':   date.toIso8601String().substring(0, 10),
        'method': method,
      },
    );
    return response.data ?? {};
  }

  // ── Hadith API ──────────────────────────────────────────────────────────────

  /// Fetch all 365 hadiths (for initial sync).
  Future<List<Map<String, dynamic>>> getHadiths() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/hadiths/');
    final results = response.data?['results'] as List<dynamic>? ?? [];
    return results.cast<Map<String, dynamic>>();
  }

  // ── Quran API ───────────────────────────────────────────────────────────────

  /// Fetch all surahs with metadata (no ayahs).
  Future<List<Map<String, dynamic>>> getSurahs() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/quran/surahs/');
    final results = response.data?['results'] as List<dynamic>? ?? [];
    return results.cast<Map<String, dynamic>>();
  }

  /// Fetch a specific surah with all ayahs.
  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/quran/surahs/$surahNumber/',
    );
    return response.data ?? {};
  }

  // ── Auth API ────────────────────────────────────────────────────────────────

  /// Request OTP to email.
  Future<void> requestOtp(String email) async {
    await _dio.post<void>('/api/v1/auth/otp/', data: {'email': email});
  }

  /// Verify OTP and obtain JWT tokens.
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/otp/verify/',
      data: {'email': email, 'otp': otp},
    );
    return response.data ?? {};
  }

  /// Refresh JWT access token.
  Future<String?> refreshToken() async {
    final prefs   = PreferencesHelper.instance;
    final refresh = await prefs.getRefreshToken();
    if (refresh == null) return null;

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/token/refresh/',
      data: {'refresh': refresh},
    );
    final access = response.data?['access'] as String?;
    if (access != null) {
      await prefs.setAccessToken(access);
    }
    return access;
  }

  // ── Notifications API ───────────────────────────────────────────────────────

  /// Register / update FCM token on the backend.
  Future<void> registerFcmToken(String fcmToken) async {
    await _dio.post<void>('/api/v1/notifications/register/', data: {
      'fcm_token': fcmToken,
      'platform':  Platform.isAndroid ? 'android' : 'ios',
    });
  }
}

// ── Auth interceptor ──────────────────────────────────────────────────────────

class _AuthInterceptor extends QueuedInterceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await PreferencesHelper.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh once
      try {
        final prefs   = PreferencesHelper.instance;
        final refresh = await prefs.getRefreshToken();
        if (refresh != null) {
          final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
          final res = await dio.post<Map<String, dynamic>>(
            '/api/v1/auth/token/refresh/',
            data: {'refresh': refresh},
          );
          final newAccess = res.data?['access'] as String?;
          if (newAccess != null) {
            await prefs.setAccessToken(newAccess);
            // Retry original request
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
            final retryDio = Dio();
            final response = await retryDio.fetch<dynamic>(err.requestOptions);
            return handler.resolve(response);
          }
        }
      } catch (_) {
        // Refresh failed — clear tokens
        await PreferencesHelper.instance.clearTokens();
      }
    }
    handler.next(err);
  }
}

// ── Logging interceptor ───────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] Error ${err.response?.statusCode}: ${err.message}');
    handler.next(err);
  }
}

// ── Typed exceptions ──────────────────────────────────────────────────────────

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int?   statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';

  static ApiException fromDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    final msg  = data is Map
        ? (data['detail'] ?? data['message'] ?? e.message ?? 'Unknown error')
        : (e.message ?? 'Unknown error');
    return ApiException(msg.toString(), statusCode: code);
  }
}
