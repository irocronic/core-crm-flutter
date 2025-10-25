// /lib/features/reports/data/repositories/sales_report_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/repositories/sales_report_repository.dart';
import '../datasources/sales_report_remote_datasource.dart';

class SalesReportRepositoryImpl implements SalesReportRepository {
  final SalesReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  SalesReportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SalesReportEntity>>> getSalesReports(
      ReportFilterEntity filter,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final reports = await remoteDataSource.getSalesReports(filter);
        return Right(reports);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, SalesReportEntity>> getSalesReportById(
      String id,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final report = await remoteDataSource.getSalesReportById(id);
        return Right(report);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  // ✅ YENİ METOT İMPLEMENTASYONU
  @override
  Future<Either<Failure, SalesReportEntity>> generateReport(
      ReportFilterEntity filter) async {
    if (await networkInfo.isConnected) {
      try {
        final report =
        await remoteDataSource.generateReport(filter.toApiData());
        return Right(report);
      } on ServerException {
        return Left(ServerFailure('Rapor oluşturulamadı.'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}