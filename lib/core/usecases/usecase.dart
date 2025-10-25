// lib/core/storage/usecases/usecase.dart

import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base UseCase interface
/// [Type] - Dönüş tipi
/// [Params] - Parametre tipi
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Parametresiz usecase için
class NoParams {
  const NoParams();
}