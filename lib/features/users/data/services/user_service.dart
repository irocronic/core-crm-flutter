// lib/features/users/data/services/user_service.dart
import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/team_model.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  // Yönetici ve Satış Müdürü için tüm kullanıcıları listeler
  Future<List<UserModel>> getUsers() async {
    try {
      print('👥 Tüm kullanıcılar alınıyor...');
      final response = await _apiClient.get(ApiConstants.users);

      final List<dynamic> data = response.data['results'] as List<dynamic>;

      print('✅ ${data.length} kullanıcı alındı');
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Kullanıcı listesi hatası: ${e.response?.statusCode}');
      throw Exception('Kullanıcılar alınamadı: ${e.message}');
    }
  }

  // ✅ YENİ: ID ile tek bir kullanıcıyı getirir
  Future<UserModel> getUserById(int userId) async {
    try {
      print('👤 Kullanıcı detayı alınıyor: $userId');
      final response = await _apiClient.get('${ApiConstants.users}$userId/');
      print('✅ Kullanıcı detayı alındı');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Kullanıcı detay hatası: ${e.response?.statusCode}');
      throw Exception('Kullanıcı detayı alınamadı: ${e.message}');
    }
  }

  // Satış Müdürü için kendi ekibini listeler
  Future<TeamModel> getMyTeam() async {
    try {
      print('🤝 Ekibim bilgisi alınıyor...');
      final response = await _apiClient.get(ApiConstants.myTeam);
      print('✅ Ekip bilgisi alındı');
      return TeamModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Ekip bilgisi hatası: ${e.response?.statusCode}');
      throw Exception('Ekip bilgisi alınamadı: ${e.message}');
    }
  }

  // Müşteri ataması için uygun satış temsilcilerini listeler
  Future<List<UserModel>> getSalesReps() async {
    try {
      print('👨‍💼 Satış temsilcileri alınıyor...');
      final response = await _apiClient.get(ApiConstants.salesReps);
      final List<dynamic> data = response.data;
      print('✅ ${data.length} satış temsilcisi alındı');
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Satış temsilcileri hatası: ${e.response?.statusCode}');
      throw Exception('Satış temsilcileri alınamadı: ${e.message}');
    }
  }

  // Yeni kullanıcı oluşturur (Admin yetkisi)
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    try {
      print('➕ Yeni kullanıcı oluşturuluyor...');
      final response = await _apiClient.post(ApiConstants.users, data: data);
      print('✅ Kullanıcı oluşturuldu');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Kullanıcı oluşturma hatası: ${e.response?.data}');
      throw Exception('Kullanıcı oluşturulamadı: ${e.response?.data.toString()}');
    }
  }

  // Mevcut kullanıcıyı günceller (Admin/Yönetici yetkisi)
  Future<UserModel> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      print('✏️ Kullanıcı güncelleniyor: $userId');
      final response = await _apiClient.patch('${ApiConstants.users}$userId/', data: data); // ✅ PUT yerine PATCH
      print('✅ Kullanıcı güncellendi');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Kullanıcı güncelleme hatası: ${e.response?.data}');
      throw Exception('Kullanıcı güncellenemedi: ${e.response?.data.toString()}');
    }
  }

  // ✅ YENİ EKLENDİ: Kullanıcıyı siler (Admin yetkisi)
  Future<void> deleteUser(int userId) async {
    try {
      print('🗑️ Kullanıcı siliniyor: $userId');
      await _apiClient.delete('${ApiConstants.users}$userId/');
      print('✅ Kullanıcı silindi');
    } on DioException catch (e) {
      print('❌ Kullanıcı silme hatası: ${e.response?.statusCode}');
      throw Exception('Kullanıcı silinemedi: ${e.message}');
    }
  }
}