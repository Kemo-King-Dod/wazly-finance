import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:wazly/features/debts/presentation/blocs/debt_bloc.dart';
import 'package:wazly/features/debts/presentation/blocs/debt_event.dart';
import 'package:wazly/features/debts/presentation/blocs/debt_state.dart';
import 'package:wazly/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:wazly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:bloc_test/bloc_test.dart';

import 'debt_bloc_test.mocks.dart';

@GenerateMocks([AddTransactionUseCase])
void main() {
  late DebtBloc debtBloc;
  late MockAddTransactionUseCase mockAddTransactionUseCase;

  setUp(() {
    mockAddTransactionUseCase = MockAddTransactionUseCase();
    debtBloc = DebtBloc(addTransactionUseCase: mockAddTransactionUseCase);
  });

  tearDown(() {
    debtBloc.close();
  });

  final testTransaction = TransactionEntity(
    id: '1',
    amount: 100.0,
    category: 'Debt',
    date: DateTime.now(),
    description: 'Test debt',
    isIncome: false,
    isDebt: true,
    accountId: 'default',
    linkedAccountId: 'account_1',
  );

  group('DebtBloc', () {
    test('initial state should be DebtInitial', () {
      expect(debtBloc.state, const DebtInitial());
    });

    blocTest<DebtBloc, DebtState>(
      'should emit [DebtLoading, DebtSuccess] when AddDebt is successful',
      build: () {
        when(
          mockAddTransactionUseCase(any),
        ).thenAnswer((_) async => const Right(null));
        return debtBloc;
      },
      act: (bloc) => bloc.add(AddDebt(testTransaction)),
      expect: () => [
        const DebtLoading(),
        const DebtSuccess('Debt added successfully'),
      ],
      verify: (_) {
        verify(
          mockAddTransactionUseCase(
            AddTransactionParams(transaction: testTransaction),
          ),
        );
      },
    );

    blocTest<DebtBloc, DebtState>(
      'should emit [DebtLoading, DebtError] when AddDebt fails',
      build: () {
        when(
          mockAddTransactionUseCase(any),
        ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));
        return debtBloc;
      },
      act: (bloc) => bloc.add(AddDebt(testTransaction)),
      expect: () => [const DebtLoading(), const DebtError('Server Error')],
    );

    blocTest<DebtBloc, DebtState>(
      'should emit [DebtLoading, DebtSuccess] when AddSettlement is successful',
      build: () {
        when(
          mockAddTransactionUseCase(any),
        ).thenAnswer((_) async => const Right(null));
        return debtBloc;
      },
      act: (bloc) => bloc.add(AddSettlement(testTransaction)),
      expect: () => [
        const DebtLoading(),
        const DebtSuccess('Settlement added successfully'),
      ],
      verify: (_) {
        verify(
          mockAddTransactionUseCase(
            AddTransactionParams(transaction: testTransaction),
          ),
        );
      },
    );
  });
}
