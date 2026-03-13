import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:wazly/core/domain/usecases/create_installment_plan.dart';
import 'package:wazly/core/domain/usecases/mark_installment_paid.dart';

part 'installment_action_event.dart';
part 'installment_action_state.dart';

class InstallmentActionBloc
    extends Bloc<InstallmentActionEvent, InstallmentActionState> {
  final CreateInstallmentPlan createInstallmentPlan;
  final MarkInstallmentPaid markInstallmentPaid;

  InstallmentActionBloc({
    required this.createInstallmentPlan,
    required this.markInstallmentPaid,
  }) : super(InstallmentActionInitial()) {
    on<SubmitInstallmentPlan>(_onSubmitInstallmentPlan);
    on<SubmitInstallmentItemPayment>(_onSubmitInstallmentItemPayment);
  }

  Future<void> _onSubmitInstallmentPlan(
    SubmitInstallmentPlan event,
    Emitter<InstallmentActionState> emit,
  ) async {
    emit(InstallmentActionSubmitting());
    final result = await createInstallmentPlan(event.params);
    result.fold(
      (failure) => emit(InstallmentActionError(failure.message)),
      (_) => emit(InstallmentActionSuccess()),
    );
  }

  Future<void> _onSubmitInstallmentItemPayment(
    SubmitInstallmentItemPayment event,
    Emitter<InstallmentActionState> emit,
  ) async {
    emit(InstallmentActionSubmitting());
    final result = await markInstallmentPaid(event.params);
    result.fold(
      (failure) => emit(InstallmentActionError(failure.message)),
      (_) => emit(InstallmentActionSuccess()),
    );
  }
}
