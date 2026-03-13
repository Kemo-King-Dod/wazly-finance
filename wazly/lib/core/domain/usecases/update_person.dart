import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/core/domain/repositories/person_repository.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:wazly/core/usecases/usecase.dart';

class UpdatePerson implements UseCase<void, UpdatePersonParams> {
  final PersonRepository repository;

  UpdatePerson(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePersonParams params) async {
    return await repository.updatePerson(params.person);
  }
}

class UpdatePersonParams extends Equatable {
  final Person person;

  const UpdatePersonParams({required this.person});

  @override
  List<Object?> get props => [person];
}
