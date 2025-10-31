// lib/features/settings/data/services/settings_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/seller_company_model.dart';

class SettingsService {
  final ApiClient _apiClient;

  SettingsService(this._apiClient);

  /// Tüm satıcı firmaları getir
  Future<List<SellerCompanyModel>> getSellerCompanies() async {
    try {
      debugPrint('⚙️ [SettingsService] Satıcı firmalar alınıyor...');
      // Ayar verileri genellikle azdır, tamamını çekmek için yüksek limit
      final response = await _apiClient.get(
        ApiConstants.sellerCompanies,
        queryParameters: {'page_size': 100},
      );

      // Backend'in paginated yanıt verip vermediğini kontrol et
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        final List<dynamic> data = response.data['results'] as List<dynamic>? ?? [];
        debugPrint('✅ [SettingsService] ${data.length} firma alındı (Paginated)');
        return data
            .map((json) => SellerCompanyModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      // Paginated değilse (List<dynamic> olarak gelirse)
      else if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        debugPrint('✅ [SettingsService] ${data.length} firma alındı (List)');
        return data
            .map((json) => SellerCompanyModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      debugPrint('⚠️ [SettingsService] Beklenmeyen yanıt formatı');
      throw ApiException(message: "Beklenmeyen yanıt formatı");

    } on DioException catch (e) {
      debugPrint('❌ [SettingsService] getSellerCompanies hatası: $e');
      throw ApiException.fromDioException(e);
    }
  }

  /// Tek bir satıcı firmayı getir
  Future<SellerCompanyModel> getSellerCompany(int id) async {
    try {
      debugPrint('⚙️ [SettingsService] Firma detayı alınıyor: $id');
      final response = await _apiClient.get('${ApiConstants.sellerCompanies}$id/');
      return SellerCompanyModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [SettingsService] getSellerCompany hatası: $e');
      throw ApiException.fromDioException(e);
    }
  }

  /// Yeni satıcı firma oluştur
  Future<SellerCompanyModel> createSellerCompany(Map<String, dynamic> data) async {
    try {
      debugPrint('⚙️ [SettingsService] Yeni firma oluşturuluyor...');
      final response = await _apiClient.post(
        ApiConstants.sellerCompanies,
        data: data,
      );
      return SellerCompanyModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [SettingsService] createSellerCompany hatası: $e');
      throw ApiException.fromDioException(e);
    }
  }

  /// Satıcı firmayı güncelle
  Future<SellerCompanyModel> updateSellerCompany(int id, Map<String, dynamic> data) async {
    try {
      debugPrint('⚙️ [SettingsService] Firma güncelleniyor: $id');
      // Backend hem PUT hem PATCH destekliyor, PATCH kısmi güncelleme için daha iyidir.
      final response = await _apiClient.patch(
        '${ApiConstants.sellerCompanies}$id/',
        data: data,
      );
      return SellerCompanyModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ [SettingsService] updateSellerCompany hatası: $e');
      throw ApiException.fromDioException(e);
    }
  }

  /// Satıcı firmayı sil
  Future<void> deleteSellerCompany(int id) async {
    try {
      debugPrint('⚙️ [SettingsService] Firma siliniyor: $id');
      await _apiClient.delete('${ApiConstants.sellerCompanies}$id/');
    } on DioException catch (e) {
      debugPrint('❌ [SettingsService] deleteSellerCompany hatası: $e');
      throw ApiException.fromDioException(e);
    }
  }
}