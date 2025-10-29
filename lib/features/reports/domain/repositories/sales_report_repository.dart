// lib/features/reports/domain/repositories/sales_report_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sales_report_entity.dart';

abstract class SalesReportRepository {
  /// Filtreye göre satış raporlarını getirir
  Future<Either<Failure, List<SalesReportEntity>>> getSalesReports(
      ReportFilterEntity filter,
      );

  /// ID'ye göre tek bir satış raporu getirir
  Future<Either<Failure, SalesReportEntity>> getSalesReportById(String id);

  /// Yeni rapor oluşturur
  Future<Either<Failure, SalesReportEntity>> generateReport(
      ReportFilterEntity filter,
      );

  /// ✅ YENİ: Raporu belirtilen formatta dışa aktarır
  /// [reportId] - Dışa aktarılacak raporun ID'si
  /// [format] - Dışa aktarma formatı ('pdf', 'excel', 'csv')
  /// Returns: Dosya URL'i veya base64 encoded data içeren Map
  Future<Either<Failure, Map<String, dynamic>>> exportReport(
      String reportId,
      String format,
      );
}