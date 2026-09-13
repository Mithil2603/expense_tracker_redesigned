import '../entities/ipo_profile_entity.dart';
import '../entities/capital_allocation_entity.dart';
import '../entities/ipo_application_entity.dart';
import '../entities/ipo_trade_entity.dart';

abstract class IpoRepository {
  Stream<List<IpoProfileEntity>> watchProfiles(String userId);
  Future<List<IpoProfileEntity>> getProfiles(String userId);
  Future<void> seedDefaultProfilesIfEmpty(String userId);
  Future<void> addProfile(String userId, IpoProfileEntity profile);

  Stream<List<CapitalAllocationEntity>> watchCapitalAllocations(String userId, {String? profileId});
  Future<void> addCapitalAllocation(String userId, CapitalAllocationEntity allocation);
  Future<void> deleteCapitalAllocation(String userId, String allocationId);

  Stream<List<IpoApplicationEntity>> watchApplications(String userId, {String? profileId});
  Future<void> addApplication(String userId, IpoApplicationEntity application);
  Future<void> unblockApplication(String userId, String applicationId);
  Future<void> allotApplication(
    String userId, {
    required String applicationId,
    required int allottedShares,
    required double debitAmount,
  });
  Future<void> sellTrade(
    String userId, {
    required String tradeId,
    required double sellPricePerShare,
    required double grossProceeds,
    required double netProfit,
  });

  Stream<List<IpoTradeEntity>> watchTrades(String userId, {String? profileId});
}
