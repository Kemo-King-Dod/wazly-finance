import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/domain/entities/dashboard_summary.dart';
import 'package:wazly/core/domain/usecases/get_dashboard_summary.dart';
import 'package:wazly/core/usecases/usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getDashboardSummary;
  final DataEventBus dataEventBus;
  late final StreamSubscription<DataChangeEvent> _eventSubscription;

  DashboardBloc({required this.getDashboardSummary, required this.dataEventBus})
    : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<_InternalRefreshDashboard>(_onInternalRefreshDashboard);

    // Subscribe to unified central event bus
    _eventSubscription = dataEventBus.stream.listen((event) {
      if (event.type == DataChangeType.transactionUpdated ||
          event.type == DataChangeType.treasuryUpdated ||
          event.type == DataChangeType.installmentUpdated) {
        // Trigger silent refresh to avoid UI flicker
        add(const _InternalRefreshDashboard());
      }
    });
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await getDashboardSummary(const NoParams());

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (summary) => emit(DashboardLoaded(summary: summary)),
    );
  }

  Future<void> _onInternalRefreshDashboard(
    _InternalRefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Only refresh silently if we already have a loaded state, otherwise UI flickers
    // If it's already loading, let the original load finish
    if (state is DashboardLoaded) {
      final result = await getDashboardSummary(const NoParams());

      result.fold(
        (failure) => emit(DashboardError(message: failure.message)),
        (summary) => emit(
          DashboardLoaded(summary: summary),
        ), // Silent overwrite without loading state
      );
    }
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }
}
