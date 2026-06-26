import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../errors/failures.dart';
import '../../utils/logger.dart';
import '../entitlement/models/subscription_plan.dart';

/// Wraps RevenueCat purchases_flutter library.
class SubscriptionRepository {
  // Use a public key for Android/iOS. Hardcoded for demo/setup purposes.
  // In a real app, this should be in an environment variable or config file.
  static const String _revenueCatApiKey = 'goog_dummy_api_key_for_testing';

  Future<void> init(String userId) async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      
      // Configuration for Android (Google Play)
      // Note: In a real app with iOS support, check Platform.isIOS to use the iOS key.
      PurchasesConfiguration configuration = PurchasesConfiguration(_revenueCatApiKey)
        ..appUserID = userId;
      
      await Purchases.configure(configuration);
      AppLogger.i('RevenueCat configured successfully for user: $userId');
    } catch (e) {
      AppLogger.e('Failed to configure RevenueCat: $e');
    }
  }

  /// Fetches the available offerings from RevenueCat
  Future<Either<Failure, List<Package>>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return Right(offerings.current!.availablePackages);
      }
      return const Right([]);
    } catch (e) {
      AppLogger.e('Error fetching RevenueCat offerings: $e');
      return Left(ServerFailure('Failed to fetch packages: $e'));
    }
  }

  /// Purchases a package
  Future<Either<Failure, CustomerInfo>> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return Right(purchaseResult.customerInfo);
    } catch (e) {
      AppLogger.e('Error purchasing package: $e');
      return Left(ServerFailure('Purchase failed: $e'));
    }
  }

  /// Syncs RevenueCat status with our EntitlementService models
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all['premium']?.isActive == true) {
        return SubscriptionStatus.active;
      }
      return SubscriptionStatus.expired;
    } catch (e) {
      AppLogger.e('Failed to get customer info: $e');
      return SubscriptionStatus.expired;
    }
  }
}
