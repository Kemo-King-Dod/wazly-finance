import 'package:dartz/dartz.dart';
import 'package:wazly/core/errors/failures.dart';
import '../../../domain/entities/treasury.dart';
import '../../../domain/repositories/treasury_repository.dart';
import '../database/app_database.dart';
import '../database/mappers.dart';

class DriftTreasuryRepository implements TreasuryRepository {
  final AppDatabase database;

  DriftTreasuryRepository(this.database);

  @override
  Future<Either<Failure, Treasury>> getTreasury() async {
    try {
      // Treasury is a singleton row table
      final entries = await database.select(database.treasuryTable).get();
      if (entries.isEmpty) {
        // Fallback safety (AppDatabase handles default insertion on migrate, but we guard here)
        return Right(Treasury(balanceInCents: 0, currency: 'LYD'));
      }
      return Right(entries.first.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch treasury: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTreasury(Treasury treasury) async {
    try {
      final entries = await database.select(database.treasuryTable).get();
      if (entries.isEmpty) {
        await database
            .into(database.treasuryTable)
            .insert(treasury.toCompanion());
      } else {
        // Update the single row explicitly
        final singleRow = entries.first;
        await (database.update(database.treasuryTable)
              ..where((tbl) => tbl.id.equals(singleRow.id)))
            .write(treasury.toCompanion());
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update treasury: $e'));
    }
  }
}
