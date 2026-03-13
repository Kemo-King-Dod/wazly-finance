import 'package:equatable/equatable.dart';
import 'package:wazly/core/domain/entities/category_entity.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoriesEvent {
  final int type;

  const LoadCategoriesEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class AddCategoryEvent extends CategoriesEvent {
  final CategoryEntity category;

  const AddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends CategoriesEvent {
  final CategoryEntity category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoriesEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}
