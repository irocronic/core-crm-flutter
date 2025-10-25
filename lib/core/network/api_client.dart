import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../../config/constants.dart';

// ✅ YENİ: Global error callback
typedef OnUnauthorizedCallback = Future<void> Function();

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final String baseUrl;

  // ✅ YENİ: Unauthorized callback (login screen'e yönlendirmek için)
  OnUnauthorizedCallback? _onUnauthorizedCallback;

  ApiClient({
    required Dio dio,
    required SecureStorageService secureStorage,
    required this.baseUrl,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  // ✅ YENİ: Unauthorized callback setter
  void setOnUnauthorizedCallback(OnUnauthorizedCallback callback) {
    _onUnauthorizedCallback = callback;
  }

  // ✅ Dio instance'ına erişim için getter
  Dio get dio => _dio;

  Future<void> _onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    try {
      final token = await _secureStorage.read(StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      debugPrint('📤 [API Request] ${options.method} ${options.path}');
      handler.next(options);
    } catch (e) {
      debugPrint('❌ [API Request Error] Error in request interceptor: $e');
      handler.next(options);
    }
  }

  Future<void> _onError(
      DioException error,
      ErrorInterceptorHandler handler,
      ) async {
    debugPrint('❌ [API Error] ${error.response?.statusCode} ${error.requestOptions.path}');
    debugPrint('📋 [API Error Details] ${error.response?.data}');

    // ✅ FIXED: 401 Unauthorized - Token yenileme veya logout
    if (error.response?.statusCode == 401) {
      try {
        await _secureStorage.delete(StorageKeys.accessToken);
        await _secureStorage.delete(StorageKeys.refreshToken);

        debugPrint('🔑 [Token Expired] Token silindi, callback çağrılıyor...');

        // ✅ Callback varsa çağır (login screen'e yönlendirmek için)
        if (_onUnauthorizedCallback != null) {
          await _onUnauthorizedCallback!();
        }
      } catch (e) {
        debugPrint('❌ [Token Refresh Error] Error handling 401: $e');
      }
    }

    // ✅ FIXED: 403 Forbidden - İzinsiz erişim
    if (error.response?.statusCode == 403) {
      debugPrint('🚫 [Forbidden] Bu işlem için yetkiniz yok');
    }

    // ✅ FIXED: 500+ Server errors
    if (error.response?.statusCode != null && error.response!.statusCode! >= 500) {
      debugPrint('🔴 [Server Error] ${error.response?.statusCode} - Sunucu hatası');
    }

    handler.next(error);
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}