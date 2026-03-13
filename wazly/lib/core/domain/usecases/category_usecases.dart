import 'package:wazly/core/data/local/repositories/drift_category_repository.dart';
import 'package:wazly/core/domain/entities/category_entity.dart';

class CategoryUseCases {
  final DriftCategoryRepository repository;

  CategoryUseCases(this.repository);

  Stream<List<CategoryEntity>> watchCategories(int type) {
    return repository.watchCategories(type).map((list) {
      return list
          .map(
            (c) => CategoryEntity(
              id: c.id,
              name: c.name,
              iconCode: c.iconCode,
              colorValue: c.colorValue,
              type: c.type,
              isSystem: c.isSystem,
            ),
          )
          .toList();
    });
  }

  Future<void> addCategory(CategoryEntity category) async {
    await repository.addCategory(
      id: category.id,
      name: category.name,
      iconCode: category.iconCode,
      colorValue: category.colorValue,
      type: category.type,
    );
  }

  Future<void> updateCategory(CategoryEntity category) async {
    await repository.updateCategory(
      id: category.id,
      name: category.name,
      iconCode: category.iconCode,
      colorValue: category.colorValue,
    );
  }

  Future<void> deleteCategory(String id) async {
    await repository.deleteCategory(id);
  }
}
