import 'package:drift/drift.dart';
import 'persons_table.dart';
import 'transactions_table.dart';

@DataClassName('InstallmentPlanEntry')
class InstallmentPlansTable extends Table {
  TextColumn get id => text()();

  TextColumn get personId => text().references(
    PersonsTable,
    #id,
    onUpdate: KeyAction.cascade,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get originalTransactionId => text().references(
    TransactionsTable,
    #id,
    onUpdate: KeyAction.cascade,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get direction => text()(); // DebtDirection Enum string
  IntColumn get totalAmountInCents => integer()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (total_amount_in_cents > 0)'];
}
