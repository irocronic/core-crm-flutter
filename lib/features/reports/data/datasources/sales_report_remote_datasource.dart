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

  /// ✅ YENİ: Export report metodu
  Future<Map<String, dynamic>> exportReport(String reportId, String format);
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

  /// ✅ YENİ: Export Report Implementation
  @override
  Future<Map<String, dynamic>> exportReport(String reportId, String format) async {
    try {
      debugPrint('📤 [EXPORT] Rapor dışa aktarılıyor: ID=$reportId, Format=$format');

      // Format validasyonu
      final validFormats = ['pdf', 'excel', 'csv'];
      if (!validFormats.contains(format.toLowerCase())) {
        throw ServerException('Geçersiz format: $format. Geçerli formatlar: ${validFormats.join(", ")}');
      }

      final response = await apiClient.get(
        '${ApiConstants.reports}$reportId/export/',
        queryParameters: {
          'format': format.toLowerCase(),
        },
      );

      debugPrint('✅ [EXPORT] Başarılı yanıt alındı');
      debugPrint('📦 [EXPORT DATA] ${response.data}');

      if (response.data == null) {
        throw ServerException('Export yanıtı boş');
      }

      // Yanıt formatına göre işle
      if (response.data is Map<String, dynamic>) {
        final exportData = response.data as Map<String, dynamic>;

        // Beklenen alanları kontrol et
        if (exportData.containsKey('file_url')) {
          debugPrint('📁 [EXPORT] Dosya URL\'i alındı: ${exportData['file_url']}');
          return {
            'success': true,
            'file_url': exportData['file_url'],
            'file_name': exportData['file_name'] ?? 'report_$reportId.$format',
            'format': format,
            'report_id': reportId,
          };
        } else if (exportData.containsKey('file_data')) {
          debugPrint('📁 [EXPORT] Base64 veri alındı');
          return {
            'success': true,
            'file_data': exportData['file_data'],
            'file_name': exportData['file_name'] ?? 'report_$reportId.$format',
            'format': format,
            'report_id': reportId,
            'mime_type': exportData['mime_type'] ?? _getMimeType(format),
          };
        } else {
          throw ServerException('Export yanıtı beklenen alanları içermiyor (file_url veya file_data)');
        }
      } else if (response.data is String) {
        // String yanıt (base64 encoded data olabilir)
        debugPrint('📁 [EXPORT] String veri alındı');
        return {
          'success': true,
          'file_data': response.data,
          'file_name': 'report_$reportId.$format',
          'format': format,
          'report_id': reportId,
          'mime_type': _getMimeType(format),
        };
      } else {
        throw ServerException('Export yanıtı beklenmeyen formatta: ${response.data.runtimeType}');
      }

    } on DioException catch (e) {
      debugPrint('❌ [EXPORT ERROR] DioException: ${e.message}');
      debugPrint('📦 [EXPORT ERROR DATA] ${e.response?.data}');

      // 404 - Rapor bulunamadı
      if (e.response?.statusCode == 404) {
        throw ServerException('Rapor bulunamadı: ID $reportId', 404);
      }

      // 400 - Geçersiz format
      if (e.response?.statusCode == 400) {
        throw ServerException(
          'Geçersiz export isteği: ${_extractErrorMessage(e)}',
          400,
        );
      }

      throw ServerException(
        'Rapor dışa aktarılamadı: ${_extractErrorMessage(e)}',
        e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('❌ [EXPORT ERROR] Genel Hata: $e');
      throw ServerException('Rapor dışa aktarılamadı: ${e.toString()}');
    }
  }

  /// ✅ YENİ: Format için MIME type döndür
  String _getMimeType(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'excel':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }

  /// Hata mesajını güvenli şekilde çıkaran helper fonksiyon
  String _extractErrorMessage(DioException e) {
    try {
      if (e.response?.data == null) {
        return e.message ?? 'Bilinmeyen hata';
      }

      final data = e.response!.data;

      if (data is String) {
        try {
          final jsonData = json.decode(data);
          if (jsonData is Map<String, dynamic>) {
            return jsonData['detail'] ?? jsonData['error'] ?? data;
          }
        } catch (_) {
          return data.length > 100 ? '${data.substring(0, 100)}...' : data;
        }
      }

      if (data is Map<String, dynamic>) {
        return data['detail'] ?? data['error'] ?? data['message'] ?? 'Bilinmeyen hata';
      }

      if (data is List) {
        return data.isNotEmpty ? data.first.toString() : 'Bilinmeyen hata';
      }

      return data.toString();
    } catch (_) {
      return e.message ?? 'Hata mesajı alınamadı';
    }
  }
}