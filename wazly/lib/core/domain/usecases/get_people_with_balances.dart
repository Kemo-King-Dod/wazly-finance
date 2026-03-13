import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/person_with_balance.dart';
import '../repositories/person_repository.dart';

class GetPeopleWithBalances
    implements UseCase<List<PersonWithBalance>, NoParams> {
  final PersonRepository repository;

  GetPeopleWithBalances(this.repository);

  @override
  Future<Either<Failure, List<PersonWithBalance>>> call(NoParams params) async {
    return await repository.getPeopleWithBalances();
  }
}
