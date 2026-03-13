import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazly/core/presentation/bloc/installment_action/installment_action_bloc.dart';
import 'package:wazly/core/domain/usecases/create_installment_plan.dart';
import 'package:wazly/core/domain/usecases/mark_installment_paid.dart';
import 'package:wazly/core/domain/entities/installment_plan.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class FakeCreateInstallmentPlan implements CreateInstallmentPlan {
  bool failNext = false;
  int callCount = 0;

  @override
  Future<Either<Failure, InstallmentPlan>> call(
    CreateInstallmentPlanParams params,
  ) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    if (failNext) return Left(GeneralFailure('Create Plan Error'));
    return Right(
      InstallmentPlan(
        id: 'plan_1',
        personId: params.personId,
        originalTransactionId: params.originalTransactionId,
        direction: params.direction,
        totalAmountInCents: params.totalAmountInCents,
        title: params.title,
        createdAt: DateTime.now(),
        isCompleted: false,
      ),
    );
  }

  @override
  get repository => throw UnimplementedError();

  @override
  get unitOfWork => throw UnimplementedError();
}

class FakeMarkInstallmentPaid implements MarkInstallmentPaid {
  bool failNext = false;
  int callCount = 0;

  @override
  Future<Either<Failure, void>> call(MarkInstallmentPaidParams params) async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    if (failNext) return Left(GeneralFailure('Mark Paid Error'));
    return const Right(null);
  }

  @override
  get addPaymentUseCase => throw UnimplementedError();

  @override
  get repository => throw UnimplementedError();

  @override
  Never get treasuryRepository => throw UnimplementedError();

  @override
  Never get unitOfWork => throw UnimplementedError();
}

void main() {
  late FakeCreateInstallmentPlan fakeCreate;
  late FakeMarkInstallmentPaid fakeMark;
  late InstallmentActionBloc bloc;

  setUp(() {
    fakeCreate = FakeCreateInstallmentPlan();
    fakeMark = FakeMarkInstallmentPaid();

    bloc = InstallmentActionBloc(
      createInstallmentPlan: fakeCreate,
      markInstallmentPaid: fakeMark,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('InstallmentActionBloc - SubmitInstallmentPlan', () {
    final params = CreateInstallmentPlanParams(
      personId: '1',
      originalTransactionId: 'tx_original',
      direction: DebtDirection.theyOweMe,
      totalAmountInCents: 500,
      title: 'Test Plan',
      items: [
        InstallmentItemDraft(amountInCents: 500, dueDate: DateTime.now()),
      ],
    );

    test(
      'emits [Submitting, Success] on successful CreateInstallmentPlan',
      () async {
        final states = <InstallmentActionState>[];
        final completer = Completer<void>();

        final sub = bloc.stream.listen((state) {
          states.add(state);
          if (states.length == 2) completer.complete();
        });

        bloc.add(SubmitInstallmentPlan(params));
        await completer.future.timeout(const Duration(milliseconds: 300));

        expect(states[0], isA<InstallmentActionSubmitting>());
        expect(states[1], isA<InstallmentActionSuccess>());
        expect(fakeCreate.callCount, 1);

        await sub.cancel();
      },
    );

    test('emits [Submitting, Error] on failed CreateInstallmentPlan', () async {
      fakeCreate.failNext = true;
      final states = <InstallmentActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitInstallmentPlan(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<InstallmentActionSubmitting>());
      expect(states[1], isA<InstallmentActionError>());
      expect(
        (states[1] as InstallmentActionError).message,
        'Create Plan Error',
      );

      await sub.cancel();
    });
  });

  group('InstallmentActionBloc - SubmitInstallmentItemPayment', () {
    final params = const MarkInstallmentPaidParams(installmentId: 'item_1');

    test(
      'emits [Submitting, Success] on successful MarkInstallmentPaid',
      () async {
        final states = <InstallmentActionState>[];
        final completer = Completer<void>();

        final sub = bloc.stream.listen((state) {
          states.add(state);
          if (states.length == 2) completer.complete();
        });

        bloc.add(SubmitInstallmentItemPayment(params));
        await completer.future.timeout(const Duration(milliseconds: 300));

        expect(states[0], isA<InstallmentActionSubmitting>());
        expect(states[1], isA<InstallmentActionSuccess>());
        expect(fakeMark.callCount, 1);

        await sub.cancel();
      },
    );

    test('emits [Submitting, Error] on failed MarkInstallmentPaid', () async {
      fakeMark.failNext = true;
      final states = <InstallmentActionState>[];
      final completer = Completer<void>();

      final sub = bloc.stream.listen((state) {
        states.add(state);
        if (states.length == 2) completer.complete();
      });

      bloc.add(SubmitInstallmentItemPayment(params));
      await completer.future.timeout(const Duration(milliseconds: 300));

      expect(states[0], isA<InstallmentActionSubmitting>());
      expect(states[1], isA<InstallmentActionError>());
      expect((states[1] as InstallmentActionError).message, 'Mark Paid Error');

      await sub.cancel();
    });
  });
}
