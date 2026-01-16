import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/wallet_repository.dart';

/// Parameters for adding a transaction
class AddTransactionParams extends Equatable {
  final TransactionEntity transaction;

  const AddTransactionParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Use case for adding a new transaction
class AddTransactionUseCase implements UseCase<void, AddTransactionParams> {
  final WalletRepository repository;

  AddTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return await repository.addTransaction(params.transaction);
  }
}
