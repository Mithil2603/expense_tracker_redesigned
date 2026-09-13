import 'package:flutter_test/flutter_test.dart';
import 'package:fingo/features/ipo/domain/entities/capital_allocation_entity.dart';
import 'package:fingo/features/ipo/domain/entities/ipo_application_entity.dart';
import 'package:fingo/features/ipo/domain/entities/ipo_pool_summary.dart';
import 'package:fingo/features/ipo/domain/entities/ipo_trade_entity.dart';

void main() {
  group('IPO Working Capital & Velocity Calculations', () {
    test('Calculates active pool, recycling velocity, and available funds accurately', () {
      final now = DateTime.now();

      // Father profile: ₹75,000 injected
      final allocations = [
        CapitalAllocationEntity(
          id: 'a1',
          profileId: 'father',
          type: AllocationType.fundInjection,
          amount: 75000.0,
          date: now,
        ),
      ];

      // 7 IPO applications totaling ₹1,05,000
      // 6 unblocked (recycled), 1 currently held (₹15,000)
      final applications = [
        IpoApplicationEntity(
          id: 'app1',
          profileId: 'father',
          ipoName: 'IPO 1',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.unblocked,
          appliedAt: now.subtract(const Duration(days: 20)),
          unblockedAt: now.subtract(const Duration(days: 15)),
        ),
        IpoApplicationEntity(
          id: 'app2',
          profileId: 'father',
          ipoName: 'IPO 2',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.unblocked,
          appliedAt: now.subtract(const Duration(days: 18)),
          unblockedAt: now.subtract(const Duration(days: 13)),
        ),
        IpoApplicationEntity(
          id: 'app3',
          profileId: 'father',
          ipoName: 'IPO 3',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.unblocked,
          appliedAt: now.subtract(const Duration(days: 16)),
          unblockedAt: now.subtract(const Duration(days: 11)),
        ),
        IpoApplicationEntity(
          id: 'app4',
          profileId: 'father',
          ipoName: 'IPO 4',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.unblocked,
          appliedAt: now.subtract(const Duration(days: 14)),
          unblockedAt: now.subtract(const Duration(days: 9)),
        ),
        IpoApplicationEntity(
          id: 'app5',
          profileId: 'father',
          ipoName: 'IPO 5',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.unblocked,
          appliedAt: now.subtract(const Duration(days: 12)),
          unblockedAt: now.subtract(const Duration(days: 7)),
        ),
        IpoApplicationEntity(
          id: 'app6',
          profileId: 'father',
          ipoName: 'IPO 6',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.unblocked,
          appliedAt: now.subtract(const Duration(days: 10)),
          unblockedAt: now.subtract(const Duration(days: 5)),
        ),
        IpoApplicationEntity(
          id: 'app7',
          profileId: 'father',
          ipoName: 'IPO 7 (Current Active Bid)',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.held,
          appliedAt: now.subtract(const Duration(days: 2)),
        ),
      ];

      final summary = IpoPoolSummary.fromData(
        allocations: allocations,
        applications: applications,
        trades: [],
      );

      // Active working pool must be ₹75,000
      expect(summary.activeWorkingPool, equals(75000.0));
      expect(summary.injectedCapital, equals(75000.0));
      expect(summary.repatriatedCapital, equals(0.0));
      expect(summary.parentRetentions, equals(0.0));

      // Frozen must only be the currently HELD bid (₹15,000)
      expect(summary.frozenInBids, equals(15000.0));

      // Available to Bid = 75,000 - 15,000 = 60,000
      expect(summary.availableToBid, equals(60000.0));

      // Total Bids Executed = 7 * 15,000 = ₹1,05,000
      expect(summary.totalBidsExecuted, equals(105000.0));
      expect(summary.totalBidsCount, equals(7));
      expect(summary.activeBidsCount, equals(1));

      // Velocity ratio = 105,000 / 75,000 = 1.40x
      expect(summary.recyclingVelocityRatio, closeTo(1.40, 0.001));
    });

    test('Explicit parent retentions reduce active pool without unaccounted leakage', () {
      final now = DateTime.now();

      final allocations = [
        // Injected ₹50,000 to Mother
        CapitalAllocationEntity(
          id: 'm1',
          profileId: 'mother',
          type: AllocationType.fundInjection,
          amount: 50000.0,
          date: now,
        ),
        // Repatriated ₹20,000 back to Self
        CapitalAllocationEntity(
          id: 'm2',
          profileId: 'mother',
          type: AllocationType.repatriation,
          amount: 20000.0,
          date: now,
        ),
        // Mother kept ₹6,000 for household use
        CapitalAllocationEntity(
          id: 'm3',
          profileId: 'mother',
          type: AllocationType.parentRetention,
          amount: 6000.0,
          date: now,
          notes: 'Retained for household groceries',
        ),
        // Dad/Mom rounding off difference ₹32
        CapitalAllocationEntity(
          id: 'm4',
          profileId: 'mother',
          type: AllocationType.parentRetention,
          amount: 32.0,
          date: now,
          notes: 'Rounding off difference',
        ),
      ];

      final summary = IpoPoolSummary.fromData(
        allocations: allocations,
        applications: [],
        trades: [],
      );

      // Injected: 50,000
      expect(summary.injectedCapital, equals(50000.0));
      // Repatriated: 20,000
      expect(summary.repatriatedCapital, equals(20000.0));
      // Parent Retentions: 6,032
      expect(summary.parentRetentions, equals(6032.0));
      // Active Pool = 50,000 - 20,000 - 6,032 = 23,968
      expect(summary.activeWorkingPool, equals(23968.0));
      expect(summary.availableToBid, equals(23968.0));
    });

    test('Allotted and Sold trades update invested and realized profit correctly', () {
      final now = DateTime.now();

      final allocations = [
        CapitalAllocationEntity(
          id: 's1',
          profileId: 'self',
          type: AllocationType.fundInjection,
          amount: 100000.0,
          date: now,
        ),
      ];

      final applications = [
        IpoApplicationEntity(
          id: 'app_allotted',
          profileId: 'self',
          ipoName: 'Tech IPO',
          bidAmount: 14500.0,
          sharesApplied: 25,
          status: IpoApplicationStatus.allotted,
          appliedAt: now.subtract(const Duration(days: 10)),
          allotmentDate: now.subtract(const Duration(days: 3)),
        ),
        IpoApplicationEntity(
          id: 'app_sold',
          profileId: 'self',
          ipoName: 'Green IPO',
          bidAmount: 15000.0,
          sharesApplied: 30,
          status: IpoApplicationStatus.sold,
          appliedAt: now.subtract(const Duration(days: 20)),
          allotmentDate: now.subtract(const Duration(days: 15)),
        ),
      ];

      final trades = [
        // Tech IPO is still holding (allotted, unsold)
        const IpoTradeEntity(
          id: 'trade_1',
          applicationId: 'app_allotted',
          profileId: 'self',
          allottedShares: 25,
          debitAmount: 14500.0,
        ),
        // Green IPO was sold with profit
        const IpoTradeEntity(
          id: 'trade_2',
          applicationId: 'app_sold',
          profileId: 'self',
          allottedShares: 30,
          debitAmount: 15000.0,
          sellPricePerShare: 900.0,
          grossProceeds: 27000.0,
          netProfit: 12000.0,
          soldAt: null, // marked via soldAt in test
        ).copyWith(soldAt: now.subtract(const Duration(days: 5))),
      ];

      final summary = IpoPoolSummary.fromData(
        allocations: allocations,
        applications: applications,
        trades: trades,
      );

      // Active Pool = 100,000
      expect(summary.activeWorkingPool, equals(100000.0));
      // Invested in unsold = 14,500
      expect(summary.investedInAllotted, equals(14500.0));
      // Frozen in bids = 0 (none in HELD)
      expect(summary.frozenInBids, equals(0.0));
      // Available to Bid = 100,000 - 14,500 = 85,500
      expect(summary.availableToBid, equals(85500.0));
      // Realized profit from sold trade = 12,000
      expect(summary.realizedProfits, equals(12000.0));
    });
  });
}
