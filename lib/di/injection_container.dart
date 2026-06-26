import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/core.dart';
import '../core/services/notification_sync_service.dart';
import '../core/services/entitlement/entitlement_service.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/sign_in_with_email.dart';
import '../features/auth/domain/usecases/sign_up_with_email.dart';
import '../features/auth/domain/usecases/sign_in_with_google.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/domain/usecases/auto_login.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

import '../features/expenses/data/datasources/transaction_remote_data_source.dart';
import '../features/expenses/data/repositories/transaction_repository_impl.dart';
import '../features/expenses/domain/repositories/transaction_repository.dart';
import '../features/expenses/domain/usecases/watch_transactions.dart';
import '../features/expenses/domain/usecases/add_transaction.dart';
import '../features/expenses/domain/usecases/update_transaction.dart';
import '../features/expenses/domain/usecases/delete_transaction.dart';
import '../features/expenses/presentation/bloc/transaction_bloc.dart';

/// Global Service Locator instance
final sl = GetIt.instance;

/// Initialize and register all global dependencies
Future<void> init() async {
  // ─── External Services & SDKs ──────────────────────────────────────────────
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ─── Core / Network / Background Services ──────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<FingoState>(() => FingoState.instance);
  sl.registerLazySingleton<AuthNotifier>(() => AuthNotifier());
  sl.registerLazySingleton<NotificationSyncService>(() => NotificationSyncService());
  sl.registerLazySingleton<EntitlementService>(() => EntitlementServiceImpl());

  // ─── Authentication Feature (Clean Architecture) ───────────────────────────
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      networkInfo: sl(),
      secureStorage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => AutoLogin(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
      autoLogin: sl(),
    ),
  );

  // ─── Expenses/Transaction Feature (Clean Architecture) ─────────────────────
  // Data Source
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => WatchTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // BLoC
  sl.registerFactory(
    () => TransactionBloc(
      watchTransactions: sl(),
      addTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );
}
