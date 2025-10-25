// lib/features/reports/data/datasources/sales_report_remote_datasource.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../models/sales_report_model.dart';

abstract class SalesReportRemoteDataSource {
  Future<List<SalesReportModel>> getSalesReports(ReportFilterEntity filter);
  Future<SalesReportModel> getSalesReportById(String id);
  Future<SalesReportModel> generateReport(Map<String, dynamic> data);
}

class SalesReportRemoteDataSourceImpl implements SalesReportRemoteDataSource {
  final ApiClient apiClient;
  SalesReportRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<List<SalesReportModel>> getSalesReports(
      ReportFilterEntity filter,
      ) async {
    try {
      final queryParams = filter.toQueryParams();
      final response = await apiClient.get(
        ApiConstants.reports,
        queryParameters: queryParams.map(
              (key, value) => MapEntry(key, value.toString()),
        ),
      );
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((item) => SalesReportModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw ServerException(
        'Raporlar alınamadı: ${_extractErrorMessage(e)}',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Sunucuya bağlanılamadı: ${e.toString()}');
    }
  }

  @override
  Future<SalesReportModel> getSalesReportById(String id) async {
    try {
      final response = await apiClient.get('${ApiConstants.reports}$id/');
      return SalesReportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        'Rapor detayı alınamadı: ${_extractErrorMessage(e)}',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Sunucuya bağlanılamadı: ${e.toString()}');
    }
  }

  @override
  Future<SalesReportModel> generateReport(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiConstants.generateReport,
        data: data,
      );
      debugPrint('✅ [DEBUG] Rapor oluşturma yanıtı alındı (201 Created). Ham Veri:');
      debugPrint(response.data.toString());
      if (response.data != null && response.data is Map<String, dynamic>) {
        if (response.data.containsKey('report')) {
          final reportData = response.data['report'];
          debugPrint('📦 [DEBUG] Ayrıştırılacak Rapor Verisi ("report" anahtarı bulundu):');
          debugPrint(reportData.toString());

          try {
            return SalesReportModel.fromJson(reportData);
          } catch (e, stackTrace) {
            debugPrint('❌ [DEBUG] SalesReportModel.fromJson İÇİNDE HATA!');
            debugPrint('Hata Mesajı: $e');
            debugPrint('Stack Trace: $stackTrace');
            throw ServerException('Flutter model ayrıştırma hatası: $e');
          }
        } else {
          debugPrint('❌ [DEBUG] Yanıtta "report" anahtarı bulunamadı!');
          throw ServerException('API yanıtı beklenen "report" anahtarını içermiyor.');
        }
      } else {
        debugPrint('❌ [DEBUG] API yanıtı geçerli bir JSON nesnesi değil!');
        throw ServerException('API yanıtı boş veya geçersiz formatta.');
      }
    } on DioException catch (e) {
      debugPrint('❌ [DEBUG] DioException: ${e.message}');
      throw ServerException(
        'Rapor oluşturulamadı: ${_extractErrorMessage(e)}',
        e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('❌ [DEBUG] Genel Hata: $e');
      throw ServerException('Sunucuya bağlanılamadı: ${e.toString()}');
    }
  }

  // 🔥 Hata mesajını güvenli şekilde çıkaran helper fonksiyon
  String _extractErrorMessage(DioException e) {
    try {
      // Response data null ise
      if (e.response?.data == null) {
        return e.message ?? 'Bilinmeyen hata';
      }

      final data = e.response!.data;

      // String ise (HTML error sayfası olabilir)
      if (data is String) {
        // JSON parse dene
        try {
          final jsonData = json.decode(data);
          if (jsonData is Map<String, dynamic>) {
            return jsonData['detail'] ?? jsonData['error'] ?? data;
          }
        } catch (_) {
          // JSON değilse raw string döndür
          return data.length > 100 ? '${data.substring(0, 100)}...' : data;
        }
      }

      // Map ise
      if (data is Map<String, dynamic>) {
        return data['detail'] ?? data['error'] ?? data['message'] ?? 'Bilinmeyen hata';
      }

      // List ise
      if (data is List) {
        return data.isNotEmpty ? data.first.toString() : 'Bilinmeyen hata';
      }

      return data.toString();
    } catch (_) {
      return e.message ?? 'Hata mesajı alınamadı';
    }
  }
}