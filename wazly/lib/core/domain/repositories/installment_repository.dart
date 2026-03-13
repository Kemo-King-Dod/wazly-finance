import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/installment_plan.dart';
import '../entities/installment_item.dart';

abstract class InstallmentRepository {
  Future<Either<Failure, List<InstallmentPlan>>> getPlansByPerson(
    String personId,
  );
  Future<Either<Failure, InstallmentPlan>> getPlanById(String planId);
  Future<Either<Failure, List<InstallmentItem>>> getItemsForPlan(String planId);
  Future<Either<Failure, InstallmentItem>> getItemById(String itemId);

  // Mutations
  Future<Either<Failure, void>> addPlan(InstallmentPlan plan);
  Future<Either<Failure, void>> addItems(List<InstallmentItem> items);
  Future<Either<Failure, void>> updateItem(InstallmentItem item);
  Future<Either<Failure, void>> updatePlan(InstallmentPlan plan);
  Future<Either<Failure, void>> deleteItemsByPlanId(String planId);
  Future<Either<Failure, void>> deletePlanById(String planId);
}
