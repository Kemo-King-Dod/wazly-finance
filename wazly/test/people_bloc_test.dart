import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/core/domain/entities/person_with_balance.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:wazly/core/usecases/usecase.dart';
import 'package:wazly/core/domain/usecases/get_people_with_balances.dart';

class FakeGetPeopleWithBalances implements GetPeopleWithBalances {
  final List<PersonWithBalance> defaultPeople;
  int callCount = 0;

  FakeGetPeopleWithBalances(this.defaultPeople);

  @override
  Future<Either<Failure, List<PersonWithBalance>>> call(NoParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 10)); // DB simulation
    return Right(defaultPeople);
  }

  @override
  get repository => throw UnimplementedError();
}

void main() {
  late FakeGetPeopleWithBalances fakeUsecase;
  late DataEventBus eventBus;
  late PeopleBloc peopleBloc;

  final testPeople = [
    PersonWithBalance(
      person: Person(
        id: '1',
        name: 'John Doe',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      ),
      netBalanceInCents: 500,
    ),
  ];

  setUp(() {
    fakeUsecase = FakeGetPeopleWithBalances(testPeople);
    eventBus = DataEventBus();
    peopleBloc = PeopleBloc(
      getPeopleWithBalances: fakeUsecase,
      dataEventBus: eventBus,
    );
  });

  tearDown(() {
    peopleBloc.close();
    eventBus.dispose();
  });

  group('PeopleBloc', () {
    test('initial state is PeopleInitial', () {
      expect(peopleBloc.state, isA<PeopleInitial>());
    });

    test('emits [PeopleLoading, PeopleLoaded] on initial LoadPeople', () async {
      final states = <PeopleState>[];
      final completer = Completer<void>();

      final subscription = peopleBloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) {
          completer.complete();
        }
      });

      peopleBloc.add(const LoadPeople());

      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<PeopleLoading>());
      expect(states[1], isA<PeopleLoaded>());
      expect((states[1] as PeopleLoaded).fullList.first.netBalanceInCents, 500);
      expect(fakeUsecase.callCount, 1);

      await subscription.cancel();
    });

    test(
      'silently refreshes on DataChangeEvent.transactionUpdated if already loaded',
      () async {
        final completer1 = Completer<void>();

        final subscription = peopleBloc.stream.listen((state) {
          if (state is PeopleLoaded) {
            if (!completer1.isCompleted) completer1.complete();
          }
        });

        peopleBloc.add(const LoadPeople());
        await completer1.future.timeout(const Duration(milliseconds: 300));
        expect(fakeUsecase.callCount, 1);

        eventBus.emit(const DataChangeEvent(DataChangeType.transactionUpdated));

        await Future.delayed(const Duration(milliseconds: 300));
        await pumpEventQueue();

        expect(fakeUsecase.callCount, 2);

        await subscription.cancel();
      },
    );

    test(
      'silently refreshes on DataChangeEvent.personUpdated if already loaded',
      () async {
        final completer1 = Completer<void>();

        final subscription = peopleBloc.stream.listen((state) {
          if (state is PeopleLoaded) {
            if (!completer1.isCompleted) completer1.complete();
          }
        });

        peopleBloc.add(const LoadPeople());
        await completer1.future.timeout(const Duration(milliseconds: 300));
        expect(fakeUsecase.callCount, 1);

        eventBus.emit(const DataChangeEvent(DataChangeType.personUpdated));

        await Future.delayed(const Duration(milliseconds: 300));
        await pumpEventQueue();

        expect(fakeUsecase.callCount, 2);
        await subscription.cancel();
      },
    );

    test(
      'silently refreshes on DataChangeEvent.installmentUpdated if already loaded',
      () async {
        final completer1 = Completer<void>();

        final subscription = peopleBloc.stream.listen((state) {
          if (state is PeopleLoaded) {
            if (!completer1.isCompleted) completer1.complete();
          }
        });

        peopleBloc.add(const LoadPeople());
        await completer1.future.timeout(const Duration(milliseconds: 300));
        expect(fakeUsecase.callCount, 1);

        eventBus.emit(const DataChangeEvent(DataChangeType.installmentUpdated));

        await Future.delayed(const Duration(milliseconds: 300));
        await pumpEventQueue();

        expect(fakeUsecase.callCount, 2);
        await subscription.cancel();
      },
    );

    test('does NOT refresh on DataChangeEvent.treasuryUpdated', () async {
      final completer1 = Completer<void>();

      final subscription = peopleBloc.stream.listen((state) {
        if (state is PeopleLoaded) {
          if (!completer1.isCompleted) completer1.complete();
        }
      });

      peopleBloc.add(const LoadPeople());
      await completer1.future.timeout(const Duration(milliseconds: 300));

      eventBus.emit(const DataChangeEvent(DataChangeType.treasuryUpdated));
      await Future.delayed(const Duration(milliseconds: 300));
      await pumpEventQueue();

      expect(fakeUsecase.callCount, 1);
      await subscription.cancel();
    });
  });
}
