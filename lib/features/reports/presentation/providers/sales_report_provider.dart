// lib/features/reports/presentation/providers/sales_report_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/usecases/get_sales_reports.dart';
import '../../domain/usecases/get_sales_report_by_id.dart';
import '../../domain/repositories/sales_report_repository.dart';
import '../../../../core/error/failures.dart';

class SalesReportProvider extends ChangeNotifier {
  final GetSalesReports getSalesReportsUseCase;
  final GetSalesReportById getSalesReportByIdUseCase;
  final SalesReportRepository repository;

  SalesReportProvider({
    required this.getSalesReportsUseCase,
    required this.getSalesReportByIdUseCase,
    required this.repository,
  });

  List<SalesReportEntity> _reports = [];
  SalesReportEntity? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;
  ReportFilterEntity _currentFilter = const ReportFilterEntity(
    period: ReportPeriod.monthly,
  );

  List<SalesReportEntity> get reports => _reports;
  SalesReportEntity? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
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
          _errorMessage = _getFailureMessage(failure);
          _reports = [];
        },
            (reports) {
          _reports = reports;
          debugPrint('✅ ${_reports.length} rapor yüklendi');
        },
      );
    } catch (e) {
      _errorMessage = 'Raporlar yüklenirken hata oluştu: $e';
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
          _errorMessage = _getFailureMessage(failure);
          _selectedReport = null;
        },
            (report) {
          _selectedReport = report;
          debugPrint('✅ Rapor detayı yüklendi: ${report.id}');
        },
      );
    } catch (e) {
      _errorMessage = 'Rapor detayı yüklenirken hata oluştu: $e';
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
      return result.fold(
            (failure) {
          _errorMessage = _getFailureMessage(failure);
          _isLoading = false;
          notifyListeners();
          return null;
        },
            (report) {
          _isLoading = false;
          // Rapor listesine ekle
          _reports.insert(0, report);
          notifyListeners();
          return report;
        },
      );
    } catch (e) {
      _errorMessage = 'Rapor oluşturma hatası: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? 'Sunucu hatası';
    } else if (failure is NetworkFailure) {
      return 'İnternet bağlantısı yok';
    }
    return 'Bilinmeyen hata';
  }
}