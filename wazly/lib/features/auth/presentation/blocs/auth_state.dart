import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_status.dart';

/// Auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Welcome screen required
class AuthWelcomeRequired extends AuthState {
  final AuthStatus authStatus;

  const AuthWelcomeRequired(this.authStatus);

  @override
  List<Object?> get props => [authStatus];
}

/// User authenticated (or continuing without auth)
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
