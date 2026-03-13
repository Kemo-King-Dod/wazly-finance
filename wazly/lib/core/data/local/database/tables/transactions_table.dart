import 'package:drift/drift.dart';
import 'persons_table.dart';

@DataClassName('TransactionEntry')
class TransactionsTable extends Table {
  TextColumn get id => text()();
  IntColumn get amountInCents => integer()();
  TextColumn get type => text()(); // Persists Enum as string
  TextColumn get direction => text().nullable()(); // Persists Enum as string
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();

  TextColumn get personId => text().nullable().references(
    PersonsTable,
    #id,
    onUpdate: KeyAction.cascade,
    onDelete: KeyAction
        .cascade, // Cascade delete so deleting a person deletes their transactions
  )();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get customUniqueKeys => [];

  // Note: Drift allows adding CHECK constraints via custom statements during migration/schema creation,
  // or using the `check()` method on columns, or overriding `customConstraints`.
  // We apply custom Constraints strictly.
  @override
  List<String> get customConstraints => [
    'CHECK (amount_in_cents >= 0)',
    // If type is debt or payment, direction MUST not be null.
    // If it's treasuryIn or treasuryOut, direction MUST be null.
    '''CHECK (
      ((type = 'debt' OR type = 'payment') AND direction IS NOT NULL) OR 
      ((type = 'treasuryIn' OR type = 'treasuryOut') AND direction IS NULL)
    )''',
  ];
}
