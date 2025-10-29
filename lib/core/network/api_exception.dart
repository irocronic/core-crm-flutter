// lib/core/network/api_exception.dart

import 'package:dio/dio.dart';

/// API'den gelen hataları temsil eden özel exception sınıfı
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? errors;
  final DioExceptionType? type;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.errors,
    this.type,
  });

  /// DioException'ı ApiException'a dönüştürür
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.',
          statusCode: 408,
          type: e.type,
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Veri gönderme zaman aşımına uğradı. Lütfen tekrar deneyin.',
          statusCode: 408,
          type: e.type,
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Veri alma zaman aşımına uğradı. Lütfen tekrar deneyin.',
          statusCode: 408,
          type: e.type,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Güvenlik sertifikası hatası. Lütfen yöneticinize başvurun.',
          statusCode: 495,
          type: e.type,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(e);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'İstek iptal edildi.',
          statusCode: 499,
          type: e.type,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.',
          statusCode: 0,
          type: e.type,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
          statusCode: 0,
          type: e.type,
        );
    }
  }

  /// BadResponse durumunu işler
  static ApiException _handleBadResponse(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Mesaj çıkarma
    String message = _extractErrorMessage(data, statusCode);

    // Validation errors
    Map<String, dynamic>? errors;
    if (data is Map<String, dynamic>) {
      errors = data;
    }

    // Hata kodunu çıkar
    String? errorCode;
    if (data is Map && data.containsKey('error_code')) {
      errorCode = data['error_code'].toString();
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      errors: errors,
      type: e.type,
    );
  }

  /// Response data'dan hata mesajını çıkarır
  static String _extractErrorMessage(dynamic data, int? statusCode) {
    // Önce detail alanına bak (Django REST Framework standardı)
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        return data['detail'].toString();
      }

      if (data.containsKey('message')) {
        return data['message'].toString();
      }

      // Non-field errors
      if (data.containsKey('non_field_errors')) {
        final errors = data['non_field_errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }

      // Validation errors - ilk hatayı al
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            return '$firstKey: ${firstError.first}';
          }
          return '$firstKey: $firstError';
        }
      }

      // Field-level validation errors (Django DRF format)
      // Örnek: {"email": ["Bu alan zorunludur."]}
      for (var entry in data.entries) {
        if (entry.value is List && (entry.value as List).isNotEmpty) {
          final fieldName = _translateFieldName(entry.key);
          return '$fieldName: ${(entry.value as List).first}';
        }
      }
    }

    // String ise direkt döndür
    if (data is String && data.isNotEmpty) {
      return data;
    }

    // Status code'a göre default mesaj
    return _getDefaultMessageForStatusCode(statusCode);
  }

  /// Status code'a göre varsayılan mesaj döndürür
  static String _getDefaultMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek. Lütfen girdiğiniz bilgileri kontrol edin.';
      case 401:
        return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
      case 403:
        return 'Bu işlem için yetkiniz yok.';
      case 404:
        return 'İstenen kaynak bulunamadı.';
      case 409:
        return 'Bu işlem çakışma oluşturuyor. Lütfen kontrol edin.';
      case 422:
        return 'Girdiğiniz veriler geçersiz.';
      case 429:
        return 'Çok fazla istek gönderdiniz. Lütfen biraz bekleyin.';
      case 500:
        return 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
      case 502:
        return 'Sunucuya ulaşılamıyor. Lütfen daha sonra tekrar deneyin.';
      case 503:
        return 'Servis şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      case 504:
        return 'Sunucu zaman aşımına uğradı. Lütfen tekrar deneyin.';
      default:
        return 'Bilinmeyen bir hata oluştu. (Kod: ${statusCode ?? "?"})';
    }
  }

  /// Alan adlarını Türkçeye çevirir
  static String _translateFieldName(String fieldName) {
    const fieldTranslations = {
      'email': 'E-posta',
      'password': 'Şifre',
      'username': 'Kullanıcı Adı',
      'phone': 'Telefon',
      'name': 'Ad',
      'surname': 'Soyad',
      'title': 'Başlık',
      'description': 'Açıklama',
      'price': 'Fiyat',
      'amount': 'Tutar',
      'date': 'Tarih',
      'file': 'Dosya',
      'image': 'Görsel',
    };

    return fieldTranslations[fieldName] ?? fieldName;
  }

  /// Kullanıcıya gösterilecek detaylı hata mesajı
  String get userFriendlyMessage {
    if (errors != null && errors!.isNotEmpty) {
      return '$message\n\nDetaylar:\n${_formatErrors()}';
    }
    return message;
  }

  /// Validation hatalarını formatlar
  String _formatErrors() {
    if (errors == null) return '';

    final buffer = StringBuffer();
    int count = 0;

    errors!.forEach((key, value) {
      if (count >= 3) return; // Maksimum 3 hata göster

      final fieldName = _translateFieldName(key);
      if (value is List && value.isNotEmpty) {
        buffer.writeln('• $fieldName: ${value.first}');
      } else {
        buffer.writeln('• $fieldName: $value');
      }
      count++;
    });

    if (errors!.length > 3) {
      buffer.writeln('• ... ve ${errors!.length - 3} hata daha');
    }

    return buffer.toString();
  }

  /// Network hatası mı?
  bool get isNetworkError =>
      type == DioExceptionType.connectionError ||
          type == DioExceptionType.connectionTimeout ||
          statusCode == 0;

  /// Timeout hatası mı?
  bool get isTimeoutError =>
      type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.sendTimeout ||
          type == DioExceptionType.receiveTimeout;

  /// Yetkilendirme hatası mı?
  bool get isAuthenticationError => statusCode == 401;

  /// Yetki hatası mı?
  bool get isAuthorizationError => statusCode == 403;

  /// Validation hatası mı?
  bool get isValidationError => statusCode == 400 || statusCode == 422;

  /// Sunucu hatası mı?
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    return 'ApiException{message: $message, statusCode: $statusCode, errorCode: $errorCode}';
  }
}