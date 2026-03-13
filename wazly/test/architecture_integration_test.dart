import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:wazly/core/data/local/database/app_database.dart';
import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/data/local/database/drift_unit_of_work.dart';
import 'package:wazly/core/data/local/repositories/drift_installment_repository.dart';
import 'package:wazly/core/data/local/repositories/drift_person_repository.dart';
import 'package:wazly/core/data/local/repositories/drift_transaction_repository.dart';
import 'package:wazly/core/data/local/repositories/drift_treasury_repository.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/domain/usecases/add_debt.dart';
import 'package:wazly/core/domain/usecases/add_payment.dart';
import 'package:wazly/core/domain/usecases/add_person.dart';
import 'package:wazly/core/domain/usecases/create_installment_plan.dart';
import 'package:wazly/core/domain/usecases/get_dashboard_summary.dart';
import 'package:wazly/core/domain/usecases/get_people_with_balances.dart';
import 'package:wazly/core/domain/usecases/get_person_balance.dart';
import 'package:wazly/core/domain/usecases/mark_installment_paid.dart';
import 'package:wazly/core/usecases/usecase.dart';

void main() {
  late AppDatabase database;
  late DataEventBus eventBus;
  late DriftUnitOfWork unitOfWork;

  late DriftPersonRepository personRepo;
  late DriftTransactionRepository txRepo;
  late DriftTreasuryRepository treasuryRepo;
  late DriftInstallmentRepository installmentRepo;

  late AddPerson addPersonUsecase;
  late AddDebt addDebtUsecase;
  late AddPayment addPaymentUsecase;
  late CreateInstallmentPlan createPlanUsecase;
  late MarkInstallmentPaid markPaidUsecase;
  late GetDashboardSummary getDashboardSummary;
  late GetPersonBalance getPersonBalance;
  late GetPeopleWithBalances getPeopleWithBalances;

  setUp(() {
    // 1. Initialize dependencies using In-Memory Drift Database
    database = AppDatabase(NativeDatabase.memory());
    eventBus = DataEventBus();
    unitOfWork = DriftUnitOfWork(database: database, eventBus: eventBus);

    personRepo = DriftPersonRepository(database);
    txRepo = DriftTransactionRepository(database);
    treasuryRepo = DriftTreasuryRepository(database);
    installmentRepo = DriftInstallmentRepository(database);

    addPersonUsecase = AddPerson(personRepo);
    addDebtUsecase = AddDebt(repository: txRepo, unitOfWork: unitOfWork);
    addPaymentUsecase = AddPayment(
      transactionRepository: txRepo,
      treasuryRepository: treasuryRepo,
      unitOfWork: unitOfWork,
    );
    createPlanUsecase = CreateInstallmentPlan(
      repository: installmentRepo,
      unitOfWork: unitOfWork,
    );
    markPaidUsecase = MarkInstallmentPaid(
      repository: installmentRepo,
      addPaymentUseCase: addPaymentUsecase,
    );
    getPersonBalance = GetPersonBalance(personRepo);
    getPeopleWithBalances = GetPeopleWithBalances(personRepo);
    getDashboardSummary = GetDashboardSummary(
      treasuryRepository: treasuryRepo,
      transactionRepository: txRepo,
      getPeopleWithBalances: getPeopleWithBalances,
    );
  });

  tearDown(() async {
    await database.close();
    eventBus.dispose();
  });

  group('Phase 3 Final Validation: Financial and Atomic Integrity', () {
    test(
      'Scenario 1: AddDebt purely increases liability without touching Treasury',
      () async {
        // 1. Create person
        final personResult = await addPersonUsecase(
          const AddPersonParams(name: 'John Doe'),
        );
        expect(personResult.isRight(), isTrue);
        final person = personResult.getOrElse(() => throw Exception());

        // Initial Treasury check
        var treasuryResult = await treasuryRepo.getTreasury();
        expect(treasuryResult.isRight(), isTrue);
        var initialTreasury = treasuryResult.getOrElse(() => throw Exception());
        expect(initialTreasury.balanceInCents, 0);

        // 2. Add Debt (theyOweMe = I lent them money = My Asset Increases, + Balance)
        final debtResult = await addDebtUsecase(
          AddDebtParams(
            personId: person.id,
            amountInCents: 50000, // 500.00
            direction: DebtDirection.theyOweMe,
            description: 'Lent money for lunch',
            date: DateTime.now(),
          ),
        );
        expect(debtResult.isRight(), isTrue);

        // 3. Verify Treasury unchanged
        treasuryResult = await treasuryRepo.getTreasury();
        final postDebtTreasury = treasuryResult.getOrElse(
          () => throw Exception(),
        );
        expect(
          postDebtTreasury.balanceInCents,
          0,
          reason: 'Treasury should NOT budge on a Debt creation.',
        );

        // 4. Verify Person Balance Positive
        final balanceResult = await getPersonBalance(
          GetPersonBalanceParams(personId: person.id),
        );
        expect(balanceResult.isRight(), isTrue);
        final balance = balanceResult.getOrElse(() => throw Exception());
        expect(
          balance,
          50000,
          reason: 'Balance should be +50000 since they owe me.',
        );
      },
    );

    test(
      'Scenario 2: AddPayment updates Treasury and reduces balance atomically',
      () async {
        // 1. Create person and Add initial debt
        final personResult = await addPersonUsecase(
          const AddPersonParams(name: 'Jane Doe'),
        );
        final person = personResult.getOrElse(() => throw Exception());
        await addDebtUsecase(
          AddDebtParams(
            personId: person.id,
            amountInCents: 100000, // 1000.00
            direction: DebtDirection.theyOweMe,
            description: 'Lent money',
            date: DateTime.now(),
          ),
        );

        // 2. Add Payment (They pay me back 400.00)
        final paymentResult = await addPaymentUsecase(
          AddPaymentParams(
            personId: person.id,
            amountInCents: 40000,
            direction: DebtDirection.theyOweMe, // Resolving a theyOweMe debt
            description: 'Partial payback',
            date: DateTime.now(),
          ),
        );
        expect(paymentResult.isRight(), isTrue);

        // 3. Verify Person Balance properly reduced (100000 - 40000 = 60000)
        final balanceResult = await getPersonBalance(
          GetPersonBalanceParams(personId: person.id),
        );
        final balance = balanceResult.getOrElse(() => throw Exception());
        expect(balance, 60000);

        // 4. Verify Treasury is updated (+400.00 incoming cash)
        final treasuryResult = await treasuryRepo.getTreasury();
        final treasury = treasuryResult.getOrElse(() => throw Exception());
        expect(treasury.balanceInCents, 40000);
      },
    );

    test(
      'Scenario 3: CreateInstallmentPlan + MarkInstallmentPaid integration',
      () async {
        // 1. Create person and debt
        final personResult = await addPersonUsecase(
          const AddPersonParams(name: 'Bob'),
        );
        final person = personResult.getOrElse(() => throw Exception());
        await addDebtUsecase(
          AddDebtParams(
            personId: person.id,
            amountInCents: 100000,
            direction: DebtDirection.theyOweMe,
            description: 'Car fix',
            date: DateTime.now(),
          ),
        );

        // Fetch the transaction to get originalTransactionId
        final txsResult = await txRepo.getTransactionsByPerson(person.id);
        final originalTx = txsResult.getOrElse(() => throw Exception()).first;

        // 2. Create Installment Plan (2 items: 40000 and 60000)
        final planResult = await createPlanUsecase(
          CreateInstallmentPlanParams(
            personId: person.id,
            originalTransactionId: originalTx.id,
            direction: DebtDirection.theyOweMe,
            totalAmountInCents: 100000,
            title: 'Repayment Plan',
            items: [
              InstallmentItemDraft(
                amountInCents: 40000,
                dueDate: DateTime.now().add(const Duration(days: 7)),
              ),
              InstallmentItemDraft(
                amountInCents: 60000,
                dueDate: DateTime.now().add(const Duration(days: 14)),
              ),
            ],
          ),
        );
        expect(planResult.isRight(), isTrue);
        final plan = planResult.getOrElse(() => throw Exception());

        // Fetch drafted items
        final itemsResult = await installmentRepo.getItemsForPlan(plan.id);
        final items = itemsResult.getOrElse(() => throw Exception());
        expect(items.length, 2);
        expect(items[0].isPaid, isFalse);

        // 3. Mark the first installment as paid
        final markPaidResult = await markPaidUsecase(
          MarkInstallmentPaidParams(installmentId: items[0].id),
        );
        expect(markPaidResult.isRight(), isTrue);

        // 4. Verify Installment Item state is updated to true
        final itemResult = await installmentRepo.getItemById(items[0].id);
        final item = itemResult.getOrElse(() => throw Exception());
        expect(item.isPaid, isTrue);

        // 5. Verify Treasury is automatically credited via UnitOfWork payment triggered inside
        final treasuryResult = await treasuryRepo.getTreasury();
        final treasury = treasuryResult.getOrElse(() => throw Exception());
        expect(treasury.balanceInCents, 40000);

        // 6. Verify Person Balance natively reduced
        final balanceResult = await getPersonBalance(
          GetPersonBalanceParams(personId: person.id),
        );
        final balance = balanceResult.getOrElse(() => throw Exception());
        expect(balance, 60000);

        // 7. Verify plan isn't completed yet
        final updatedPlanResult = await installmentRepo.getPlanById(plan.id);
        final updatedPlan = updatedPlanResult.getOrElse(
          () => throw Exception(),
        );
        expect(updatedPlan.isCompleted, isFalse);
      },
    );

    test(
      'Scenario 4: DashboardSummary outputs reliable aggregate data',
      () async {
        // 1. Setup multiple people
        final p1Res = await addPersonUsecase(
          const AddPersonParams(name: 'Alice'),
        );
        final p2Res = await addPersonUsecase(
          const AddPersonParams(name: 'Charlie'),
        );
        final alice = p1Res.getOrElse(() => throw Exception());
        final charlie = p2Res.getOrElse(() => throw Exception());

        // Alice owes me 500
        await addDebtUsecase(
          AddDebtParams(
            personId: alice.id,
            amountInCents: 50000,
            direction: DebtDirection.theyOweMe,
            description: 'Alice debt',
            date: DateTime.now(),
          ),
        );

        // I owe Charlie 200
        await addDebtUsecase(
          AddDebtParams(
            personId: charlie.id,
            amountInCents: 20000,
            direction: DebtDirection.iOweThem,
            description: 'Charlie debt',
            date: DateTime.now(),
          ),
        );

        // Alice pays me 100
        await addPaymentUsecase(
          AddPaymentParams(
            personId: alice.id,
            amountInCents: 10000,
            direction: DebtDirection.theyOweMe,
            description: 'Alice payment',
            date: DateTime.now(),
          ),
        );

        // Dashboard logic check
        final dashboardResult = await getDashboardSummary(const NoParams());
        expect(dashboardResult.isRight(), isTrue);
        final dashboard = dashboardResult.getOrElse(() => throw Exception());

        // Treasury should exactly be +100
        expect(dashboard.treasury.balanceInCents, 10000);

        // Active Debts
        expect(dashboard.activeDebts.length, 2);
        final aliceDebt = dashboard.activeDebts.firstWhere(
          (e) => e.person.id == alice.id,
        );
        final charlieDebt = dashboard.activeDebts.firstWhere(
          (e) => e.person.id == charlie.id,
        );

        expect(aliceDebt.netBalanceInCents, 40000); // 500 - 100
        expect(charlieDebt.netBalanceInCents, -20000); // They lent me 200

        // Recent Transactions must equal 3
        expect(dashboard.recentTransactions.length, 3);
      },
    );
  });
}
