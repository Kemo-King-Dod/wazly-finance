import 'package:drift/drift.dart';

@DataClassName('PersonEntry')
class PersonsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get nextReminderDate => dateTime().nullable()();
  TextColumn get reminderRepeatType => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
