import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../core/core.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/sign_in_with_email.dart';
import '../features/auth/domain/usecases/sign_up_with_email.dart';
import '../features/auth/domain/usecases/sign_in_with_google.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

/// Global Service Locator instance
final sl = GetIt.instance;

/// Initialize and register all global dependencies
Future<void> init() async {
  // ─── External Services & SDKs ──────────────────────────────────────────────
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ─── Core / Network ────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<FingoState>(() => FingoState.instance);
  sl.registerLazySingleton<AuthNotifier>(() => AuthNotifier());

  // ─── Authentication Feature (Clean Architecture) ───────────────────────────
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
    ),
  );
}
