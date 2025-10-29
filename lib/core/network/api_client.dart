// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../../config/constants.dart';
import 'api_exception.dart';
import 'dart:async';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final String baseUrl;

  // Callback for unauthorized errors (401)
  Future<void> Function()? _onUnauthorizedCallback;

  // ✅ FIX: Token refresh için Completer kullanarak senkronizasyon
  bool _isRefreshing = false;
  Completer<String>? _tokenRefreshCompleter;

  ApiClient({
    required Dio dio,
    required SecureStorageService secureStorage,
    required this.baseUrl,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _setupInterceptors();
  }

  void setOnUnauthorizedCallback(Future<void> Function() callback) {
    _onUnauthorizedCallback = callback;
  }

  void _setupInterceptors() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('🌐 [REQUEST] ${options.method} ${options.uri}');
          debugPrint('📦 [REQUEST DATA] ${options.data}');
          debugPrint('🔍 [REQUEST PARAMS] ${options.queryParameters}');

          final token = await _secureStorage.read(StorageKeys.accessToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('🔑 [AUTH] Token eklendi');
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
          debugPrint('📦 [RESPONSE DATA] ${response.data}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          debugPrint('❌ [ERROR] ${error.type} ${error.requestOptions.uri}');
          debugPrint('📦 [ERROR RESPONSE] ${error.response?.data}');
          debugPrint('🔢 [STATUS CODE] ${error.response?.statusCode}');

          // 🔥 401 Unauthorized - Token Refresh Mekanizması
          if (error.response?.statusCode == 401) {
            debugPrint('🔐 [UNAUTHORIZED] Token süresi dolmuş, refresh deneniyor...');

            try {
              // ✅ FIX: Token refresh işlemi devam ediyorsa, Completer ile bekle
              if (_isRefreshing) {
                debugPrint('⏳ [TOKEN REFRESH] Zaten devam ediyor, bekleniyor...');

                // Mevcut refresh işleminin tamamlanmasını bekle
                final newToken = await _tokenRefreshCompleter!.future;

                // Yeni token ile başarısız olan isteği tekrar dene
                final requestOptions = error.requestOptions;
                requestOptions.headers['Authorization'] = 'Bearer $newToken';

                debugPrint('🔄 [RETRY] Refresh tamamlandı, istek tekrar deneniyor...');

                try {
                  final retryResponse = await _dio.fetch(requestOptions);
                  return handler.resolve(retryResponse);
                } catch (retryError) {
                  debugPrint('❌ [RETRY ERROR] Tekrar deneme başarısız: $retryError');
                  return handler.reject(error);
                }
              }

              // ✅ FIX: Yeni bir Completer oluştur
              _isRefreshing = true;
              _tokenRefreshCompleter = Completer<String>();

              // Refresh token'ı al
              final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);

              if (refreshToken == null || refreshToken.isEmpty) {
                debugPrint('❌ [REFRESH TOKEN] Bulunamadı, logout yapılıyor...');
                _tokenRefreshCompleter!.completeError('Refresh token not found');
                _isRefreshing = false;
                _tokenRefreshCompleter = null;
                await _handleLogout();
                return handler.reject(error);
              }

              debugPrint('🔄 [TOKEN REFRESH] Yeni token isteniyor...');

              // Yeni token isteği yap (Authorization header'ı olmadan)
              final refreshResponse = await _dio.post(
                ApiConstants.refresh,
                data: {'refresh': refreshToken},
                options: Options(
                  headers: {
                    'Authorization': null, // Eski token'ı kaldır
                    'Content-Type': 'application/json',
                  },
                ),
              );

              // Yeni token'ları kaydet
              final newAccessToken = refreshResponse.data['access'] as String?;
              final newRefreshToken = refreshResponse.data['refresh'] as String?;

              if (newAccessToken == null) {
                debugPrint('❌ [TOKEN REFRESH] Yeni access token alınamadı');
                _tokenRefreshCompleter!.completeError('New access token not received');
                _isRefreshing = false;
                _tokenRefreshCompleter = null;
                await _handleLogout();
                return handler.reject(error);
              }

              await _secureStorage.saveAccessToken(newAccessToken);

              if (newRefreshToken != null) {
                await _secureStorage.saveRefreshToken(newRefreshToken);
              }

              debugPrint('✅ [TOKEN REFRESH] Yeni token kaydedildi');

              // ✅ FIX: Completer'ı tamamla - bekleyen tüm istekler devam edecek
              _tokenRefreshCompleter!.complete(newAccessToken);

              // Başarısız olan isteği yeniden dene
              final requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              debugPrint('🔄 [RETRY] Başarısız istek tekrar deneniyor...');

              final retryResponse = await _dio.fetch(requestOptions);

              // ✅ FIX: İşlem tamamlandı, flag'leri temizle
              _isRefreshing = false;
              _tokenRefreshCompleter = null;

              return handler.resolve(retryResponse);

            } catch (refreshError) {
              debugPrint('❌ [TOKEN REFRESH ERROR] $refreshError');

              // ✅ FIX: Hata durumunda Completer'ı hatayla tamamla
              if (_tokenRefreshCompleter != null && !_tokenRefreshCompleter!.isCompleted) {
                _tokenRefreshCompleter!.completeError(refreshError);
              }

              _isRefreshing = false;
              _tokenRefreshCompleter = null;

              // Refresh başarısız oldu, logout yap
              await _handleLogout();
              return handler.reject(error);
            }
          }

          // 403 Forbidden
          if (error.response?.statusCode == 403) {
            debugPrint('🚫 [FORBIDDEN] Bu işlem için yetkiniz yok');
          }

          // 500+ Server errors
          if (error.response?.statusCode != null && error.response!.statusCode! >= 500) {
            debugPrint('🔴 [SERVER ERROR] ${error.response?.statusCode} - Sunucu hatası');
          }

          return handler.next(error);
        },
      ),
    );
  }

  // 🔥 Logout işlemini merkezi olarak yönet
  Future<void> _handleLogout() async {
    try {
      debugPrint('🚪 [LOGOUT] Token temizleniyor ve callback çağrılıyor...');

      // Token'ları temizle
      await _secureStorage.delete(StorageKeys.accessToken);
      await _secureStorage.delete(StorageKeys.refreshToken);
      debugPrint('🗑️ [TOKEN CLEANUP] Token\'lar silindi');

      // Callback çağır
      if (_onUnauthorizedCallback != null) {
        try {
          await _onUnauthorizedCallback!();
          debugPrint('✅ [CALLBACK] Unauthorized callback başarıyla çağrıldı');
        } catch (e) {
          debugPrint('⚠️ [CALLBACK ERROR] $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [LOGOUT ERROR] $e');
    }
  }

  // GET Request
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // POST Request
  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // PUT Request
  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // File Upload
  Future<Response> upload(
      String path, {
        required FormData formData,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // File Download
  Future<Response> download(
      String path,
      String savePath, {
        ProgressCallback? onReceiveProgress,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Dio instance'ına erişim için getter
  Dio get dio => _dio;
}