import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../repositories/person_repository.dart';

class GetPersonBalanceParams {
  final String personId;

  const GetPersonBalanceParams({required this.personId});
}

class GetPersonBalance implements UseCase<int, GetPersonBalanceParams> {
  final PersonRepository repository;

  GetPersonBalance(this.repository);

  @override
  Future<Either<Failure, int>> call(GetPersonBalanceParams params) async {
    return await repository.getPersonBalanceInCents(params.personId);
  }
}
