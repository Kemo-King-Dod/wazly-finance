import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/installment_plan.dart';
import 'package:wazly/core/domain/usecases/get_person_by_id.dart';
import 'package:wazly/core/domain/usecases/get_person_balance.dart';
import 'package:wazly/core/domain/usecases/get_transactions_by_person.dart';
import 'package:wazly/core/domain/usecases/get_installment_plans_by_person.dart';

part 'person_details_event.dart';
part 'person_details_state.dart';

class PersonDetailsBloc extends Bloc<PersonDetailsEvent, PersonDetailsState> {
  final GetPersonById getPersonById;
  final GetPersonBalance getPersonBalance;
  final GetTransactionsByPerson getTransactionsByPerson;
  final GetInstallmentPlansByPerson getInstallmentPlansByPerson;
  final DataEventBus dataEventBus;

  late final StreamSubscription<DataChangeEvent> _eventSubscription;
  String? _currentPersonId;

  PersonDetailsBloc({
    required this.getPersonById,
    required this.getPersonBalance,
    required this.getTransactionsByPerson,
    required this.getInstallmentPlansByPerson,
    required this.dataEventBus,
  }) : super(PersonDetailsInitial()) {
    on<LoadPersonDetails>(_onLoadPersonDetails);
    on<_InternalRefreshPersonDetails>(_onInternalRefreshPersonDetails);

    // Subscribe to unified central event bus
    _eventSubscription = dataEventBus.stream.listen((event) {
      if (_currentPersonId == null) return;

      // Rule: Only refresh if the event logically affects the same personId
      // If the event provides a personId, ensure it matches the current person.
      if (event.personId != null && event.personId != _currentPersonId) {
        return; // Ignore events for other people
      }

      if (event.type == DataChangeType.transactionUpdated ||
          event.type == DataChangeType.personUpdated ||
          event.type == DataChangeType.installmentUpdated) {
        // Trigger silent refresh to avoid UI flicker
        add(_InternalRefreshPersonDetails(_currentPersonId!));
      }
    });
  }

  Future<void> _onLoadPersonDetails(
    LoadPersonDetails event,
    Emitter<PersonDetailsState> emit,
  ) async {
    _currentPersonId = event.personId;
    emit(PersonDetailsLoading());
    await _fetchAndEmit(event.personId, emit);
  }

  Future<void> _onInternalRefreshPersonDetails(
    _InternalRefreshPersonDetails event,
    Emitter<PersonDetailsState> emit,
  ) async {
    // Only refresh silently if we already have a loaded state, otherwise UI flickers
    if (state is PersonDetailsLoaded && _currentPersonId == event.personId) {
      await _fetchAndEmit(event.personId, emit);
    }
  }

  Future<void> _fetchAndEmit(
    String personId,
    Emitter<PersonDetailsState> emit,
  ) async {
    final personResult = await getPersonById(
      GetPersonByIdParams(personId: personId),
    );
    if (personResult.isLeft()) {
      personResult.fold(
        (failure) => emit(PersonDetailsError(message: failure.message)),
        (_) {},
      );
      return;
    }

    final balanceResult = await getPersonBalance(
      GetPersonBalanceParams(personId: personId),
    );
    if (balanceResult.isLeft()) {
      balanceResult.fold(
        (failure) => emit(PersonDetailsError(message: failure.message)),
        (_) {},
      );
      return;
    }

    final txResult = await getTransactionsByPerson(
      GetTransactionsByPersonParams(personId: personId),
    );
    if (txResult.isLeft()) {
      txResult.fold(
        (failure) => emit(PersonDetailsError(message: failure.message)),
        (_) {},
      );
      return;
    }

    final instResult = await getInstallmentPlansByPerson(
      GetInstallmentPlansByPersonParams(personId: personId),
    );
    if (instResult.isLeft()) {
      instResult.fold(
        (failure) => emit(PersonDetailsError(message: failure.message)),
        (_) {},
      );
      return;
    }

    // Success
    emit(
      PersonDetailsLoaded(
        person: personResult.getOrElse(() => throw Exception()),
        netBalanceInCents: balanceResult.getOrElse(() => 0),
        transactions: txResult.getOrElse(() => []),
        installmentPlans: instResult.getOrElse(() => []),
      ),
    );
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }
}
