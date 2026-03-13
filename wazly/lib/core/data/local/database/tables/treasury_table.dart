import 'package:drift/drift.dart';

@DataClassName('TreasuryEntry')
class TreasuryTable extends Table {
  // We use a single constant ID conceptually since there's only one treasury,
  // or just rely on a single row insertion.
  IntColumn get id => integer().autoIncrement()();
  IntColumn get balanceInCents => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('LYD'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
