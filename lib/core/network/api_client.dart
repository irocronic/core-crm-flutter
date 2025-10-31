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

  // Token refresh için Completer kullanarak senkronizasyon
  bool _isRefreshing = false;
  Completer<String>? _tokenRefreshCompleter;

  // Token refresh retry sayacı
  int _refreshRetryCount = 0;
  static const int _maxRefreshRetries = 3;

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

          // 401 Unauthorized - Token Refresh Mekanizması
          if (error.response?.statusCode == 401) {
            debugPrint('🔐 [UNAUTHORIZED] Token süresi dolmuş, refresh deneniyor...');

            try {
              // Token refresh işlemi devam ediyorsa, Completer ile bekle
              if (_isRefreshing) {
                debugPrint('⏳ [TOKEN REFRESH] Zaten devam ediyor, bekleniyor...');

                try {
                  // Mevcut refresh işleminin tamamlanmasını bekle
                  final newToken = await _tokenRefreshCompleter!.future.timeout(
                    const Duration(seconds: 10),
                    onTimeout: () {
                      throw TimeoutException('Token refresh timeout');
                    },
                  );

                  // Yeni token ile başarısız olan isteği tekrar dene
                  final requestOptions = error.requestOptions;
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';

                  debugPrint('🔄 [RETRY] Refresh tamamlandı, istek tekrar deneniyor...');

                  final retryResponse = await _dio.fetch(requestOptions);
                  return handler.resolve(retryResponse);
                } catch (completerError) {
                  debugPrint('❌ [COMPLETER ERROR] Refresh bekleme hatası: $completerError');
                  await _handleLogout();
                  return handler.reject(error);
                }
              }

              // Yeni bir Completer oluştur
              _isRefreshing = true;
              _tokenRefreshCompleter = Completer<String>();

              // Refresh token'ı al
              final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);

              if (refreshToken == null || refreshToken.isEmpty) {
                debugPrint('❌ [REFRESH TOKEN] Bulunamadı, logout yapılıyor...');

                // Completer'ı hatayla tamamla
                if (!_tokenRefreshCompleter!.isCompleted) {
                  _tokenRefreshCompleter!.completeError(
                    Exception('Refresh token not found'),
                  );
                }

                _isRefreshing = false;
                _tokenRefreshCompleter = null;
                _refreshRetryCount = 0;

                await _handleLogout();
                return handler.reject(error);
              }

              debugPrint('🔄 [TOKEN REFRESH] Yeni token isteniyor... (Deneme: ${_refreshRetryCount + 1}/$_maxRefreshRetries)');

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
              ).timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException('Token refresh request timeout');
                },
              );

              // Yeni token'ları kaydet
              final newAccessToken = refreshResponse.data['access'] as String?;
              final newRefreshToken = refreshResponse.data['refresh'] as String?;

              if (newAccessToken == null) {
                debugPrint('❌ [TOKEN REFRESH] Yeni access token alınamadı');

                // Completer'ı hatayla tamamla
                if (!_tokenRefreshCompleter!.isCompleted) {
                  _tokenRefreshCompleter!.completeError(
                    Exception('New access token not received'),
                  );
                }

                _isRefreshing = false;
                _tokenRefreshCompleter = null;
                _refreshRetryCount = 0;

                await _handleLogout();
                return handler.reject(error);
              }

              await _secureStorage.saveAccessToken(newAccessToken);

              if (newRefreshToken != null) {
                await _secureStorage.saveRefreshToken(newRefreshToken);
              }

              debugPrint('✅ [TOKEN REFRESH] Yeni token kaydedildi');

              // Retry sayacını sıfırla (başarılı refresh)
              _refreshRetryCount = 0;

              // Completer'ı tamamla - bekleyen tüm istekler devam edecek
              if (!_tokenRefreshCompleter!.isCompleted) {
                _tokenRefreshCompleter!.complete(newAccessToken);
              }

              // Başarısız olan isteği yeniden dene
              final requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              debugPrint('🔄 [RETRY] Başarısız istek tekrar deneniyor...');

              final retryResponse = await _dio.fetch(requestOptions);

              // İşlem tamamlandı, flag'leri temizle
              _isRefreshing = false;
              _tokenRefreshCompleter = null;

              return handler.resolve(retryResponse);

            } catch (refreshError) {
              debugPrint('❌ [TOKEN REFRESH ERROR] $refreshError');

              // Completer'ı hatayla tamamla (henüz tamamlanmadıysa)
              if (_tokenRefreshCompleter != null && !_tokenRefreshCompleter!.isCompleted) {
                _tokenRefreshCompleter!.completeError(refreshError);
              }

              // Retry sayacını artır
              _refreshRetryCount++;

              // Flag'leri temizle
              _isRefreshing = false;
              _tokenRefreshCompleter = null;

              // Max retry aşıldıysa logout yap
              if (_refreshRetryCount >= _maxRefreshRetries) {
                debugPrint('⚠️ [MAX RETRY] Token refresh max retry aşıldı, logout yapılıyor...');
                _refreshRetryCount = 0;
                await _handleLogout();
              } else {
                debugPrint('⚠️ [RETRY] Token refresh tekrar denenecek...');
              }

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

  /// Logout işlemini merkezi olarak yönet
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

  /// Token refresh durumunu sıfırla (test veya debug için)
  void resetRefreshState() {
    _isRefreshing = false;
    _tokenRefreshCompleter = null;
    _refreshRetryCount = 0;
    debugPrint('🔄 [RESET] Token refresh state sıfırlandı');
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