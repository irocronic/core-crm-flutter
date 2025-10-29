// lib/features/reports/presentation/providers/sales_report_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../../core/error/failures.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/repositories/sales_report_repository.dart';
import '../../domain/usecases/get_sales_report_by_id.dart';
import '../../domain/usecases/get_sales_reports.dart';
import '../../services/pdf_export_service.dart';
import '../../services/excel_export_service.dart';
import '../../services/csv_export_service.dart';

/// ✅ YENİ: Export Result Model - Web ve Mobile uyumlu
class ExportResult {
  final dynamic data; // File (mobile/desktop) veya Uint8List (web)
  final String fileName;
  final bool isWeb;
  final String format;

  ExportResult({
    required this.data,
    required this.fileName,
    required this.isWeb,
    required this.format,
  });

  /// Dosya türü kontrol metodu
  bool get isFile => data is File;
  bool get isBytes => data is Uint8List || data is List<int>;

  /// Safe casting metodları
  File? asFile() => isFile ? data as File : null;
  Uint8List? asBytes() {
    if (data is Uint8List) {
      return data as Uint8List;
    } else if (data is List<int>) {
      return Uint8List.fromList(data as List<int>);
    }
    return null;
  }
}

class SalesReportProvider with ChangeNotifier {
  final SalesReportRepository repository;
  final GetSalesReports getSalesReportsUseCase;
  final GetSalesReportById getSalesReportByIdUseCase;

  SalesReportProvider({
    required this.repository,
    required this.getSalesReportsUseCase,
    required this.getSalesReportByIdUseCase,
  });

  static const int _maxReportsInMemory = 100;

  // State Management
  List<SalesReportEntity> _reports = [];
  SalesReportEntity? _selectedReport;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _errorMessage;
  ReportFilterEntity _currentFilter = const ReportFilterEntity(period: ReportPeriod.monthly);

  // Getters
  List<SalesReportEntity> get reports => _reports;
  SalesReportEntity? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get errorMessage => _errorMessage;
  ReportFilterEntity get currentFilter => _currentFilter;

  /// Raporları yükle
  Future<void> loadReports({ReportFilterEntity? filter}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (filter != null) {
        _currentFilter = filter;
      }

      final result = await getSalesReportsUseCase(_currentFilter);

      result.fold(
            (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          _reports = [];
        },
            (reports) {
          _reports = reports;
          _errorMessage = null;
          _trimReportsIfNeeded();
        },
      );
    } catch (e) {
      _errorMessage = 'Bilinmeyen hata: ${e.toString()}';
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rapor detayını ID'ye göre yükle
  Future<void> loadReportById(String reportId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await getSalesReportByIdUseCase(reportId);

      result.fold(
            (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          _selectedReport = null;
        },
            (report) {
          _selectedReport = report;
          _errorMessage = null;
        },
      );
    } catch (e) {
      _errorMessage = 'Rapor detayı alınamadı: ${e.toString()}';
      _selectedReport = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtreyi güncelle
  void updateFilter(ReportFilterEntity filter) {
    _currentFilter = filter;
    loadReports();
  }

  /// Raporları yenile
  Future<void> refreshReports() async {
    await loadReports();
  }

  /// Yeni rapor oluştur
  Future<SalesReportEntity?> generateReport({
    required ReportFilterEntity filter,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.generateReport(filter);

      final report = result.fold<SalesReportEntity?>(
            (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          return null;
        },
            (report) {
          final existingIndex = _reports.indexWhere((r) => r.id == report.id);

          if (existingIndex != -1) {
            _reports[existingIndex] = report;
            debugPrint('📝 [PROVIDER] Mevcut rapor güncellendi: ID ${report.id}');
          } else {
            _reports.insert(0, report);
            debugPrint('➕ [PROVIDER] Yeni rapor eklendi: ID ${report.id}');
            _trimReportsIfNeeded();
          }

          _errorMessage = null;
          return report;
        },
      );

      return report;
    } catch (e) {
      _errorMessage = 'Rapor oluşturulamadı: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ FIXED: Flutter'dan direkt export - Type-safe return
  Future<ExportResult?> exportReportLocal({
    required SalesReportEntity report,
    required String format,
  }) async {
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📤 [LOCAL EXPORT] Başlıyor: Format=$format, Report ID=${report.id}');

      dynamic result;

      switch (format.toLowerCase()) {
        case 'pdf':
          result = await PdfExportService.generatePdf(report);
          break;
        case 'excel':
          result = await ExcelExportService.generateExcel(report);
          break;
        case 'csv':
          result = await CsvExportService.generateCsv(report);
          break;
        default:
          _errorMessage = 'Geçersiz format: $format';
          return null;
      }

      if (result != null) {
        debugPrint('✅ [LOCAL EXPORT] Başarılı');

        // Dosya adını belirle
        String fileName;
        if (result is File) {
          fileName = result.path.split('/').last;
          debugPrint('📁 [LOCAL EXPORT] Dosya adı (mobile): $fileName');
        } else if (result is Uint8List || result is List<int>) {
          fileName = 'rapor_${report.id}_${DateTime.now().millisecondsSinceEpoch}.$format';
          debugPrint('📁 [LOCAL EXPORT] Dosya adı (web): $fileName');
        } else {
          fileName = 'rapor.$format';
          debugPrint('⚠️ [LOCAL EXPORT] Bilinmeyen type: ${result.runtimeType}');
        }

        return ExportResult(
          data: result,
          fileName: fileName,
          isWeb: kIsWeb,
          format: format,
        );
      } else {
        _errorMessage = 'Dosya oluşturulamadı';
        debugPrint('❌ [LOCAL EXPORT] Dosya oluşturulamadı');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOCAL EXPORT] Hata: $e');
      debugPrint('📄 [LOCAL EXPORT] Stack Trace: $stackTrace');
      _errorMessage = 'Export hatası: $e';
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Bellek optimizasyonu - çok fazla rapor tutmayı engelle
  void _trimReportsIfNeeded() {
    if (_reports.length > _maxReportsInMemory) {
      final removedCount = _reports.length - _maxReportsInMemory;
      _reports = _reports.sublist(0, _maxReportsInMemory);
      debugPrint('🗑️ [PROVIDER] Bellek optimizasyonu: $removedCount rapor kaldırıldı');
    }
  }

  /// Raporu sil
  void removeReport(int reportId) {
    final initialLength = _reports.length;
    _reports.removeWhere((report) => report.id == reportId);

    if (_reports.length < initialLength) {
      debugPrint('🗑️ [PROVIDER] Rapor silindi: ID $reportId');
      notifyListeners();
    }
  }

  /// Tüm raporları temizle
  void clearAllReports() {
    _reports.clear();
    _selectedReport = null;
    _errorMessage = null;
    _currentFilter = const ReportFilterEntity(period: ReportPeriod.monthly);
    debugPrint('🧹 [PROVIDER] Tüm raporlar temizlendi');
    notifyListeners();
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Hata mesajını kullanıcı dostu formata çevir
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? 'Sunucu hatası oluştu';
    } else if (failure is NetworkFailure) {
      return 'İnternet bağlantısı kontrol edin';
    } else {
      return 'Bilinmeyen hata oluştu';
    }
  }

  /// Provider dispose
  @override
  void dispose() {
    debugPrint('🧹 [PROVIDER] SalesReportProvider dispose ediliyor...');
    _reports.clear();
    _selectedReport = null;
    super.dispose();
  }
}