import 'package:drift/drift.dart';
import 'installment_plans_table.dart';

@DataClassName('InstallmentItemEntry')
class InstallmentItemsTable extends Table {
  TextColumn get id => text()();

  TextColumn get planId => text().references(
    InstallmentPlansTable,
    #id,
    onUpdate: KeyAction.cascade,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get amountInCents => integer()();
  DateTimeColumn get dueDate => dateTime()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidDate => dateTime().nullable()();
  IntColumn get notificationId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (amount_in_cents > 0)'];
}
