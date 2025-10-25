// lib/features/reservations/data/services/reservation_service.dart
import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/pagination_model.dart';
import '../models/reservation_model.dart';

class ReservationService {
  final ApiClient _apiClient;

  ReservationService(this._apiClient);

  // **** GÜNCELLEME: customerId parametresi eklendi ****
  Future<PaginationModel<ReservationModel>> getReservations({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    int? customerId, // Yeni parametre
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      // **** YENİ: Müşteri ID'sini query parametrelerine ekle ****
      // Backend'deki filtre adının 'customer_id' olduğunu varsayıyoruz
      if (customerId != null) {
        queryParams['customer_id'] = customerId;
      }
      // **** YENİ SONU ****

      final response = await _apiClient.get(
        ApiConstants.reservations,
        queryParameters: queryParams,
      );
      return PaginationModel<ReservationModel>.fromJson(
        response.data,
            (json) => ReservationModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception('Rezervasyonlar yüklenemedi: ${e.message}');
    }
  }
  // **** GÜNCELLEME SONU ****

  Future<PaginationModel<ReservationModel>> getMyReservations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };
      final response = await _apiClient.get(
        ApiConstants.myReservations,
        queryParameters: queryParams,
      );
      return PaginationModel<ReservationModel>.fromJson(
        response.data,
            (json) => ReservationModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception('Rezervasyonlarım yüklenemedi: ${e.message}');
    }
  }

  Future<PaginationModel<ReservationModel>> getActiveReservations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };
      final response = await _apiClient.get(
        ApiConstants.activeReservations, // Yeni endpoint'i kullan
        queryParameters: queryParams,
      );
      return PaginationModel<ReservationModel>.fromJson(
        response.data,
            (json) => ReservationModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception('Aktif rezervasyonlar yüklenemedi: ${e.message}');
    }
  }


  Future<ReservationModel> getReservationDetail(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.reservations}$id/');
      return ReservationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Rezervasyon detayı yüklenemedi: ${e.message}');
    }
  }

  Future<ReservationModel> createReservation(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.reservations,
        data: data,
      );
      return ReservationModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        final errorMessages = errors.values.join(', ');
        throw Exception(errorMessages);
      }
      throw Exception('Rezervasyon oluşturulamadı: ${e.message}');
    }
  }

  Future<ReservationModel> convertToSale(int id) async {
    try {
      print('🔄 Rezervasyon satışa dönüştürülüyor: $id');
      final response = await _apiClient.post('${ApiConstants.reservations}$id/convert_to_sale/');
      print('✅ Rezervasyon satışa dönüştürüldü');
      if (response.data.containsKey('reservation')) {
        return ReservationModel.fromJson(response.data['reservation']);
      }
      return ReservationModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Satışa dönüştürme hatası: ${e.response?.data}');
      throw Exception('Satışa dönüştürülemedi: ${e.response?.data['error'] ?? e.message}');
    }
  }

  Future<void> cancelReservation(int id, String reason) async {
    try {
      await _apiClient.post(
        '${ApiConstants.reservations}$id/cancel/',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw Exception('Rezervasyon iptal edilemedi: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getReservationStatistics() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.reservations}statistics/', // Backend'deki statistics endpoint'i
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Rezervasyon istatistikleri alınamadı: ${e.message}');
    }
  }
}