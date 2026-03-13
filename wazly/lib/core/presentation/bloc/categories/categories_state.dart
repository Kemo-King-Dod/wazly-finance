import 'package:equatable/equatable.dart';
import 'package:wazly/core/domain/entities/category_entity.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  final int type; // The type currently loaded

  const CategoriesLoaded({required this.categories, required this.type});

  @override
  List<Object?> get props => [categories, type];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
