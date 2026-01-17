import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

/// Profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Loaded state
class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Updating state
class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

/// Updated state
class ProfileUpdated extends ProfileState {
  final ProfileEntity profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
