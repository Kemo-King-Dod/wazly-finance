import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../transactions/domain/usecases/add_transaction_usecase.dart';
import 'debt_event.dart';
import 'debt_state.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  final AddTransactionUseCase addTransactionUseCase;

  DebtBloc({required this.addTransactionUseCase}) : super(const DebtInitial()) {
    on<AddDebt>(_onAddDebt);
    on<AddSettlement>(_onAddSettlement);
  }

  Future<void> _onAddDebt(AddDebt event, Emitter<DebtState> emit) async {
    emit(const DebtLoading());
    final result = await addTransactionUseCase(
      AddTransactionParams(transaction: event.transaction),
    );
    result.fold(
      (failure) => emit(DebtError(failure.message)),
      (_) => emit(const DebtSuccess('Debt added successfully')),
    );
  }

  Future<void> _onAddSettlement(
    AddSettlement event,
    Emitter<DebtState> emit,
  ) async {
    emit(const DebtLoading());
    final result = await addTransactionUseCase(
      AddTransactionParams(transaction: event.transaction),
    );
    result.fold(
      (failure) => emit(DebtError(failure.message)),
      (_) => emit(const DebtSuccess('Settlement added successfully')),
    );
  }
}
