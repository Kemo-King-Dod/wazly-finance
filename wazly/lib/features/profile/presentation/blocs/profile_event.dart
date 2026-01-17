import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

/// Profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load profile event
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Update profile event
class UpdateProfile extends ProfileEvent {
  final ProfileEntity profile;

  const UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}
