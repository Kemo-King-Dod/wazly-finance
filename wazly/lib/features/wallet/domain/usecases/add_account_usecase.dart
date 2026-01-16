import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account_entity.dart';
import '../repositories/wallet_repository.dart';

/// Parameters for AddAccountUseCase
class AddAccountParams extends Equatable {
  final AccountEntity account;

  const AddAccountParams({required this.account});

  @override
  List<Object?> get props => [account];
}

/// Use case for adding a new account
class AddAccountUseCase implements UseCase<void, AddAccountParams> {
  final WalletRepository repository;

  AddAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddAccountParams params) async {
    // Validate account
    if (params.account.name.trim().isEmpty) {
      return Left(ValidationFailure('Account name is required'));
    }

    return await repository.addAccount(params.account);
  }
}
