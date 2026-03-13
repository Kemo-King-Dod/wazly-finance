part of 'installment_action_bloc.dart';

abstract class InstallmentActionEvent extends Equatable {
  const InstallmentActionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitInstallmentPlan extends InstallmentActionEvent {
  final CreateInstallmentPlanParams params;

  const SubmitInstallmentPlan(this.params);

  @override
  List<Object?> get props => [params];
}

class SubmitInstallmentItemPayment extends InstallmentActionEvent {
  final MarkInstallmentPaidParams params;

  const SubmitInstallmentItemPayment(this.params);

  @override
  List<Object?> get props => [params];
}
