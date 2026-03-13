import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:wazly/core/errors/failures.dart';
import '../../../domain/entities/installment_plan.dart';
import '../../../domain/entities/installment_item.dart';
import '../../../domain/repositories/installment_repository.dart';
import '../database/app_database.dart';
import '../database/mappers.dart';

class DriftInstallmentRepository implements InstallmentRepository {
  final AppDatabase database;

  DriftInstallmentRepository(this.database);

  @override
  Future<Either<Failure, List<InstallmentPlan>>> getPlansByPerson(
    String personId,
  ) async {
    try {
      final query = database.select(database.installmentPlansTable)
        ..where((tbl) => tbl.personId.equals(personId));

      final entries = await query.get();
      return Right(entries.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch installment plans: $e'));
    }
  }

  @override
  Future<Either<Failure, InstallmentPlan>> getPlanById(String planId) async {
    try {
      final entry = await (database.select(
        database.installmentPlansTable,
      )..where((tbl) => tbl.id.equals(planId))).getSingle();
      return Right(entry.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch installment plan: $e'));
    }
  }

  @override
  Future<Either<Failure, List<InstallmentItem>>> getItemsForPlan(
    String planId,
  ) async {
    try {
      final query = database.select(database.installmentItemsTable)
        ..where((tbl) => tbl.planId.equals(planId))
        ..orderBy([
          (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
        ]);

      final entries = await query.get();
      return Right(entries.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch installment items: $e'));
    }
  }

  @override
  Future<Either<Failure, InstallmentItem>> getItemById(String itemId) async {
    try {
      final entry = await (database.select(
        database.installmentItemsTable,
      )..where((tbl) => tbl.id.equals(itemId))).getSingle();
      return Right(entry.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch installment item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPlan(InstallmentPlan plan) async {
    try {
      await database
          .into(database.installmentPlansTable)
          .insert(plan.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add installment plan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addItems(List<InstallmentItem> items) async {
    try {
      await database.batch((batch) {
        batch.insertAll(
          database.installmentItemsTable,
          items.map((i) => i.toCompanion()).toList(),
        );
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add installment items: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(InstallmentItem item) async {
    try {
      await database
          .update(database.installmentItemsTable)
          .replace(item.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update installment item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePlan(InstallmentPlan plan) async {
    try {
      await database
          .update(database.installmentPlansTable)
          .replace(plan.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update installment plan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItemsByPlanId(String planId) async {
    try {
      await (database.delete(
        database.installmentItemsTable,
      )..where((tbl) => tbl.planId.equals(planId))).go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete installment items: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlanById(String planId) async {
    try {
      await (database.delete(
        database.installmentPlansTable,
      )..where((tbl) => tbl.id.equals(planId))).go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete installment plan: $e'));
    }
  }
}
