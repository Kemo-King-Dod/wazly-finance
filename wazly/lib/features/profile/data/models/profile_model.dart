import 'package:hive/hive.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 4) // Using typeId 4 for ProfileModel
class ProfileModel extends ProfileEntity {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  final String email;

  @override
  @HiveField(3)
  final String phone;

  @override
  @HiveField(4)
  final String? profilePicture;

  @override
  @HiveField(5)
  final String currency;

  @override
  @HiveField(6)
  final DateTime createdAt;

  @override
  @HiveField(7)
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicture,
    this.currency = 'LYD',
    required this.createdAt,
    required this.updatedAt,
  }) : super(
         id: id,
         name: name,
         email: email,
         phone: phone,
         profilePicture: profilePicture,
         currency: currency,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Convert from entity to model
  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      profilePicture: entity.profilePicture,
      currency: entity.currency,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profilePicture: profilePicture,
      currency: currency,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create default profile
  factory ProfileModel.defaultProfile() {
    final now = DateTime.now();
    return ProfileModel(
      id: 'default',
      name: 'User',
      email: '',
      phone: '',
      currency: 'LYD',
      createdAt: now,
      updatedAt: now,
    );
  }
}
