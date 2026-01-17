import 'package:equatable/equatable.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Continue without sign-in
class ContinueWithoutSignIn extends AuthEvent {
  const ContinueWithoutSignIn();
}

/// Sign in with Google (placeholder)
class SignInWithGoogle extends AuthEvent {
  const SignInWithGoogle();
}
