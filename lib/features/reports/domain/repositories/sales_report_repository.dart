// /lib/features/reports/domain/repositories/sales_report_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sales_report_entity.dart';

abstract class SalesReportRepository {
  Future<Either<Failure, List<SalesReportEntity>>> getSalesReports(
      ReportFilterEntity filter,
      );
  Future<Either<Failure, SalesReportEntity>> getSalesReportById(String id);

  // ✅ YENİ METOT TANIMI
  Future<Either<Failure, SalesReportEntity>> generateReport(
      ReportFilterEntity filter);
}