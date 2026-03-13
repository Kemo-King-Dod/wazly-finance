import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/installment_item.dart';
import '../entities/installment_plan.dart';
import '../repositories/installment_repository.dart';
import 'add_payment.dart';

class MarkInstallmentPaidParams {
  final String installmentId;

  const MarkInstallmentPaidParams({required this.installmentId});
}

class MarkInstallmentPaid implements UseCase<void, MarkInstallmentPaidParams> {
  final InstallmentRepository repository;
  final AddPayment addPaymentUseCase;
  // TODO: Add NotificationService to cancel any pending notifications by item.notificationId

  MarkInstallmentPaid({
    required this.repository,
    required this.addPaymentUseCase,
  });

  @override
  Future<Either<Failure, void>> call(MarkInstallmentPaidParams params) async {
    try {
      // 1. Fetch item
      final itemResult = await repository.getItemById(params.installmentId);
      return await itemResult.fold((failure) async => Left(failure), (
        item,
      ) async {
        if (item.isPaid) {
          return const Left(ValidationFailure('Installment is already paid.'));
        }

        // 2. Fetch parent plan
        final planResult = await repository.getPlanById(item.planId);
        return await planResult.fold((failure) async => Left(failure), (
          plan,
        ) async {
          // 3. Process the financial transaction (this handles UnitOfWork internally)
          final paymentParams = AddPaymentParams(
            personId: plan.personId,
            amountInCents: item.amountInCents,
            direction: plan.direction,
            description: 'Installment Payment for: ${plan.title}',
            date: DateTime.now(),
          );

          final paymentResult = await addPaymentUseCase(paymentParams);

          return await paymentResult.fold((failure) async => Left(failure), (
            _,
          ) async {
            // 4. Update the item
            final updatedItem = InstallmentItem(
              id: item.id,
              planId: item.planId,
              amountInCents: item.amountInCents,
              dueDate: item.dueDate,
              isPaid: true,
              paidDate: DateTime.now(),
              notificationId: item
                  .notificationId, // Notification to be cancelled centrally or by listener
            );

            final itemUpdateResult = await repository.updateItem(updatedItem);
            if (itemUpdateResult.isLeft()) return itemUpdateResult;

            // 5. Check if all items are paid to complete plan
            final allItemsResult = await repository.getItemsForPlan(plan.id);
            return await allItemsResult.fold((failure) async => Left(failure), (
              items,
            ) async {
              // We must swap the old item for the new one in memory check
              final updatedItemsList = items
                  .map((i) => i.id == updatedItem.id ? updatedItem : i)
                  .toList();
              final allPaid = updatedItemsList.every((i) => i.isPaid);

              if (allPaid) {
                final updatedPlan = InstallmentPlan(
                  id: plan.id,
                  personId: plan.personId,
                  originalTransactionId: plan.originalTransactionId,
                  direction: plan.direction,
                  totalAmountInCents: plan.totalAmountInCents,
                  title: plan.title,
                  createdAt: plan.createdAt,
                  isCompleted: true,
                );
                return await repository.updatePlan(updatedPlan);
              }

              return const Right(null);
            });
          });
        });
      });
    } catch (e) {
      if (e is ArgumentError) {
        return Left(ValidationFailure(e.message));
      }
      return Left(GeneralFailure(e.toString()));
    }
  }
}
