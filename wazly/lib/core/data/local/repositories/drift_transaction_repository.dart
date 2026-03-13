import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:wazly/core/errors/failures.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../database/app_database.dart';
import '../database/mappers.dart';

class DriftTransactionRepository implements TransactionRepository {
  final AppDatabase database;

  DriftTransactionRepository(this.database);

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByPerson(
    String personId,
  ) async {
    try {
      final query = database.select(database.transactionsTable)
        ..where((tbl) => tbl.personId.equals(personId))
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        ]);

      final entries = await query.get();
      return Right(entries.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch person transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions(
    int limit,
  ) async {
    try {
      final query = database.select(database.transactionsTable)
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        ])
        ..limit(limit);

      final entries = await query.get();
      return Right(entries.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch recent transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      await database
          .into(database.transactionsTable)
          .insert(transaction.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final query = database.select(database.transactionsTable)
        ..where((tbl) => tbl.id.equals(id));
      final entry = await query.getSingle();
      return Right(entry.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch transaction by id: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransactionById(String id) async {
    try {
      await (database.delete(
        database.transactionsTable,
      )..where((tbl) => tbl.id.equals(id))).go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransactionsByPersonId(
    String personId,
  ) async {
    try {
      await (database.delete(
        database.transactionsTable,
      )..where((tbl) => tbl.personId.equals(personId))).go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete transactions for person: $e'));
    }
  }
}
