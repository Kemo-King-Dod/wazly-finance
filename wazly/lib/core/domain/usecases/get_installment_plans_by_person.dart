import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/installment_plan.dart';
import '../repositories/installment_repository.dart';

class GetInstallmentPlansByPersonParams {
  final String personId;

  const GetInstallmentPlansByPersonParams({required this.personId});
}

class GetInstallmentPlansByPerson
    implements
        UseCase<List<InstallmentPlan>, GetInstallmentPlansByPersonParams> {
  final InstallmentRepository repository;

  GetInstallmentPlansByPerson(this.repository);

  @override
  Future<Either<Failure, List<InstallmentPlan>>> call(
    GetInstallmentPlansByPersonParams params,
  ) async {
    return await repository.getPlansByPerson(params.personId);
  }
}
