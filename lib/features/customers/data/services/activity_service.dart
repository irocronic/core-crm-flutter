// lib/features/customers/data/services/activity_service.dart
import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/activity_model.dart';
// **** YENİ IMPORT ****
import '../../../../shared/models/pagination_model.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için // ✅ DÜZELTİLDİ

class ActivityService {
  final ApiClient _apiClient;

  ActivityService(this._apiClient);

  // **** YENİ METOT: Tüm Aktiviteleri Getir (Dashboard için) ****
  Future<PaginationModel<ActivityModel>> getAllActivities({
    int page = 1,
    int pageSize = 20, // Dashboard için daha az olabilir
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('⏳ Tüm aktiviteler alınıyor (Dashboard)... Sayfa: $page');
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      // Tarih filtrelerini ekle (yyyy-MM-dd formatında)
      if (startDate != null) {
        queryParameters['start_date'] = DateFormat('yyyy-MM-dd').format(startDate); //
      }
      if (endDate != null) {
        queryParameters['end_date'] = DateFormat('yyyy-MM-dd').format(endDate); //
      }

      print('🔍 Filtreler: $queryParameters');

      final response = await _apiClient.get(
        ApiConstants.activities, // Ana aktivite endpoint'i //
        queryParameters: queryParameters,
      );

      print('✅ Tüm aktiviteler alındı (Dashboard)');

      // API yanıtının paginated olduğunu varsayıyoruz
      return PaginationModel<ActivityModel>.fromJson(
        response.data,
            (json) => ActivityModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      print('❌ Tüm aktiviteler hatası (Dashboard): ${e.response?.statusCode}');
      throw Exception('Tüm aktiviteler alınamadı: ${e.message}');
    }
  }
  // **** YENİ METOT SONU ****


  Future<List<ActivityModel>> getUpcomingFollowUps() async {
    try {
      print('⏳ Yaklaşan takipler alınıyor...');
      final response = await _apiClient.get(ApiConstants.upcomingFollowUps);
      final List<dynamic> data = response.data as List<dynamic>;
      print('✅ ${data.length} adet yaklaşan takip alındı');
      return data
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>)) // [cite: 776]
          .toList();
    } on DioException catch (e) {
      print('❌ Yaklaşan takipler hatası: ${e.response?.statusCode}');
      throw Exception('Yaklaşan takipler alınamadı: ${e.message}');
    }
  }

  Future<List<ActivityModel>> getActivitiesByCustomer(
      int customerId, {
        String? activityType,
        int page = 1,
        int pageSize = 1000,
      }) async {
    try {
      print('📋 Müşteri aktiviteleri alınıyor: $customerId (Type: $activityType)');

      final queryParameters = <String, dynamic>{
        'customer': customerId,
        'page': page,
        'page_size': pageSize, // [cite: 777]
      };

      if (activityType != null && activityType.isNotEmpty) {
        queryParameters['activity_type'] = activityType;
        print('🔍 Aktivite tipine göre filtre uygulanıyor: $activityType');
      }

      final response = await _apiClient.get(
        ApiConstants.activities,
        queryParameters: queryParameters,
      );

      final List<dynamic> data;
      if (response.data is Map && response.data.containsKey('results')) {
        data = response.data['results'] as List<dynamic>? ?? [];
      } else if (response.data is List) {
        data = response.data as List<dynamic>;
      } else {
        data = [];
      }

      print('✅ ${data.length} aktivite alındı (Filtre: $activityType)');

      return data
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
          .toList(); // [cite: 778]
    } on DioException catch (e) {
      print('❌ Aktivite listesi hatası: ${e.response?.statusCode}');
      throw Exception('Aktiviteler alınamadı: ${e.message}');
    }
  }

  Future<ActivityModel> createActivity(Map<String, dynamic> data) async {
    try {
      print('➕ Aktivite oluşturuluyor...');
      print('📦 Data: $data');

      final response = await _apiClient.post(
        ApiConstants.activities,
        data: data,
      );

      print('✅ Aktivite oluşturuldu (Backend sub_type hesapladı)');
      return ActivityModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ Aktivite oluşturma hatası: ${e.response?.statusCode}');
      print('📦 Error: ${e.response?.data}');

      if (e.response?.data != null && e.response!.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        final errorMessages = errors.entries
            .map((entry) { // [cite: 779]
          final key = entry.key;
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            return '$key: ${value.first}';
          }
          return '$key: $value';
        })
            .join(' | ');
        throw Exception('Aktivite oluşturulamadı: $errorMessages');
      }

      throw Exception('Aktivite oluşturulamadı: ${e.message}');
    }
  }

  Future<ActivityModel> updateActivity(
      int id,
      Map<String, dynamic> data,
      ) async {
    try { // [cite: 780]
      print('✏️ Aktivite güncelleniyor: $id');
      print('📦 Data: $data');
      final response = await _apiClient.put(
        '${ApiConstants.activities}$id/',
        data: data,
      );

      print('✅ Aktivite güncellendi');
      return ActivityModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ Aktivite güncelleme hatası: ${e.response?.statusCode}');
      throw Exception('Aktivite güncellenemedi: ${e.message}');
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      print('🗑️ Aktivite siliniyor: $id');

      await _apiClient.delete('${ApiConstants.activities}$id/');

      print('✅ Aktivite silindi');
    } on DioException catch (e) {
      print('❌ Aktivite silme hatası: ${e.response?.statusCode}');
      throw Exception('Aktivite silinemedi: ${e.message}');
    }
  }

  Future<ActivityModel> getActivity(int id) async {
    try {
      print('📋 Aktivite detayı alınıyor: $id');

      final response = await _apiClient.get('${ApiConstants.activities}$id/');

      print('✅ Aktivite detayı alındı');
      return ActivityModel.fromJson(response.data as Map<String, dynamic>); // [cite: 781]
    } on DioException catch (e) {
      print('❌ Aktivite detay hatası: ${e.response?.statusCode}');
      throw Exception('Aktivite detayı alınamadı: ${e.message}');
    }
  }
}