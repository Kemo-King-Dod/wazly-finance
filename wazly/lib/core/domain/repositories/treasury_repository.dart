import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/treasury.dart';

abstract class TreasuryRepository {
  Future<Either<Failure, Treasury>> getTreasury();
  Future<Either<Failure, void>> updateTreasury(Treasury treasury);
}
