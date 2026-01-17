import 'package:equatable/equatable.dart';

/// User profile entity
class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicture; // Path to local image
  final String currency; // Default currency (e.g., 'LYD', 'USD')
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicture,
    this.currency = 'LYD',
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePicture,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    profilePicture,
    currency,
    createdAt,
    updatedAt,
  ];
}
