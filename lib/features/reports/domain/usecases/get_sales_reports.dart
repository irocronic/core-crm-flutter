// /lib/features/reports/domain/usecases/get_sales_reports.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sales_report_entity.dart';
import '../repositories/sales_report_repository.dart';

class GetSalesReports implements UseCase<List<SalesReportEntity>, ReportFilterEntity> {
  final SalesReportRepository repository;

  GetSalesReports(this.repository);

  @override
  Future<Either<Failure, List<SalesReportEntity>>> call(
      ReportFilterEntity params,
      ) async {
    return await repository.getSalesReports(params);
  }
}