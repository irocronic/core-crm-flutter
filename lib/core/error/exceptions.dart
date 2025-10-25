// lib/core/error/exceptions.dart

/// Sunucu exception'ı
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerException ($statusCode): $message';
    }
    return 'ServerException: $message';
  }
}

/// Önbellek exception'ı
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Ağ exception'ı
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication exception'ı
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Validation exception'ı
class ValidationException implements Exception {
  final String message;
  // ✅ GÜNCELLEME: `errors` alanı artık boş olamaz ve varsayılan değeri boş bir Map.
  final Map<String, dynamic> errors;

  // ✅ GÜNCELLEME: Constructor, gelen `errors` null ise onu boş bir Map'e çevirir.
  ValidationException(this.message, [Map<String, dynamic>? errors])
      : errors = errors ?? {};

  @override
  String toString() {
    if (errors.isNotEmpty) {
      return 'ValidationException: $message\nErrors: $errors';
    }
    return 'ValidationException: $message';
  }
}