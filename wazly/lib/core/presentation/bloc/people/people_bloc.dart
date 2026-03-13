import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/domain/entities/person_with_balance.dart';
import 'package:wazly/core/domain/usecases/get_people_with_balances.dart';
import 'package:wazly/core/usecases/usecase.dart';

part 'people_event.dart';
part 'people_state.dart';

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  final GetPeopleWithBalances getPeopleWithBalances;
  final DataEventBus dataEventBus;
  late final StreamSubscription<DataChangeEvent> _eventSubscription;

  PeopleBloc({required this.getPeopleWithBalances, required this.dataEventBus})
    : super(PeopleInitial()) {
    on<LoadPeople>(_onLoadPeople);
    on<_InternalRefreshPeople>(_onInternalRefreshPeople);
    on<SearchPeople>(_onSearchPeople);

    // Subscribe to unified central event bus
    _eventSubscription = dataEventBus.stream.listen((event) {
      if (event.type == DataChangeType.transactionUpdated ||
          event.type == DataChangeType.personUpdated ||
          event.type == DataChangeType.installmentUpdated) {
        // Trigger silent refresh to avoid UI flicker
        add(const _InternalRefreshPeople());
      }
    });
  }

  Future<void> _onLoadPeople(
    LoadPeople event,
    Emitter<PeopleState> emit,
  ) async {
    emit(PeopleLoading());

    final result = await getPeopleWithBalances(const NoParams());

    result.fold(
      (failure) => emit(PeopleError(message: failure.message)),
      (people) => emit(PeopleLoaded(fullList: people, filteredList: people)),
    );
  }

  Future<void> _onInternalRefreshPeople(
    _InternalRefreshPeople event,
    Emitter<PeopleState> emit,
  ) async {
    // Only refresh silently if we already have a loaded state, otherwise UI flickers
    // If it's already loading, let the original load finish
    if (state is PeopleLoaded) {
      final currentState = state as PeopleLoaded;
      final result = await getPeopleWithBalances(const NoParams());

      result.fold(
        (failure) => emit(PeopleError(message: failure.message)),
        (people) {
          final query = currentState.searchQuery.toLowerCase();
          final filteredList = query.isEmpty
              ? people
              : people
                    .where((p) => p.person.name.toLowerCase().contains(query))
                    .toList();

          emit(
            PeopleLoaded(
              fullList: people,
              filteredList: filteredList,
              searchQuery: currentState.searchQuery,
            ),
          );
        }, // Silent overwrite without loading state
      );
    }
  }

  void _onSearchPeople(SearchPeople event, Emitter<PeopleState> emit) {
    if (state is PeopleLoaded) {
      final currentState = state as PeopleLoaded;
      final query = event.query.toLowerCase();

      final filteredList = query.isEmpty
          ? currentState.fullList
          : currentState.fullList
                .where((p) => p.person.name.toLowerCase().contains(query))
                .toList();

      emit(
        PeopleLoaded(
          fullList: currentState.fullList,
          filteredList: filteredList,
          searchQuery: event.query,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }
}
