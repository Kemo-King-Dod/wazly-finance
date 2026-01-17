// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/account_entity.dart';

part 'account_model.g.dart';

@HiveType(typeId: 1)
class AccountModel extends AccountEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String phone;

  const AccountModel({required this.id, required this.name, this.phone = ''})
    : super(id: id, name: name, phone: phone);

  /// Create an AccountModel from an AccountEntity
  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(id: entity.id, name: entity.name, phone: entity.phone);
  }

  /// Create an AccountModel from JSON
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: (json['phone'] as String?) ?? '',
    );
  }

  /// Convert AccountModel to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone};
  }

  /// Convert to AccountEntity
  AccountEntity toEntity() {
    return AccountEntity(id: id, name: name, phone: phone);
  }

  /// Create a copy with modified fields
  AccountModel copyWith({String? id, String? name, String? phone}) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}
