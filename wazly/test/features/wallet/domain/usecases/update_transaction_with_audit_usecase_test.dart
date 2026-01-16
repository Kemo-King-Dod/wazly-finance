import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:wazly/features/wallet/domain/entities/transaction_entity.dart';
import 'package:wazly/features/wallet/domain/usecases/update_transaction_with_audit_usecase.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:wazly/features/wallet/domain/repositories/wallet_repository.dart';

import 'update_transaction_with_audit_usecase_test.mocks.dart';

@GenerateMocks([WalletRepository])
void main() {
  late UpdateTransactionWithAuditUseCase useCase;
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
    useCase = UpdateTransactionWithAuditUseCase(mockRepository);
  });

  group('UpdateTransactionWithAuditUseCase', () {
    final oldTransaction = TransactionEntity(
      id: '1',
      amount: 100.0,
      category: 'Food',
      date: DateTime(2024, 1, 1),
      description: 'Groceries',
      isIncome: false,
      isDebt: false,
      accountId: 'default',
    );

    final newTransaction = TransactionEntity(
      id: '1',
      amount: 150.0,
      category: 'Food',
      date: DateTime(2024, 1, 1),
      description: 'Groceries',
      isIncome: false,
      isDebt: false,
      accountId: 'default',
    );

    test(
      'should return ValidationFailure when trying to update without providing a reason',
      () async {
        // Arrange
        final params = UpdateTransactionWithAuditParams(
          oldTransaction: oldTransaction,
          newTransaction: newTransaction,
          reason: '', // Empty reason
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(
          result,
          const Left(ValidationFailure('Modification reason is required')),
        );
        verifyNever(
          mockRepository.updateTransactionWithAudit(
            oldTransaction: anyNamed('oldTransaction'),
            newTransaction: anyNamed('newTransaction'),
            reason: anyNamed('reason'),
          ),
        );
      },
    );

    test(
      'should return ValidationFailure when transaction IDs do not match',
      () async {
        // Arrange
        final differentIdTransaction = TransactionEntity(
          id: '2', // Different ID
          amount: 150.0,
          category: 'Food',
          date: DateTime(2024, 1, 1),
          description: 'Groceries',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        );

        final params = UpdateTransactionWithAuditParams(
          oldTransaction: oldTransaction,
          newTransaction: differentIdTransaction,
          reason: 'Price changed',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(
          result,
          const Left(ValidationFailure('Transaction IDs must match')),
        );
        verifyNever(
          mockRepository.updateTransactionWithAudit(
            oldTransaction: anyNamed('oldTransaction'),
            newTransaction: anyNamed('newTransaction'),
            reason: anyNamed('reason'),
          ),
        );
      },
    );

    test(
      'should call repository with updated transaction including reason',
      () async {
        // Arrange
        final params = UpdateTransactionWithAuditParams(
          oldTransaction: oldTransaction,
          newTransaction: newTransaction,
          reason: 'Price increased',
        );

        when(
          mockRepository.updateTransactionWithAudit(
            oldTransaction: anyNamed('oldTransaction'),
            newTransaction: anyNamed('newTransaction'),
            reason: anyNamed('reason'),
          ),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, const Right(null));
        verify(
          mockRepository.updateTransactionWithAudit(
            oldTransaction: oldTransaction,
            newTransaction: argThat(
              predicate<TransactionEntity>(
                (t) => t.lastModifiedReason == 'Price increased',
              ),
              named: 'newTransaction',
            ),
            reason: 'Price increased',
          ),
        ).called(1);
      },
    );
  });
}
