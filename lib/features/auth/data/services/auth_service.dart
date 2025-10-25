// lib/features/auth/data/services/auth_service.dart
import 'dart:io';
// ✅ YENİ: Web platformunda byte verisiyle çalışmak için import edildi.
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // ==========================================
  // 🔥 DÜZELTME: Login
  // ==========================================
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('🔐 Login isteği gönderiliyor...');
      print('📍 Endpoint: ${ApiConstants.login}');
      print('👤 Username: $username');

      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      print('✅ Login başarılı');
      print('📦 Response: ${response.data}');

      return {
        'access': response.data['access'],
        'refresh': response.data['refresh'],
      };
    } on DioException catch (e) {
      print('❌ Login hatası:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('Kullanıcı adı veya şifre hatalı');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Login endpoint bulunamadı. Backend çalışıyor mu?');
      }
      throw Exception('Giriş yapılamadı: ${e.message}');
    } catch (e) {
      print('❌ Beklenmeyen hata: $e');
      throw Exception('Bir hata oluştu: $e');
    }
  }

  // Get Profile
  Future<UserModel> getProfile() async {
    try {
      print('👤 Profil bilgileri alınıyor...');
      print('📍 Endpoint: ${ApiConstants.profile}');

      final response = await _apiClient.get(ApiConstants.profile);

      print('✅ Profil bilgileri alındı');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Profil hatası: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Profil bilgileri alınamadı: ${e.message}');
    }
  }

  // Update Profile
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateProfile,
        data: data,
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('Profil güncellenemedi: ${e.message}');
    }
  }

  // ✅ GÜNCELLEME: Profil Fotoğrafı Yükleme Metodu
  // Artık platforma özel olarak dosya yolu (mobil) veya byte verisi (web) kabul ediyor.
  Future<UserModel> updateProfilePicture({
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
  }) async {
    try {
      late MultipartFile multipartFile;

      // Platforma göre MultipartFile objesini oluştur
      if (fileBytes != null) {
        // Web platformu için byte'lardan oluştur
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (filePath != null) {
        // Mobil platform için yoldan oluştur
        multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        throw Exception('Yüklenecek dosya verisi (path veya bytes) bulunamadı.');
      }

      FormData formData = FormData.fromMap({
        // Backend'de beklenen alan adı 'profile_picture' varsayılmıştır.
        "profile_picture": multipartFile,
      });

      // Backend'de bu işlem için özel bir endpoint (`/users/profile/upload_picture/` gibi)
      // veya mevcut `updateProfile` endpoint'inin `multipart/form-data` kabul etmesi gerekir.
      // Django projenizde `update_profile` view'ı PATCH/PUT ile çalıştığı için PATCH kullanıyoruz.
      final response = await _apiClient.patch(
        ApiConstants.updateProfile,
        data: formData,
      );

      // Backend yanıtına göre 'user' anahtarını kontrol edin.
      // Eğer doğrudan User modeli dönüyorsa `response.data` yeterli olacaktır.
      final responseData = response.data;
      if (responseData.containsKey('user')) {
        return UserModel.fromJson(responseData['user']);
      }
      return UserModel.fromJson(responseData);

    } on DioException catch (e) {
      throw Exception('Profil fotoğrafı yüklenemedi: ${e.response?.data.toString() ?? e.message}');
    }
  }


  // Change Password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        },
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        if (errorData.containsKey('old_password')) {
          throw Exception('Mevcut şifre hatalı');
        }
        throw Exception(errorData.values.first.toString());
      }
      throw Exception('Şifre değiştirilemedi: ${e.message}');
    }
  }

  // Get User Statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      print('📊 Kullanıcı istatistikleri alınıyor...');
      print('📍 Endpoint: ${ApiConstants.statistics}');

      final response = await _apiClient.get(ApiConstants.statistics);

      print('✅ İstatistikler alındı');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('❌ İstatistik hatası: ${e.response?.statusCode} - ${e.message}');
      throw Exception('İstatistikler alınamadı: ${e.message}');
    }
  }

  // Register FCM Device Token
  Future<void> registerFcmToken({
    required String registrationId,
    required String deviceId,
    required String name,
    String type = 'android',
  }) async {
    try {
      print('📲 FCM token kaydediliyor...');
      print('📍 Endpoint: ${ApiConstants.fcmToken}');

      await _apiClient.post(
        ApiConstants.fcmToken,
        data: {
          'registration_id': registrationId,
          'device_id': deviceId,
          'name': name,
          'type': type,
        },
      );
      print('✅ FCM token kaydedildi');
    } on DioException catch (e) {
      // Hata olsa da devam et (FCM opsiyonel)
      print('⚠️ FCM token kaydedilemedi: ${e.message}');
    }
  }

  // ✅ YENİ EKLENDİ: Deactivate FCM Token
  Future<void> deactivateFcmToken(String registrationId) async {
    try {
      print('📴 FCM token deaktive ediliyor...');
      await _apiClient.post(
        ApiConstants.deactivateFcmDevice,
        data: {'registration_id': registrationId},
      );
      print('✅ FCM token deaktive edildi.');
    } on DioException catch (e) {
      // Bu işlemdeki hata, logout akışını engellememeli.
      print('⚠️ FCM token deaktive edilemedi: ${e.message}');
    }
  }

  // Logout (Local)
  Future<void> logout() async {
    // Backend'de logout endpoint'i yok, sadece local temizlik yapıyoruz
    print('👋 Logout - Local temizlik');
    return;
  }
}