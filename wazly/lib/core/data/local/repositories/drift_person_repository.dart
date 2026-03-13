import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:wazly/core/errors/failures.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/person_with_balance.dart';
import '../../../domain/repositories/person_repository.dart';
import '../database/app_database.dart';
import '../database/mappers.dart';

class DriftPersonRepository implements PersonRepository {
  final AppDatabase database;

  DriftPersonRepository(this.database);

  @override
  Future<Either<Failure, Person>> addPerson(Person person) async {
    try {
      await database.into(database.personsTable).insert(person.toCompanion());
      return Right(person);
    } catch (e) {
      return Left(CacheFailure('Failed to add person: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Person>>> getPersons() async {
    try {
      final entries = await database.select(database.personsTable).get();
      return Right(entries.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch persons: $e'));
    }
  }

  @override
  Future<Either<Failure, Person>> getPersonById(String id) async {
    try {
      final entry = await (database.select(
        database.personsTable,
      )..where((tbl) => tbl.id.equals(id))).getSingle();
      return Right(entry.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch person: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePerson(Person person) async {
    try {
      await database
          .update(database.personsTable)
          .replace(person.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update person: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePerson(String id) async {
    try {
      await (database.delete(
        database.personsTable,
      )..where((tbl) => tbl.id.equals(id))).go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete person: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPersonBalanceInCents(String personId) async {
    try {
      // Execute raw SQL aggregation to compute Net Balance instantly.
      // Logic mapping signedAmountForPerson:
      // debt && theyOweMe -> +
      // debt && themToMe -> -
      // payment && theyOweMe -> -
      // payment && themToMe -> +
      final query = '''
      SELECT COALESCE(SUM(
        CASE 
          WHEN type = 'debt' AND direction = 'theyOweMe' THEN amount_in_cents
          WHEN type = 'debt' AND direction = 'iOweThem' THEN -amount_in_cents
          WHEN type = 'payment' AND direction = 'theyOweMe' THEN -amount_in_cents
          WHEN type = 'payment' AND direction = 'iOweThem' THEN amount_in_cents
          ELSE 0 
        END
      ), 0) AS net_balance
      FROM transactions_table
      WHERE person_id = ?;
      ''';

      final result = await database
          .customSelect(query, variables: [Variable.withString(personId)])
          .getSingle();
      final balance = result.read<int>('net_balance');

      return Right(balance);
    } catch (e) {
      return Left(CacheFailure('Failed to compute balance: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PersonWithBalance>>>
  getPeopleWithBalances() async {
    try {
      // Execute an optimized grouped query to retrieve all people and their computed balances.
      final query = '''
      SELECT p.*,
        COALESCE(SUM(
          CASE 
            WHEN t.type = 'debt' AND t.direction = 'theyOweMe' THEN t.amount_in_cents
            WHEN t.type = 'debt' AND t.direction = 'iOweThem' THEN -t.amount_in_cents
            WHEN t.type = 'payment' AND t.direction = 'theyOweMe' THEN -t.amount_in_cents
            WHEN t.type = 'payment' AND t.direction = 'iOweThem' THEN t.amount_in_cents
            ELSE 0 
          END
        ), 0) AS net_balance
      FROM persons_table p
      LEFT JOIN transactions_table t ON p.id = t.person_id
      GROUP BY p.id;
      ''';

      final rows = await database.customSelect(query).get();

      final List<PersonWithBalance> results = [];
      for (final row in rows) {
        // Map raw row to PersonEntry using Drift's built-in mapper
        final mappedPerson = database.personsTable.map(row.data);
        final balance = row.read<int>('net_balance');

        results.add(
          PersonWithBalance(
            person: mappedPerson.toDomain(),
            netBalanceInCents: balance,
          ),
        );
      }
      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch people with balances: $e'));
    }
  }
}
