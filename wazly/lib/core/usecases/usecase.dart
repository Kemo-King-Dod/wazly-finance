import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base class for all use cases
/// [Type] is the return type
/// [Params] is the parameter type
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Used when a use case doesn't need parameters
class NoParams {
  const NoParams();
}
