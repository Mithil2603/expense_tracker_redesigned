import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import '../core/network/network_info.dart';

/// Global Service Locator instance
final sl = GetIt.instance;

/// Initialize and register all global dependencies
Future<void> init() async {
  // ─── External Services ─────────────────────────────────────────────────────
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ─── Core / Network ────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
