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
import 'package:wazly/core/domain/usecases/affect_treasury.dart';
import 'package:wazly/core/domain/usecases/create_installment_plan.dart';
import 'package:wazly/core/domain/usecases/get_dashboard_summary.dart';
import 'package:wazly/core/domain/usecases/get_people_with_balances.dart';
import 'package:wazly/core/domain/usecases/get_person_balance.dart';
import 'package:wazly/core/domain/usecases/get_person_by_id.dart';
import 'package:wazly/core/domain/usecases/get_transactions_by_person.dart';
import 'package:wazly/core/domain/usecases/get_installment_plans_by_person.dart';
import 'package:wazly/core/domain/usecases/delete_transaction.dart';
import 'package:wazly/core/domain/usecases/mark_installment_paid.dart';

import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/presentation/bloc/person_details/person_details_bloc.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/presentation/bloc/installment_action/installment_action_bloc.dart';

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
  late AffectTreasury affectTreasuryUsecase;
  late DeleteTransaction deleteTransactionUsecase;
  late CreateInstallmentPlan createPlanUsecase;
  late MarkInstallmentPaid markPaidUsecase;

  late GetDashboardSummary getDashboardSummary;
  late GetPersonBalance getPersonBalance;
  late GetPeopleWithBalances getPeopleWithBalances;
  late GetPersonById getPersonById;
  late GetTransactionsByPerson getTransactionsByPerson;
  late GetInstallmentPlansByPerson getInstallmentPlansByPerson;

  // Blocs
  late DashboardBloc dashboardBloc;
  late PeopleBloc peopleBloc;
  late PersonDetailsBloc personDetailsBloc;
  late TransactionActionBloc transactionActionBloc;
  late InstallmentActionBloc installmentActionBloc;

  setUp(() {
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
    affectTreasuryUsecase = AffectTreasury(
      transactionRepository: txRepo,
      treasuryRepository: treasuryRepo,
      unitOfWork: unitOfWork,
    );
    deleteTransactionUsecase = DeleteTransaction(
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
    getPersonById = GetPersonById(personRepo);
    getTransactionsByPerson = GetTransactionsByPerson(txRepo);
    getInstallmentPlansByPerson = GetInstallmentPlansByPerson(installmentRepo);
    getDashboardSummary = GetDashboardSummary(
      treasuryRepository: treasuryRepo,
      transactionRepository: txRepo,
      getPeopleWithBalances: getPeopleWithBalances,
    );

    dashboardBloc = DashboardBloc(
      getDashboardSummary: getDashboardSummary,
      dataEventBus: eventBus,
    );
    peopleBloc = PeopleBloc(
      getPeopleWithBalances: getPeopleWithBalances,
      dataEventBus: eventBus,
    );
    personDetailsBloc = PersonDetailsBloc(
      getPersonById: getPersonById,
      getPersonBalance: getPersonBalance,
      getTransactionsByPerson: getTransactionsByPerson,
      getInstallmentPlansByPerson: getInstallmentPlansByPerson,
      dataEventBus: eventBus,
    );
    transactionActionBloc = TransactionActionBloc(
      addDebt: addDebtUsecase,
      addPayment: addPaymentUsecase,
      affectTreasury: affectTreasuryUsecase,
      deleteTransaction: deleteTransactionUsecase,
    );
    installmentActionBloc = InstallmentActionBloc(
      createInstallmentPlan: createPlanUsecase,
      markInstallmentPaid: markPaidUsecase,
    );
  });

  tearDown(() async {
    dashboardBloc.close();
    peopleBloc.close();
    personDetailsBloc.close();
    transactionActionBloc.close();
    installmentActionBloc.close();
    await database.close();
    eventBus.dispose();
  });

  group('BLoC Integration Suite', () {
    test(
      'Scenario 1: SubmitDebt propagates through EventBus to Read Blocs',
      () async {
        // 1. Setup Person
        final personResult = await addPersonUsecase(
          const AddPersonParams(name: 'Test Setup'),
        );
        final person = personResult.getOrElse(() => throw Exception());

        // 2. Load Read Blocs initially
        dashboardBloc.add(LoadDashboard());
        peopleBloc.add(const LoadPeople());
        personDetailsBloc.add(LoadPersonDetails(person.id));

        // Wait for Initial Load states to settle to Loaded
        await Future.delayed(const Duration(milliseconds: 100));
        print("Initial Dashboard State: ${dashboardBloc.state}");
        print("Initial People State: ${peopleBloc.state}");
        print("Initial PersonDetails State: ${personDetailsBloc.state}");

        final dashboardStates = <DashboardState>[];
        final peopleStates = <PeopleState>[];
        final personDetailsStates = <PersonDetailsState>[];

        final dSub = dashboardBloc.stream.listen(
          (state) => dashboardStates.add(state),
        );
        final pSub = peopleBloc.stream.listen(
          (state) => peopleStates.add(state),
        );
        final pdSub = personDetailsBloc.stream.listen(
          (state) => personDetailsStates.add(state),
        );

        // 3. Fire SubmitDebt mutation
        transactionActionBloc.add(
          SubmitDebt(
            AddDebtParams(
              personId: person.id,
              amountInCents: 1000,
              direction: DebtDirection.theyOweMe,
              description: 'Integration test',
              date: DateTime.now(),
            ),
          ),
        );

        // 4. Wait for propagation
        await Future.delayed(const Duration(milliseconds: 200));

        // Assertions
        expect(
          dashboardStates,
          isNotEmpty,
          reason: 'Dashboard failed to refresh',
        );
        expect(dashboardStates.last, isA<DashboardLoaded>());

        expect(
          peopleStates,
          isNotEmpty,
          reason: 'People list failed to refresh',
        );
        expect(
          (peopleStates.last as PeopleLoaded).fullList.first.netBalanceInCents,
          1000,
        );

        expect(
          personDetailsStates,
          isNotEmpty,
          reason: 'Person details failed to refresh',
        );
        expect(
          (personDetailsStates.last as PersonDetailsLoaded).netBalanceInCents,
          1000,
        );
        expect(
          (personDetailsStates.last as PersonDetailsLoaded).transactions.length,
          1,
        );

        await dSub.cancel();
        await pSub.cancel();
        await pdSub.cancel();
      },
    );

    test('Scenario 2: SubmitPayment refreshes relevant blocs', () async {
      // 1. Setup Person and existing Debt
      final personResult = await addPersonUsecase(
        const AddPersonParams(name: 'Test Setup'),
      );
      final person = personResult.getOrElse(() => throw Exception());
      await addDebtUsecase(
        AddDebtParams(
          personId: person.id,
          amountInCents: 1000,
          direction: DebtDirection.theyOweMe,
          description: 'Initial',
          date: DateTime.now(),
        ),
      );

      // 2. Settle read blocs
      dashboardBloc.add(LoadDashboard());
      peopleBloc.add(const LoadPeople());
      personDetailsBloc.add(LoadPersonDetails(person.id));
      await Future.delayed(const Duration(milliseconds: 100));

      final dashboardStates = <DashboardState>[];
      final peopleStates = <PeopleState>[];
      final personDetailsStates = <PersonDetailsState>[];

      final dSub = dashboardBloc.stream.listen(
        (state) => dashboardStates.add(state),
      );
      final pSub = peopleBloc.stream.listen((state) => peopleStates.add(state));
      final pdSub = personDetailsBloc.stream.listen(
        (state) => personDetailsStates.add(state),
      );

      // 3. Fire SubmitPayment
      transactionActionBloc.add(
        SubmitPayment(
          AddPaymentParams(
            personId: person.id,
            amountInCents: 500,
            direction: DebtDirection.theyOweMe,
            description: 'Payback',
            date: DateTime.now(),
          ),
        ),
      );

      // 4. Wait for propagation
      await Future.delayed(const Duration(milliseconds: 200));

      // Assertions
      expect(dashboardStates, isNotEmpty);
      expect(
        (dashboardStates.last as DashboardLoaded)
            .summary
            .treasury
            .balanceInCents,
        500,
      );

      expect(peopleStates, isNotEmpty);
      expect(
        (peopleStates.last as PeopleLoaded).fullList.first.netBalanceInCents,
        500,
      );

      expect(personDetailsStates, isNotEmpty);
      expect(
        (personDetailsStates.last as PersonDetailsLoaded).netBalanceInCents,
        500,
      );
      expect(
        (personDetailsStates.last as PersonDetailsLoaded).transactions.length,
        2,
      );

      await dSub.cancel();
      await pSub.cancel();
      await pdSub.cancel();
    });

    test('Scenario 3: MarkInstallmentPaid triggers deep propagation', () async {
      // 1. Setup Data
      final personResult = await addPersonUsecase(
        const AddPersonParams(name: 'Installment Tester'),
      );
      final person = personResult.getOrElse(() => throw Exception());

      await addDebtUsecase(
        AddDebtParams(
          personId: person.id,
          amountInCents: 2000,
          direction: DebtDirection.theyOweMe,
          description: 'Car debt',
          date: DateTime.now(),
        ),
      );

      final txsResult = await getTransactionsByPerson(
        GetTransactionsByPersonParams(personId: person.id),
      );
      final originalTxId = txsResult
          .getOrElse(() => throw Exception())
          .first
          .id;

      final planResult = await createPlanUsecase(
        CreateInstallmentPlanParams(
          personId: person.id,
          originalTransactionId: originalTxId,
          direction: DebtDirection.theyOweMe,
          totalAmountInCents: 2000,
          title: 'Plan',
          items: [
            InstallmentItemDraft(amountInCents: 1000, dueDate: DateTime.now()),
            InstallmentItemDraft(
              amountInCents: 1000,
              dueDate: DateTime.now().add(const Duration(days: 30)),
            ),
          ],
        ),
      );
      final plan = planResult.getOrElse(() => throw Exception());

      final itemsResult = await installmentRepo.getItemsForPlan(plan.id);
      final itemId = itemsResult.getOrElse(() => throw Exception()).first.id;

      // 2. Load Blocs
      dashboardBloc.add(LoadDashboard());
      personDetailsBloc.add(LoadPersonDetails(person.id));
      await Future.delayed(const Duration(milliseconds: 100));

      final dashboardStates = <DashboardState>[];
      final personDetailsStates = <PersonDetailsState>[];

      final dSub = dashboardBloc.stream.listen(
        (state) => dashboardStates.add(state),
      );
      final pdSub = personDetailsBloc.stream.listen(
        (state) => personDetailsStates.add(state),
      );

      // 3. Fire MarkPaid
      installmentActionBloc.add(
        SubmitInstallmentItemPayment(
          MarkInstallmentPaidParams(installmentId: itemId),
        ),
      );

      // 4. Wait for propagation
      await Future.delayed(const Duration(milliseconds: 300));

      expect(
        dashboardStates,
        isNotEmpty,
        reason: 'Dashboard did not refresh on Installment Paid',
      );
      expect(
        (dashboardStates.last as DashboardLoaded)
            .summary
            .treasury
            .balanceInCents,
        1000,
        reason: 'Treasury should have +1000 cash now',
      );

      expect(
        personDetailsStates,
        isNotEmpty,
        reason: 'PersonDetails did not refresh on Installment Paid',
      );
      expect(
        (personDetailsStates.last as PersonDetailsLoaded).netBalanceInCents,
        1000,
        reason: 'Net balance should drop to 1000',
      );
      // Original Tx + New Payment Tx
      expect(
        (personDetailsStates.last as PersonDetailsLoaded).transactions.length,
        2,
        reason: 'Payment transaction should be attached',
      );

      await dSub.cancel();
      await pdSub.cancel();
    });
  });
}
