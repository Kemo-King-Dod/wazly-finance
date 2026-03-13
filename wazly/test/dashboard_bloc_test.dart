import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/domain/usecases/get_dashboard_summary.dart';
import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/domain/entities/dashboard_summary.dart';
import 'package:wazly/core/domain/entities/treasury.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:wazly/core/usecases/usecase.dart';

class FakeGetDashboardSummary implements GetDashboardSummary {
  final DashboardSummary defaultSummary;
  int callCount = 0;

  FakeGetDashboardSummary(this.defaultSummary);

  @override
  Future<Either<Failure, DashboardSummary>> call(NoParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 10)); // DB simulation
    return Right(defaultSummary);
  }

  @override
  get getPeopleWithBalances => throw UnimplementedError();

  @override
  get transactionRepository => throw UnimplementedError();

  @override
  get treasuryRepository => throw UnimplementedError();
}

void main() {
  late FakeGetDashboardSummary fakeUsecase;
  late DataEventBus eventBus;
  late DashboardBloc dashboardBloc;

  final testSummary = DashboardSummary(
    treasury: const Treasury(balanceInCents: 1000, currency: 'LYD'),
    activeDebts: [],
    recentTransactions: [],
  );

  setUp(() {
    fakeUsecase = FakeGetDashboardSummary(testSummary);
    eventBus = DataEventBus();
    dashboardBloc = DashboardBloc(
      getDashboardSummary: fakeUsecase,
      dataEventBus: eventBus,
    );
  });

  tearDown(() {
    dashboardBloc.close();
    eventBus.dispose();
  });

  group('DashboardBloc', () {
    test('initial state is DashboardInitial', () {
      expect(dashboardBloc.state, isA<DashboardInitial>());
    });

    test(
      'emits [DashboardLoading, DashboardLoaded] on initial LoadDashboard',
      () async {
        final states = <DashboardState>[];
        final completer = Completer<void>();

        final subscription = dashboardBloc.stream.listen((state) {
          states.add(state);
          if (states.length == 2) {
            completer.complete();
          }
        });

        dashboardBloc.add(const LoadDashboard());

        await completer.future.timeout(const Duration(milliseconds: 300));

        expect(states[0], isA<DashboardLoading>());
        expect(states[1], isA<DashboardLoaded>());
        expect(
          (states[1] as DashboardLoaded).summary.treasury.balanceInCents,
          1000,
        );
        expect(fakeUsecase.callCount, 1);

        await subscription.cancel();
      },
    );

    test(
      'silently refreshes on DataChangeEvent.transactionUpdated if already loaded',
      () async {
        final completer1 = Completer<void>();

        final subscription = dashboardBloc.stream.listen((state) {
          if (state is DashboardLoaded) {
            if (!completer1.isCompleted) completer1.complete();
          }
        });

        dashboardBloc.add(const LoadDashboard());
        await completer1.future.timeout(const Duration(milliseconds: 300));
        expect(fakeUsecase.callCount, 1);

        // Trigger update
        eventBus.emit(const DataChangeEvent(DataChangeType.transactionUpdated));

        // Bloc doesn't emit duplicate states when equating the exact same object.
        // So we just pump the event loop securely to let the Usecase run.
        await Future.delayed(const Duration(milliseconds: 300));
        await pumpEventQueue();

        expect(fakeUsecase.callCount, 2);

        await subscription.cancel();
      },
    );

    test(
      'silently refreshes on DataChangeEvent.treasuryUpdated if already loaded',
      () async {
        final completer1 = Completer<void>();

        final subscription = dashboardBloc.stream.listen((state) {
          if (state is DashboardLoaded) {
            if (!completer1.isCompleted) completer1.complete();
          }
        });

        dashboardBloc.add(const LoadDashboard());
        await completer1.future.timeout(const Duration(milliseconds: 300));
        expect(fakeUsecase.callCount, 1);

        eventBus.emit(const DataChangeEvent(DataChangeType.treasuryUpdated));

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

        final subscription = dashboardBloc.stream.listen((state) {
          if (state is DashboardLoaded) {
            if (!completer1.isCompleted) completer1.complete();
          }
        });

        dashboardBloc.add(const LoadDashboard());
        await completer1.future.timeout(const Duration(milliseconds: 300));
        expect(fakeUsecase.callCount, 1);

        eventBus.emit(const DataChangeEvent(DataChangeType.installmentUpdated));

        await Future.delayed(const Duration(milliseconds: 300));
        await pumpEventQueue();

        expect(fakeUsecase.callCount, 2);
        await subscription.cancel();
      },
    );

    test('does NOT refresh on DataChangeEvent.personUpdated', () async {
      final completer1 = Completer<void>();

      final subscription = dashboardBloc.stream.listen((state) {
        if (state is DashboardLoaded) {
          if (!completer1.isCompleted) completer1.complete();
        }
      });

      dashboardBloc.add(const LoadDashboard());
      await completer1.future.timeout(const Duration(milliseconds: 300));

      eventBus.emit(const DataChangeEvent(DataChangeType.personUpdated));
      await Future.delayed(const Duration(milliseconds: 300));
      await pumpEventQueue();

      expect(fakeUsecase.callCount, 1);
      await subscription.cancel();
    });
  });
}
