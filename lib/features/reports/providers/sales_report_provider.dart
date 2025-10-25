// lib/features/reports/presentation/providers/sales_report_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../data/models/sales_report_model.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/repositories/sales_report_repository.dart';
import '../../domain/usecases/export_sales_report.dart';
import '../../domain/usecases/get_sales_report_by_id.dart';
import '../../domain/usecases/get_sales_reports.dart';

class SalesReportProvider with ChangeNotifier {
  final SalesReportRepository repository;
  final GetSalesReports getSalesReportsUseCase;
  final GetSalesReportById getSalesReportByIdUseCase;
  final ExportSalesReport exportSalesReportUseCase;

  SalesReportProvider({
    required this.repository,
    required this.getSalesReportsUseCase,
    required this.getSalesReportByIdUseCase,
    required this.exportSalesReportUseCase,
  });

  // State Management
  List<SalesReportEntity> _reports = [];
  SalesReportEntity? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;
  ReportFilterEntity _currentFilter =
  const ReportFilterEntity(period: ReportPeriod.monthly);

  // Getters
  List<SalesReportEntity> get reports => _reports;
  SalesReportEntity? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReportFilterEntity get currentFilter => _currentFilter;

  // ✅ FIXED: loadReports - Use Case üzerinden yapılıyor
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

  // ✅ FIXED: loadReportById - Use Case üzerinden yapılıyor
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

  // ✅ FIXED: updateFilter - Filter'ı güncelle ve raporları yeniden yükle
  void updateFilter(ReportFilterEntity filter) {
    _currentFilter = filter;
    loadReports();
  }

  // ✅ FIXED: refreshReports - Raporları yenile
  Future<void> refreshReports() async {
    await loadReports();
  }

  // ✅ FIXED: generateReport - YENİ FONKSİYON EKLENDI
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
          // En son oluşturulan raporu da listeye ekle
          _reports.insert(0, report);
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

  // ✅ FIXED: exportReport - Export işlemi (Repository kullanıyor)
  Future<Map<String, dynamic>?> exportReport(
      String reportId,
      String format,
      ) async {
    try {
      final result = await repository.exportReport(reportId, format);

      return result.fold(
            (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          return null;
        },
            (exportResult) {
          _errorMessage = null;
          return exportResult;
        },
      );
    } catch (e) {
      _errorMessage = 'Dışa aktarma başarısız: ${e.toString()}';
      return null;
    }
  }

  // ✅ FIXED: clearError - Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ YENİ: HELPER - Failure'ı türkçe mesaja dönüştür
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? 'Sunucu hatası oluştu';
    } else if (failure is NetworkFailure) {
      return 'İnternet bağlantısı kontrol edin';
    } else {
      return 'Bilinmeyen hata oluştu';
    }
  }
}