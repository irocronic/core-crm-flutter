// lib/core/network/errors/failures.dart

import 'package:equatable/equatable.dart';

/// Base Failure sınıfı
abstract class Failure extends Equatable {
  final String? message;

  const Failure([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Sunucu hatası
class ServerFailure extends Failure {
  const ServerFailure([String? message]) : super(message ?? 'Sunucu hatası oluştu');
}

/// Ağ bağlantı hatası
class NetworkFailure extends Failure {
  const NetworkFailure([String? message]) : super(message ?? 'İnternet bağlantınızı kontrol edin');
}

/// Önbellek hatası
class CacheFailure extends Failure {
  const CacheFailure([String? message]) : super(message ?? 'Yerel veri yüklenemedi');
}

/// Yetkilendirme hatası
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String? message]) : super(message ?? 'Oturum süreniz doldu');
}

/// Validation hatası
class ValidationFailure extends Failure {
  const ValidationFailure([String? message]) : super(message ?? 'Geçersiz veri');
}

/// Bilinmeyen hata
class UnknownFailure extends Failure {
  const UnknownFailure([String? message]) : super(message ?? 'Beklenmeyen bir hata oluştu');
}