// /lib/features/reports/domain/usecases/get_sales_report_by_id.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sales_report_entity.dart';
import '../repositories/sales_report_repository.dart';

class GetSalesReportById implements UseCase<SalesReportEntity, String> {
  final SalesReportRepository repository;

  GetSalesReportById(this.repository);

  @override
  Future<Either<Failure, SalesReportEntity>> call(String params) async {
    return await repository.getSalesReportById(params);
  }
}