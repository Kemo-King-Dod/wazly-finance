import 'package:drift/drift.dart';
import 'package:wazly/core/data/local/database/app_database.dart';

class DriftCategoryRepository {
  final AppDatabase _db;

  DriftCategoryRepository(this._db);

  Stream<List<CategoriesTableData>> watchCategories(int type) {
    return (_db.select(_db.categoriesTable)
          ..where((t) => t.type.equals(type))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<int> addCategory({
    required String id,
    required String name,
    required String iconCode,
    required int colorValue,
    required int type,
  }) {
    return _db
        .into(_db.categoriesTable)
        .insert(
          CategoriesTableCompanion.insert(
            id: id,
            name: name,
            iconCode: iconCode,
            colorValue: colorValue,
            type: type,
            isSystem: const Value(false),
          ),
        );
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    required String iconCode,
    required int colorValue,
  }) {
    return _db
        .update(_db.categoriesTable)
        .replace(
          CategoriesTableData(
            id: id,
            name: name,
            iconCode: iconCode,
            colorValue: colorValue,
            type: 0, // Not updating type
            isSystem: false, // You shouldn't update system categories
          ),
        );
  }

  Future<int> deleteCategory(String id) {
    return (_db.delete(_db.categoriesTable)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isSystem.equals(false))) // Protect system categories
        .go();
  }
}
