// lib/features/reports/presentation/providers/sales_report_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'dart:typed_data';

import '../../../../core/error/failures.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/repositories/sales_report_repository.dart';
import '../../domain/usecases/get_sales_report_by_id.dart';
import '../../domain/usecases/get_sales_reports.dart';
import '../../services/pdf_export_service.dart';
import '../../services/excel_export_service.dart';
import '../../services/csv_export_service.dart';

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
  ReportFilterEntity _currentFilter =
  const ReportFilterEntity(period: ReportPeriod.monthly);

  // Getters
  List<SalesReportEntity> get reports => _reports;
  SalesReportEntity? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get errorMessage => _errorMessage;
  ReportFilterEntity get currentFilter => _currentFilter;

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

  void updateFilter(ReportFilterEntity filter) {
    _currentFilter = filter;
    loadReports();
  }

  Future<void> refreshReports() async {
    await loadReports();
  }

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

  void _trimReportsIfNeeded() {
    if (_reports.length > _maxReportsInMemory) {
      final removedCount = _reports.length - _maxReportsInMemory;
      _reports = _reports.sublist(0, _maxReportsInMemory);
      debugPrint('🗑️ [PROVIDER] Bellek optimizasyonu: $removedCount rapor kaldırıldı');
      debugPrint('📊 [PROVIDER] Mevcut rapor sayısı: ${_reports.length}/$_maxReportsInMemory');
    }
  }

  /// ✅ FIX: Local Export Metodu - Platform-agnostic return
  /// Web: Uint8List döndürür
  /// Mobil: File döndürür
  /// Hata: null döndürür
  Future<dynamic> exportReportLocal({
    required SalesReportEntity report,
    required String format,
  }) async {
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('📤 [LOCAL EXPORT] Başlıyor: Format=$format, Report ID=${report.id}');
    debugPrint('🔵 [PROVIDER] Platform: ${kIsWeb ? "Web" : "Mobil"}');

    try {
      // ✅ FIX: Service çağrısından ÖNCE type belirt
      late final dynamic rawResult;

      switch (format.toLowerCase()) {
        case 'pdf':
          debugPrint('🔵 [PROVIDER] PDF export service çağrılıyor...');
          // ✅ FIX: Await sonucunu intermediate variable'a al
          final pdfResult = await PdfExportService.generatePdf(report);
          debugPrint('🔵 [PROVIDER] PDF service döndü, tip: ${pdfResult.runtimeType}');
          rawResult = pdfResult;
          break;

        case 'excel':
          debugPrint('🔵 [PROVIDER] Excel export service çağrılıyor...');
          final excelResult = await ExcelExportService.generateExcel(report);
          debugPrint('🔵 [PROVIDER] Excel service döndü, tip: ${excelResult.runtimeType}');
          rawResult = excelResult;
          break;

        case 'csv':
          debugPrint('🔵 [PROVIDER] CSV export service çağrılıyor...');
          final csvResult = await CsvExportService.generateCsv(report);
          debugPrint('🔵 [PROVIDER] CSV service döndü, tip: ${csvResult.runtimeType}');
          rawResult = csvResult;
          break;

        default:
          throw Exception('Geçersiz export formatı: $format');
      }

      debugPrint('🔵 [PROVIDER] rawResult atandı, tip kontrolü yapılıyor...');

      // Null check
      if (rawResult == null) {
        debugPrint('❌ [PROVIDER] Export servisi null döndürdü');
        throw Exception('Export servisi null döndürdü');
      }

      debugPrint('🔵 [PROVIDER] Export servisi sonuç döndürdü');
      debugPrint('🔵 [PROVIDER] Result runtime type: ${rawResult.runtimeType}');
      debugPrint('🔵 [PROVIDER] Result is Uint8List: ${rawResult is Uint8List}');
      debugPrint('🔵 [PROVIDER] Result is File: ${rawResult is File}');
      debugPrint('🔵 [PROVIDER] Result is List<int>: ${rawResult is List<int>}');

      // Platform-specific validation
      if (kIsWeb) {
        debugPrint('🌐 [PROVIDER] Web platformu - Uint8List validation');

        if (rawResult is Uint8List) {
          debugPrint('✅ [PROVIDER] Geçerli Uint8List: ${rawResult.length} bytes');
          _errorMessage = null;
          return rawResult;
        } else if (rawResult is List<int>) {
          debugPrint('🔄 [PROVIDER] List<int> -> Uint8List dönüşümü yapılıyor');
          final converted = Uint8List.fromList(rawResult);
          debugPrint('✅ [PROVIDER] Dönüştürüldü: ${converted.length} bytes');
          _errorMessage = null;
          return converted;
        } else {
          debugPrint('❌ [PROVIDER] Web için geçersiz tip: ${rawResult.runtimeType}');
          throw Exception('Web platformu için beklenen tip: Uint8List, Gelen: ${rawResult.runtimeType}');
        }
      } else {
        debugPrint('📱 [PROVIDER] Mobil platformu - File validation');

        if (rawResult is File) {
          debugPrint('✅ [PROVIDER] Geçerli File: ${rawResult.path}');
          _errorMessage = null;
          return rawResult;
        } else {
          debugPrint('❌ [PROVIDER] Mobil için geçersiz tip: ${rawResult.runtimeType}');
          throw Exception('Mobil platformu için beklenen tip: File, Gelen: ${rawResult.runtimeType}');
        }
      }

    } catch (e, stackTrace) {
      debugPrint('❌ [LOCAL EXPORT] Hata: $e');
      debugPrint('📄 [STACK TRACE] $stackTrace');
      _errorMessage = 'Export başarısız: ${e.toString()}';
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  void removeReport(int reportId) {
    final initialLength = _reports.length;
    _reports.removeWhere((report) => report.id == reportId);

    if (_reports.length < initialLength) {
      debugPrint('🗑️ [PROVIDER] Rapor silindi: ID $reportId');
      notifyListeners();
    }
  }

  void clearAllReports() {
    _reports.clear();
    _selectedReport = null;
    _errorMessage = null;
    _currentFilter = const ReportFilterEntity(period: ReportPeriod.monthly);
    debugPrint('🧹 [PROVIDER] Tüm raporlar temizlendi');
    notifyListeners();
  }

  Map<String, dynamic> getMemoryStats() {
    return {
      'total_reports': _reports.length,
      'max_limit': _maxReportsInMemory,
      'memory_usage_percent': (_reports.length / _maxReportsInMemory * 100).toStringAsFixed(1),
      'has_selected_report': _selectedReport != null,
      'current_filter_period': _currentFilter.period.toString(),
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? 'Sunucu hatası oluştu';
    } else if (failure is NetworkFailure) {
      return 'İnternet bağlantısı kontrol edin';
    } else {
      return 'Bilinmeyen hata oluştu';
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 [PROVIDER] SalesReportProvider dispose ediliyor...');
    _reports.clear();
    _selectedReport = null;
    super.dispose();
  }
}