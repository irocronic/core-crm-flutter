// lib/features/reports/data/repositories/sales_report_repository_impl.dart

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
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantınızı kontrol edin'));
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
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantınızı kontrol edin'));
    }
  }

  @override
  Future<Either<Failure, SalesReportEntity>> generateReport(
      ReportFilterEntity filter,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final report = await remoteDataSource.generateReport(filter.toApiData());
        return Right(report);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Rapor oluşturulamadı: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantınızı kontrol edin'));
    }
  }

  /// ✅ YENİ: Export Report Implementation
  @override
  Future<Either<Failure, Map<String, dynamic>>> exportReport(
      String reportId,
      String format,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.exportReport(reportId, format);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Rapor dışa aktarılamadı: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantınızı kontrol edin'));
    }
  }
}