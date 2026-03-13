import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

class AddPersonParams {
  final String name;
  final String? phoneNumber;

  const AddPersonParams({required this.name, this.phoneNumber});
}

class AddPerson implements UseCase<Person, AddPersonParams> {
  final PersonRepository repository;

  AddPerson(this.repository);

  @override
  Future<Either<Failure, Person>> call(AddPersonParams params) async {
    try {
      final person = Person(
        id: const Uuid().v4(),
        name: params.name,
        phoneNumber: params.phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await repository.addPerson(person);
    } catch (e) {
      if (e is ArgumentError) {
        return Left(ValidationFailure(e.message));
      }
      return Left(GeneralFailure(e.toString()));
    }
  }
}
