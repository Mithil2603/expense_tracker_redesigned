import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// [AuthBloc] — manages state transitions for user sign-in, sign-up, and sign-out actions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<SignInWithEmailEvent>((event, emit) async {
      emit(const AuthLoading(isGoogle: false));
      final result = await signInWithEmail(event.email, event.password);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    on<SignUpWithEmailEvent>((event, emit) async {
      emit(const AuthLoading(isGoogle: false));
      final result = await signUpWithEmail(event.email, event.password, event.name);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    on<SignInWithGoogleEvent>((event, emit) async {
      emit(const AuthLoading(isGoogle: true));
      final result = await signInWithGoogle();
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    on<SignOutEvent>((event, emit) async {
      emit(const AuthLoading(isGoogle: false));
      final result = await signOut();
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(Unauthenticated()),
      );
    });
  }
}
