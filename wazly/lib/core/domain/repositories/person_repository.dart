import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/person.dart';
import '../entities/person_with_balance.dart';

abstract class PersonRepository {
  Future<Either<Failure, Person>> addPerson(Person person);
  Future<Either<Failure, List<Person>>> getPersons();
  Future<Either<Failure, Person>> getPersonById(String id);
  Future<Either<Failure, void>> updatePerson(Person person);
  Future<Either<Failure, void>> deletePerson(String id);

  // Aggregation queries delegated to Data Layer
  Future<Either<Failure, int>> getPersonBalanceInCents(String personId);
  Future<Either<Failure, List<PersonWithBalance>>> getPeopleWithBalances();
}
