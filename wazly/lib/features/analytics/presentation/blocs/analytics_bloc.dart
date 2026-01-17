import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_category_wise_expenses_usecase.dart';
import '../../../accounts/domain/usecases/calculate_net_worth_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetCategoryWiseExpensesUseCase getCategoryWiseExpensesUseCase;
  final CalculateNetWorthUseCase calculateNetWorthUseCase;

  AnalyticsBloc({
    required this.getCategoryWiseExpensesUseCase,
    required this.calculateNetWorthUseCase,
  }) : super(const AnalyticsInitial()) {
    on<FetchAnalyticsData>(_onFetchAnalyticsData);
  }

  Future<void> _onFetchAnalyticsData(
    FetchAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());

    final expensesResult = await getCategoryWiseExpensesUseCase(
      CategoryExpensesParams(filter: event.filter),
    );

    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    expensesResult.fold((failure) => emit(AnalyticsError(failure.message)), (
      expenses,
    ) {
      netWorthResult.fold((failure) => emit(AnalyticsError(failure.message)), (
        netWorth,
      ) {
        // Calculate total expenses from category breakdown (not all transactions)
        final totalExpenses = expenses.fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );
        final totalIncome = 0.0; // TODO: Implement income analytics

        emit(
          AnalyticsLoaded(
            categoryExpenses: expenses,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            currentFilter: event.filter,
            totalBalance: netWorth.vaultBalance,
            debtAssets: netWorth.debtAssets,
            debtLiabilities: netWorth.debtLiabilities,
          ),
        );
      });
    });
  }
}
