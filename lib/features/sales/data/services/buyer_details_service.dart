// lib/features/sales/data/services/buyer_details_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/buyer_details_model.dart';

class BuyerDetailsService {
  final ApiClient _apiClient;

  BuyerDetailsService(this._apiClient);

  Future<BuyerDetailsModel?> getBuyerDetails(int customerId) async {
    try {
      debugPrint('⚙️ [BuyerDetailsService] Alıcı detayı alınıyor: $customerId');
      final response = await _apiClient.get(
        ApiConstants.buyerDetailsByCustomer(customerId),
      );
      return BuyerDetailsModel.fromJson(response.data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        debugPrint('ℹ️ [BuyerDetailsService] Alıcı detayı bulunamadı (404).');
        return null; // 404 ise null dön, bu bir hata değil, kayıt yok demek.
      }
      debugPrint('❌ [BuyerDetailsService] getBuyerDetails hatası: $e');
      rethrow;
    }
  }

  Future<BuyerDetailsModel> createBuyerDetails(Map<String, dynamic> data) async {
    try {
      debugPrint('⚙️ [BuyerDetailsService] Alıcı detayı oluşturuluyor...');
      final response = await _apiClient.post(
        ApiConstants.buyerDetails,
        data: data,
      );
      return BuyerDetailsModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [BuyerDetailsService] createBuyerDetails hatası: $e');
      throw ApiException.fromDioException(e);
    }
  }

  Future<BuyerDetailsModel> updateBuyerDetails(
      int id, Map<String, dynamic> data) async {
    try {
      debugPrint('⚙️ [BuyerDetailsService] Alıcı detayı güncelleniyor: $id');
      final response = await _apiClient.put(
        '${ApiConstants.buyerDetails}$id/',
        data: data,
      );
      return BuyerDetailsModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [BuyerDetailsService] updateBuyerDetails hatası: $e');
      throw ApiException.fromDioException(e);
    }
  }
}