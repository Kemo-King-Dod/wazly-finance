import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/persons_table.dart';
import 'tables/transactions_table.dart';
import 'tables/treasury_table.dart';
import 'tables/installment_plans_table.dart';
import 'tables/installment_items_table.dart';
import 'tables/categories_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PersonsTable,
    TransactionsTable,
    TreasuryTable,
    InstallmentPlansTable,
    InstallmentItemsTable,
    CategoriesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insert a default treasury row on creation since it's a global singleton table
        await into(treasuryTable).insert(
          TreasuryTableCompanion.insert(
            balanceInCents: const Value(0),
            currency: const Value('LYD'),
          ),
        );
        // Seed default categories
        await _seedDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(categoriesTable);
          await _seedDefaultCategories();
        }
        if (from < 3) {
          await m.addColumn(personsTable, personsTable.nextReminderDate);
          await m.addColumn(personsTable, personsTable.reminderRepeatType);
        }
      },
      beforeOpen: (details) async {
        // Enforce foreign key constraints strictly in SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    final defaultCategories = [
      // Income
      CategoriesTableCompanion.insert(
        id: 'cat_salary',
        name: 'Salary',
        iconCode: 'E227', // attach_money
        colorValue: 0xFF4CAF50, // Green
        type: 0,
        isSystem: const Value(true),
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_business',
        name: 'Business',
        iconCode: 'E8F9', // work
        colorValue: 0xFF2196F3, // Blue
        type: 0,
        isSystem: const Value(true),
      ),
      // Expense
      CategoriesTableCompanion.insert(
        id: 'cat_food',
        name: 'Food & Dining',
        iconCode: 'EA60', // restaurant
        colorValue: 0xFFFF9800, // Orange
        type: 1,
        isSystem: const Value(true),
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_transport',
        name: 'Transportation',
        iconCode: 'E531', // directions_car
        colorValue: 0xFF9C27B0, // Purple
        type: 1,
        isSystem: const Value(true),
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_shopping',
        name: 'Shopping',
        iconCode: 'E8CB', // shopping_cart
        colorValue: 0xFFE91E63, // Pink
        type: 1,
        isSystem: const Value(true),
      ),
      CategoriesTableCompanion.insert(
        id: 'cat_utilities',
        name: 'Utilities',
        iconCode: 'E02A', // lightbulb
        colorValue: 0xFFFFEB3B, // Yellow
        type: 1,
        isSystem: const Value(true),
      ),
    ];

    for (var cat in defaultCategories) {
      await into(categoriesTable).insert(cat, mode: InsertMode.insertOrIgnore);
    }
  }

  Future<void> clearDatabase() async {
    await transaction(() async {
      await delete(transactionsTable).go();
      await delete(personsTable).go();
      await delete(categoriesTable).go();
      await delete(installmentItemsTable).go();
      await delete(installmentPlansTable).go();
      await update(treasuryTable).write(const TreasuryTableCompanion(balanceInCents: Value(0)));
      await _seedDefaultCategories();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wazly_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
