import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/domain/usecases/add_debt.dart';
import 'package:wazly/core/domain/usecases/add_payment.dart';
import 'package:wazly/core/domain/usecases/affect_treasury.dart';
import 'package:wazly/core/domain/usecases/delete_transaction.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class FakeAddDebt implements AddDebt {
  bool failNext = false;
  int callCount = 0;

  @override
  Future<Either<Failure, void>> call(AddDebtParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    if (failNext) return Left(GeneralFailure('Debt Error'));
    return const Right(null);
  }

  @override
  get repository => throw UnimplementedError();

  @override
  get unitOfWork => throw UnimplementedError();
}

class FakeAddPayment implements AddPayment {
  bool failNext = false;
  int callCount = 0;

  @override
  Future<Either<Failure, void>> call(AddPaymentParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    if (failNext) return Left(GeneralFailure('Payment Error'));
    return const Right(null);
  }

  @override
  get transactionRepository => throw UnimplementedError();

  @override
  get treasuryRepository => throw UnimplementedError();

  @override
  get unitOfWork => throw UnimplementedError();
}

class FakeAffectTreasury implements AffectTreasury {
  bool failNext = false;
  int callCount = 0;

  @override
  Future<Either<Failure, void>> call(AffectTreasuryParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    if (failNext) return Left(GeneralFailure('Treasury Error'));
    return const Right(null);
  }

  @override
  get transactionRepository => throw UnimplementedError();

  @override
  get treasuryRepository => throw UnimplementedError();

  @override
  get unitOfWork => throw UnimplementedError();
}

class FakeDeleteTransaction implements DeleteTransaction {
  bool failNext = false;
  int callCount = 0;

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    if (failNext) return Left(GeneralFailure('Delete Error'));
    return const Right(null);
  }

  @override
  get transactionRepository => throw UnimplementedError();

  @override
  get treasuryRepository => throw UnimplementedError();

  @override
  get unitOfWork => throw UnimplementedError();
}

void main() {
  late FakeAddDebt fakeAddDebt;
  late FakeAddPayment fakeAddPayment;
  late FakeAffectTreasury fakeAffectTreasury;
  late FakeDeleteTransaction fakeDeleteTransaction;
  late TransactionActionBloc bloc;

  setUp(() {
    fakeAddDebt = FakeAddDebt();
    fakeAddPayment = FakeAddPayment();
    fakeAffectTreasury = FakeAffectTreasury();
    fakeDeleteTransaction = FakeDeleteTransaction();

    bloc = TransactionActionBloc(
      addDebt: fakeAddDebt,
      addPayment: fakeAddPayment,
      affectTreasury: fakeAffectTreasury,
      deleteTransaction: fakeDeleteTransaction,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('TransactionActionBloc - SubmitDebt', () {
    final params = AddDebtParams(
      personId: '1',
      amountInCents: 500,
      direction: DebtDirection.iOweThem,
      description: 'Test',
      date: DateTime.now(),
    );

    test('emits [Submitting, Success] on successful AddDebt', () async {
      final states = <TransactionActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitDebt(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<TransactionActionSubmitting>());
      expect(states[1], isA<TransactionActionSuccess>());
      expect(fakeAddDebt.callCount, 1);

      await sub.cancel();
    });

    test('emits [Submitting, Error] on failed AddDebt', () async {
      fakeAddDebt.failNext = true;
      final states = <TransactionActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitDebt(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<TransactionActionSubmitting>());
      expect(states[1], isA<TransactionActionError>());
      expect((states[1] as TransactionActionError).message, 'Debt Error');

      await sub.cancel();
    });
  });

  group('TransactionActionBloc - SubmitPayment', () {
    final params = AddPaymentParams(
      personId: '1',
      amountInCents: 500,
      direction: DebtDirection.theyOweMe, // In Payment context
      description: 'Test',
      date: DateTime.now(),
    );

    test('emits [Submitting, Success] on successful AddPayment', () async {
      final states = <TransactionActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitPayment(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<TransactionActionSubmitting>());
      expect(states[1], isA<TransactionActionSuccess>());
      expect(fakeAddPayment.callCount, 1);

      await sub.cancel();
    });

    test('emits [Submitting, Error] on failed AddPayment', () async {
      fakeAddPayment.failNext = true;
      final states = <TransactionActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitPayment(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<TransactionActionSubmitting>());
      expect(states[1], isA<TransactionActionError>());

      await sub.cancel();
    });
  });

  group('TransactionActionBloc - SubmitTreasuryFlow', () {
    final params = AffectTreasuryParams(
      amountInCents: 500,
      type: TransactionType.treasuryIn,
      description: 'Test',
      date: DateTime.now(),
    );

    test('emits [Submitting, Success] on successful AffectTreasury', () async {
      final states = <TransactionActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitTreasuryFlow(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<TransactionActionSubmitting>());
      expect(states[1], isA<TransactionActionSuccess>());
      expect(fakeAffectTreasury.callCount, 1);

      await sub.cancel();
    });

    test('emits [Submitting, Error] on failed AffectTreasury', () async {
      fakeAffectTreasury.failNext = true;
      final states = <TransactionActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitTreasuryFlow(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<TransactionActionSubmitting>());
      expect(states[1], isA<TransactionActionError>());

      await sub.cancel();
    });
  });
}
