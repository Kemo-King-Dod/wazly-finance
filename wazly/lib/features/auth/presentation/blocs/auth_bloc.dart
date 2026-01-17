import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_auth_status_usecase.dart';
import '../../domain/usecases/increment_launch_count_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStatusUseCase getAuthStatusUseCase;
  final IncrementLaunchCountUseCase incrementLaunchCountUseCase;

  AuthBloc({
    required this.getAuthStatusUseCase,
    required this.incrementLaunchCountUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ContinueWithoutSignIn>(_onContinueWithoutSignIn);
    on<SignInWithGoogle>(_onSignInWithGoogle);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Increment launch count
      await incrementLaunchCountUseCase();

      // Get auth status
      final authStatus = await getAuthStatusUseCase();

      if (authStatus.shouldShowWelcome) {
        emit(AuthWelcomeRequired(authStatus));
      } else {
        emit(const AuthAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onContinueWithoutSignIn(
    ContinueWithoutSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAuthenticated());
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Implement Google Sign-in
    // For now, just continue without sign-in
    emit(const AuthAuthenticated());
  }
}
