// lib/core/network/api_interceptor.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../config/constants.dart';
import '../storage/secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  final Logger _logger = Logger();

  ApiInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Access token ekle
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    _logger.i('📤 Request: ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('📥 Response: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _logger.e('❌ Error: ${err.response?.statusCode} ${err.requestOptions.path}');

    // 401 Unauthorized - Token yenileme
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // Token yenileme isteği
          final response = await _dio.post(
            ApiConstants.refresh,
            data: {'refresh': refreshToken},
            options: Options(
              headers: {'Authorization': null}, // Eski token'ı kaldır
            ),
          );

          final newAccessToken = response.data['access'];
          await _storage.saveAccessToken(newAccessToken);

          // Başarısız olan isteği tekrar dene
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await _dio.fetch(options);
          return handler.resolve(retryResponse);
          
        } catch (e) {
          // Token yenilenemedi, logout yap
          _logger.e('Token yenilenemedi, logout yapılıyor');
          await _storage.clearAll();
          return handler.reject(err);
        }
      } else {
        // Refresh token yok, logout yap
        await _storage.clearAll();
        return handler.reject(err);
      }
    }

    handler.next(err);
  }
}