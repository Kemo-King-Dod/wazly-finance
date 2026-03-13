import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazly/core/presentation/bloc/person_details/person_details_bloc.dart';
import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/installment_plan.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:wazly/core/domain/usecases/get_person_by_id.dart';
import 'package:wazly/core/domain/usecases/get_person_balance.dart';
import 'package:wazly/core/domain/usecases/get_transactions_by_person.dart';
import 'package:wazly/core/domain/usecases/get_installment_plans_by_person.dart';

class FakeGetPersonById implements GetPersonById {
  final Person defaultPerson;
  int callCount = 0;

  FakeGetPersonById(this.defaultPerson);

  @override
  Future<Either<Failure, Person>> call(GetPersonByIdParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    return Right(defaultPerson);
  }

  @override
  get repository => throw UnimplementedError();
}

class FakeGetPersonBalance implements GetPersonBalance {
  final int defaultBalance;
  int callCount = 0;

  FakeGetPersonBalance(this.defaultBalance);

  @override
  Future<Either<Failure, int>> call(GetPersonBalanceParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    return Right(defaultBalance);
  }

  @override
  get repository => throw UnimplementedError();
}

class FakeGetTransactionsByPerson implements GetTransactionsByPerson {
  final List<Transaction> defaultTransactions;
  int callCount = 0;

  FakeGetTransactionsByPerson(this.defaultTransactions);

  @override
  Future<Either<Failure, List<Transaction>>> call(
    GetTransactionsByPersonParams params,
  ) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    return Right(defaultTransactions);
  }

  @override
  get repository => throw UnimplementedError();
}

class FakeGetInstallmentPlansByPerson implements GetInstallmentPlansByPerson {
  final List<InstallmentPlan> defaultPlans;
  int callCount = 0;

  FakeGetInstallmentPlansByPerson(this.defaultPlans);

  @override
  Future<Either<Failure, List<InstallmentPlan>>> call(
    GetInstallmentPlansByPersonParams params,
  ) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    return Right(defaultPlans);
  }

  @override
  get repository => throw UnimplementedError();
}

void main() {
  late FakeGetPersonById fakeGetPerson;
  late FakeGetPersonBalance fakeGetBalance;
  late FakeGetTransactionsByPerson fakeGetTransactions;
  late FakeGetInstallmentPlansByPerson fakeGetInstallmentPlans;
  late DataEventBus eventBus;
  late PersonDetailsBloc bloc;

  final testPerson = Person(
    id: 'person_1',
    name: 'John Doe',
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );

  final testTx = Transaction(
    id: 'tx_1',
    amountInCents: 500,
    type: TransactionType.debt,
    direction: DebtDirection.theyOweMe,
    description: 'Test',
    date: DateTime(2023, 1, 1),
    personId: 'person_1',
  );

  setUp(() {
    fakeGetPerson = FakeGetPersonById(testPerson);
    fakeGetBalance = FakeGetPersonBalance(500);
    fakeGetTransactions = FakeGetTransactionsByPerson([testTx]);
    fakeGetInstallmentPlans = FakeGetInstallmentPlansByPerson([]);
    eventBus = DataEventBus();

    bloc = PersonDetailsBloc(
      getPersonById: fakeGetPerson,
      getPersonBalance: fakeGetBalance,
      getTransactionsByPerson: fakeGetTransactions,
      getInstallmentPlansByPerson: fakeGetInstallmentPlans,
      dataEventBus: eventBus,
    );
  });

  tearDown(() {
    bloc.close();
    eventBus.dispose();
  });

  group('PersonDetailsBloc', () {
    test('initial state is PersonDetailsInitial', () {
      expect(bloc.state, isA<PersonDetailsInitial>());
    });

    test(
      'emits [PersonDetailsLoading, PersonDetailsLoaded] on LoadPersonDetails',
      () async {
        final states = <PersonDetailsState>[];
        final completer = Completer<void>();

        final sub = bloc.stream.listen((state) {
          states.add(state);
          if (states.length == 2) completer.complete();
        });

        bloc.add(const LoadPersonDetails('person_1'));
        await completer.future.timeout(const Duration(milliseconds: 300));

        expect(states[0], isA<PersonDetailsLoading>());
        expect(states[1], isA<PersonDetailsLoaded>());

        final loaded = states[1] as PersonDetailsLoaded;
        expect(loaded.person.id, 'person_1');
        expect(loaded.netBalanceInCents, 500);

        expect(fakeGetPerson.callCount, 1);
        expect(fakeGetBalance.callCount, 1);

        await sub.cancel();
      },
    );

    test('silently refreshes if DataChangeEvent matches personId', () async {
      final completer1 = Completer<void>();

      final sub = bloc.stream.listen((state) {
        if (state is PersonDetailsLoaded) {
          if (!completer1.isCompleted) completer1.complete();
        }
      });

      bloc.add(const LoadPersonDetails('person_1'));
      await completer1.future.timeout(const Duration(milliseconds: 300));
      expect(fakeGetPerson.callCount, 1);

      // Fire event strictly for this person
      eventBus.emit(
        const DataChangeEvent(
          DataChangeType.transactionUpdated,
          personId: 'person_1',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      await pumpEventQueue();

      // Ensure fetch occurred silently
      expect(fakeGetPerson.callCount, 2);
      expect(fakeGetBalance.callCount, 2);

      await sub.cancel();
    });

    test(
      'does NOT refresh if DataChangeEvent personId does NOT match',
      () async {
        final completer1 = Completer<void>();

        final sub = bloc.stream.listen((state) {
          if (state is PersonDetailsLoaded) {
            if (!completer1.isCompleted) completer1.complete();
          }
        });

        bloc.add(const LoadPersonDetails('person_1'));
        await completer1.future.timeout(const Duration(milliseconds: 300));
        expect(fakeGetPerson.callCount, 1);

        // Fire event for SOMEONE ELSE
        eventBus.emit(
          const DataChangeEvent(
            DataChangeType.transactionUpdated,
            personId: 'person_OTHER',
          ),
        );

        await Future.delayed(const Duration(milliseconds: 300));
        await pumpEventQueue();

        // Fetch count should STILL BE 1
        expect(fakeGetPerson.callCount, 1);
        expect(fakeGetBalance.callCount, 1);

        await sub.cancel();
      },
    );
  });
}
