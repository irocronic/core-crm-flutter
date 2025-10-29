// lib/features/reports/domain/usecases/export_sales_report.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/sales_report_repository.dart';

/// ✅ YENİ: Export Report UseCase
class ExportSalesReport implements UseCase<Map<String, dynamic>, ExportReportParams> {
  final SalesReportRepository repository;

  ExportSalesReport(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(ExportReportParams params) async {
    return await repository.exportReport(params.reportId, params.format);
  }
}

/// Export işlemi için parametreler
class ExportReportParams {
  final String reportId;
  final String format;

  const ExportReportParams({
    required this.reportId,
    required this.format,
  });

  /// Format validasyonu
  bool get isValidFormat {
    const validFormats = ['pdf', 'excel', 'csv'];
    return validFormats.contains(format.toLowerCase());
  }

  /// Format görünen adı
  String get formatDisplayName {
    switch (format.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'excel':
        return 'Excel';
      case 'csv':
        return 'CSV';
      default:
        return format.toUpperCase();
    }
  }
}