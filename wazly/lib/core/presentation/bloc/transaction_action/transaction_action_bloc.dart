import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:wazly/core/domain/usecases/add_debt.dart';
import 'package:wazly/core/domain/usecases/add_payment.dart';
import 'package:wazly/core/domain/usecases/affect_treasury.dart';
import 'package:wazly/core/domain/usecases/delete_transaction.dart';

part 'transaction_action_event.dart';
part 'transaction_action_state.dart';

class TransactionActionBloc
    extends Bloc<TransactionActionEvent, TransactionActionState> {
  final AddDebt addDebt;
  final AddPayment addPayment;
  final AffectTreasury affectTreasury;
  final DeleteTransaction deleteTransaction;

  TransactionActionBloc({
    required this.addDebt,
    required this.addPayment,
    required this.affectTreasury,
    required this.deleteTransaction,
  }) : super(TransactionActionInitial()) {
    on<SubmitDebt>(_onSubmitDebt);
    on<SubmitPayment>(_onSubmitPayment);
    on<SubmitTreasuryFlow>(_onSubmitTreasuryFlow);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<EditTransactionEvent>(_onEditTransaction);
  }

  Future<void> _onSubmitDebt(
    SubmitDebt event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionSubmitting());
    final result = await addDebt(event.params);
    result.fold(
      (failure) => emit(TransactionActionError(failure.message)),
      (_) => emit(TransactionActionSuccess()),
    );
  }

  Future<void> _onSubmitPayment(
    SubmitPayment event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionSubmitting());
    final result = await addPayment(event.params);
    result.fold(
      (failure) => emit(TransactionActionError(failure.message)),
      (_) => emit(TransactionActionSuccess()),
    );
  }

  Future<void> _onSubmitTreasuryFlow(
    SubmitTreasuryFlow event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionSubmitting());
    final result = await affectTreasury(event.params);
    result.fold(
      (failure) => emit(TransactionActionError(failure.message)),
      (_) => emit(TransactionActionSuccess()),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionSubmitting());
    final result = await deleteTransaction(
      DeleteTransactionParams(transactionId: event.transactionId),
    );
    result.fold(
      (failure) => emit(TransactionActionError(failure.message)),
      (_) => emit(TransactionActionSuccess()),
    );
  }

  Future<void> _onEditTransaction(
    EditTransactionEvent event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionSubmitting());
    // 1. Delete old transaction
    final delResult = await deleteTransaction(
      DeleteTransactionParams(transactionId: event.oldTransactionId),
    );

    if (delResult.isLeft()) {
      delResult.fold(
        (failure) => emit(TransactionActionError(failure.message)),
        (_) {},
      );
      return;
    }

    // 2. Perform new action
    if (event.newAction is SubmitDebt) {
      final res = await addDebt((event.newAction as SubmitDebt).params);
      res.fold(
        (failure) => emit(TransactionActionError(failure.message)),
        (_) => emit(TransactionActionSuccess()),
      );
    } else if (event.newAction is SubmitPayment) {
      final res = await addPayment((event.newAction as SubmitPayment).params);
      res.fold(
        (failure) => emit(TransactionActionError(failure.message)),
        (_) => emit(TransactionActionSuccess()),
      );
    } else if (event.newAction is SubmitTreasuryFlow) {
      final res = await affectTreasury(
        (event.newAction as SubmitTreasuryFlow).params,
      );
      res.fold(
        (failure) => emit(TransactionActionError(failure.message)),
        (_) => emit(TransactionActionSuccess()),
      );
    } else {
      emit(const TransactionActionError('Unsupported edit action context'));
    }
  }
}
