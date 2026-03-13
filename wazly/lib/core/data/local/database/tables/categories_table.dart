import 'package:drift/drift.dart';

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconCode => text()();
  IntColumn get colorValue => integer()();

  // 0 for income, 1 for expense
  IntColumn get type => integer()();

  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
