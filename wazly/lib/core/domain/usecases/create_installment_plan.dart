import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/installment_plan.dart';
import '../entities/installment_item.dart';
import '../entities/transaction_enums.dart';
import '../repositories/installment_repository.dart';
import '../repositories/unit_of_work.dart';
import '../../data/local/database/data_event_bus.dart';

class InstallmentItemDraft {
  final int amountInCents;
  final DateTime dueDate;
  final int? notificationId;

  const InstallmentItemDraft({
    required this.amountInCents,
    required this.dueDate,
    this.notificationId,
  });
}

class CreateInstallmentPlanParams {
  final String personId;
  final String originalTransactionId;
  final DebtDirection direction;
  final int totalAmountInCents;
  final String title;
  final List<InstallmentItemDraft> items;

  const CreateInstallmentPlanParams({
    required this.personId,
    required this.originalTransactionId,
    required this.direction,
    required this.totalAmountInCents,
    required this.title,
    required this.items,
  });
}

class CreateInstallmentPlan
    implements UseCase<InstallmentPlan, CreateInstallmentPlanParams> {
  final InstallmentRepository repository;
  final UnitOfWork unitOfWork;

  CreateInstallmentPlan({required this.repository, required this.unitOfWork});

  @override
  Future<Either<Failure, InstallmentPlan>> call(
    CreateInstallmentPlanParams params,
  ) async {
    try {
      final planId = const Uuid().v4();

      final plan = InstallmentPlan(
        id: planId,
        personId: params.personId,
        originalTransactionId: params.originalTransactionId,
        direction: params.direction,
        totalAmountInCents: params.totalAmountInCents,
        title: params.title,
        createdAt: DateTime.now(),
        isCompleted: false,
      );

      final items = params.items
          .map(
            (draft) => InstallmentItem(
              id: const Uuid().v4(),
              planId: planId,
              amountInCents: draft.amountInCents,
              dueDate: draft.dueDate,
              isPaid: false,
              notificationId: draft.notificationId,
            ),
          )
          .toList();

      // Ensure sum of items equals the total plan amount
      final sum = items.fold<int>(
        0,
        (prev, element) => prev + element.amountInCents,
      );
      if (sum != plan.totalAmountInCents) {
        return const Left(
          ValidationFailure(
            'Sum of installment items must equal the total plan amount.',
          ),
        );
      }

      return await unitOfWork.executeTransaction(
        () async {
          // First save the plan
          final planResult = await repository.addPlan(plan);
          if (planResult.isLeft()) return planResult.map((_) => plan);

          // Then save all items
          final itemResult = await repository.addItems(items);
          return itemResult.map((_) => plan);
        },
        eventsToEmit: [
          DataChangeEvent(
            DataChangeType.installmentUpdated,
            personId: params.personId,
          ),
        ],
      );
    } catch (e) {
      if (e is ArgumentError) {
        return Left(ValidationFailure(e.message));
      }
      return Left(GeneralFailure(e.toString()));
    }
  }
}
