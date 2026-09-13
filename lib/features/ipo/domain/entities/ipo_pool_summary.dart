import 'package:equatable/equatable.dart';
import 'capital_allocation_entity.dart';
import 'ipo_application_entity.dart';
import 'ipo_trade_entity.dart';

class IpoPoolSummary extends Equatable {
  final double injectedCapital;
  final double repatriatedCapital;
  final double parentRetentions;
  final double activeWorkingPool;
  final double frozenInBids;
  final double investedInAllotted;
  final double availableToBid;
  final double totalBidsExecuted;
  final int totalBidsCount;
  final int activeBidsCount;
  final double recyclingVelocityRatio;
  final double realizedProfits;

  const IpoPoolSummary({
    required this.injectedCapital,
    required this.repatriatedCapital,
    required this.parentRetentions,
    required this.activeWorkingPool,
    required this.frozenInBids,
    required this.investedInAllotted,
    required this.availableToBid,
    required this.totalBidsExecuted,
    required this.totalBidsCount,
    required this.activeBidsCount,
    required this.recyclingVelocityRatio,
    required this.realizedProfits,
  });

  factory IpoPoolSummary.fromData({
    required List<CapitalAllocationEntity> allocations,
    required List<IpoApplicationEntity> applications,
    required List<IpoTradeEntity> trades,
  }) {
    double injected = 0.0;
    double repatriated = 0.0;
    double retentions = 0.0;

    for (final alloc in allocations) {
      switch (alloc.type) {
        case AllocationType.fundInjection:
          injected += alloc.amount;
          break;
        case AllocationType.repatriation:
          repatriated += alloc.amount;
          break;
        case AllocationType.parentRetention:
          retentions += alloc.amount;
          break;
      }
    }

    final activePool = injected - repatriated - retentions;

    double frozen = 0.0;
    int activeBids = 0;
    double totalExecuted = 0.0;

    for (final app in applications) {
      totalExecuted += app.bidAmount;
      if (app.status == IpoApplicationStatus.held) {
        frozen += app.bidAmount;
        activeBids++;
      }
    }

    double invested = 0.0;
    double profits = 0.0;

    for (final trade in trades) {
      if (trade.soldAt == null) {
        invested += trade.debitAmount;
      } else {
        profits += (trade.netProfit ?? 0.0);
      }
    }

    final available = activePool - frozen - invested;

    // Velocity ratio = Total Bids Executed / Base Pool
    final basePool = activePool > 0 ? activePool : (injected > 0 ? injected : 1.0);
    final velocityRatio = basePool > 0 ? (totalExecuted / basePool) : 0.0;

    return IpoPoolSummary(
      injectedCapital: injected,
      repatriatedCapital: repatriated,
      parentRetentions: retentions,
      activeWorkingPool: activePool,
      frozenInBids: frozen,
      investedInAllotted: invested,
      availableToBid: available < 0 ? 0.0 : available,
      totalBidsExecuted: totalExecuted,
      totalBidsCount: applications.length,
      activeBidsCount: activeBids,
      recyclingVelocityRatio: velocityRatio,
      realizedProfits: profits,
    );
  }

  static const IpoPoolSummary empty = IpoPoolSummary(
    injectedCapital: 0,
    repatriatedCapital: 0,
    parentRetentions: 0,
    activeWorkingPool: 0,
    frozenInBids: 0,
    investedInAllotted: 0,
    availableToBid: 0,
    totalBidsExecuted: 0,
    totalBidsCount: 0,
    activeBidsCount: 0,
    recyclingVelocityRatio: 0,
    realizedProfits: 0,
  );

  @override
  List<Object?> get props => [
        injectedCapital,
        repatriatedCapital,
        parentRetentions,
        activeWorkingPool,
        frozenInBids,
        investedInAllotted,
        availableToBid,
        totalBidsExecuted,
        totalBidsCount,
        activeBidsCount,
        recyclingVelocityRatio,
        realizedProfits,
      ];
}
