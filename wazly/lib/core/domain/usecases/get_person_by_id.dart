import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

class GetPersonByIdParams {
  final String personId;

  const GetPersonByIdParams({required this.personId});
}

class GetPersonById implements UseCase<Person, GetPersonByIdParams> {
  final PersonRepository repository;

  GetPersonById(this.repository);

  @override
  Future<Either<Failure, Person>> call(GetPersonByIdParams params) async {
    return await repository.getPersonById(params.personId);
  }
}
