import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconCode;
  final int colorValue;
  final int type; // 0 for income, 1 for expense
  final bool isSystem;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    this.isSystem = false,
  });

  @override
  List<Object?> get props => [id, name, iconCode, colorValue, type, isSystem];
}
