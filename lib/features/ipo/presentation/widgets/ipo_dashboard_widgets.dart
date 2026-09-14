import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/ipo_application_entity.dart';
import '../../domain/entities/ipo_pool_summary.dart';
import '../../domain/entities/ipo_profile_entity.dart';
import '../../domain/entities/ipo_trade_entity.dart';

/// Recycling Velocity Meter showing capital efficiency and turnover
class RecyclingVelocityMeterWidget extends StatelessWidget {
  final IpoPoolSummary summary;

  const RecyclingVelocityMeterWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E232B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF333B47) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final velocity = summary.recyclingVelocityRatio;
    final basePoolFormatted = AppFormatters.formatCurrency(
      summary.activeWorkingPool > 0 ? summary.activeWorkingPool : summary.injectedCapital,
    );
    final executedFormatted = AppFormatters.formatCurrency(summary.totalBidsExecuted);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.autorenew_rounded,
                      size: 18,
                      color: Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'RECYCLING VELOCITY METER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: subColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: velocity >= 1.5
                      ? const Color(0xFF059669).withValues(alpha: 0.15)
                      : const Color(0xFF0284C7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: velocity >= 1.5
                        ? const Color(0xFF10B981)
                        : const Color(0xFF38BDF8),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${velocity.toStringAsFixed(2)}x Velocity',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: velocity >= 1.5
                        ? const Color(0xFF10B981)
                        : const Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$basePoolFormatted pool executed $executedFormatted across ${summary.totalBidsCount} bids',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (velocity / 5.0).clamp(0.05, 1.0),
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF2E3846) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                velocity >= 2.0
                    ? const Color(0xFF10B981) // High velocity green
                    : velocity >= 1.0
                        ? const Color(0xFF38BDF8) // Good velocity blue
                        : const Color(0xFFF59E0B), // Moderate velocity amber
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${summary.activeBidsCount} active ASBA bids currently frozen',
                  style: TextStyle(fontSize: 11, color: subColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Target: 3.0x turnover',
                style: TextStyle(fontSize: 11, color: subColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Working Capital Matrix Display
class WorkingCapitalMatrixWidget extends StatelessWidget {
  final IpoPoolSummary summary;
  final VoidCallback onAddCapital;

  const WorkingCapitalMatrixWidget({
    super.key,
    required this.summary,
    required this.onAddCapital,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE WORKING POOL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: subColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatCurrency(summary.activeWorkingPool),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onAddCapital,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('CAPITAL'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3-Way Pool State Breakdown
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  title: 'Available to Bid',
                  amount: summary.availableToBid,
                  indicatorColor: const Color(0xFF10B981), // Emerald
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  title: 'Frozen in ASBA',
                  amount: summary.frozenInBids,
                  indicatorColor: const Color(0xFFF59E0B), // Amber
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  title: 'Invested (Allotted)',
                  amount: summary.investedInAllotted,
                  indicatorColor: const Color(0xFF3B82F6), // Blue
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Working Capital Reconciliation Ledger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ReconciliationItem(
                label: 'Injected',
                amount: summary.injectedCapital,
                isDark: isDark,
              ),
              _ReconciliationItem(
                label: 'Repatriated',
                amount: summary.repatriatedCapital,
                isDark: isDark,
              ),
              _ReconciliationItem(
                label: 'Parent Retentions',
                amount: summary.parentRetentions,
                isAlert: summary.parentRetentions > 0,
                isDark: isDark,
              ),
              _ReconciliationItem(
                label: 'Realized Gains',
                amount: summary.realizedProfits,
                isDark: isDark,
                isPositiveProfit: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final double amount;
  final Color indicatorColor;
  final bool isDark;

  const _MetricTile({
    required this.title,
    required this.amount,
    required this.indicatorColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC);
    final border = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.formatCurrency(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReconciliationItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isAlert;
  final bool isPositiveProfit;
  final bool isDark;

  const _ReconciliationItem({
    required this.label,
    required this.amount,
    this.isAlert = false,
    this.isPositiveProfit = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isAlert
                ? const Color(0xFFF59E0B)
                : (isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
            fontWeight: isAlert ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${isPositiveProfit && amount > 0 ? '+' : ''}${AppFormatters.formatCurrency(amount)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPositiveProfit && amount > 0
                ? const Color(0xFF10B981)
                : (isDark ? const Color(0xFFC9D1D9) : const Color(0xFF334155)),
          ),
        ),
      ],
    );
  }
}

/// Single ASBA Bid Card
class IpoBidCard extends StatelessWidget {
  final IpoApplicationEntity application;
  final IpoProfileEntity? profile;
  final IpoTradeEntity? trade;
  final VoidCallback onUnblock;
  final VoidCallback onAllot;
  final VoidCallback? onSell;

  const IpoBidCard({
    super.key,
    required this.application,
    this.profile,
    this.trade,
    required this.onUnblock,
    required this.onAllot,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final status = application.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.ipoName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile?.name ?? "Profile"} • ${application.sharesApplied} Shares Applied',
                      style: TextStyle(fontSize: 12, color: subColor),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bid Amount',
                    style: TextStyle(fontSize: 11, color: subColor),
                  ),
                  Text(
                    AppFormatters.formatCurrency(application.bidAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                AppFormatters.formatDate(application.appliedAt),
                style: TextStyle(fontSize: 12, color: subColor),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons according to state
          if (status == IpoApplicationStatus.held) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onUnblock,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('UNBLOCK / REFUND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAllot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669), // Emerald
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text('ALLOT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ] else if (status == IpoApplicationStatus.allotted) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Debited: ${AppFormatters.formatCurrency(trade?.debitAmount ?? application.bidAmount)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSell,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFF1E3A8A), // Navy
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ),
                  child: const Text('SELL / EXIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ] else if (status == IpoApplicationStatus.unblocked) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'Hold released • Recycled back to pool (0 ledger entries)',
                    style: TextStyle(fontSize: 11, color: subColor),
                  ),
                ],
              ),
            ),
          ] else if (status == IpoApplicationStatus.sold) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    'Realized Gain: +${AppFormatters.formatCurrency(trade?.netProfit ?? 0)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(IpoApplicationStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case IpoApplicationStatus.held:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        text = const Color(0xFFF59E0B);
        label = 'HELD / ASBA';
        break;
      case IpoApplicationStatus.unblocked:
        bg = const Color(0xFF64748B).withValues(alpha: 0.15);
        text = const Color(0xFF94A3B8);
        label = 'UNBLOCKED';
        break;
      case IpoApplicationStatus.allotted:
        bg = const Color(0xFF3B82F6).withValues(alpha: 0.15);
        text = const Color(0xFF3B82F6);
        label = 'ALLOTTED';
        break;
      case IpoApplicationStatus.sold:
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        text = const Color(0xFF10B981);
        label = 'SOLD';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: text,
        ),
      ),
    );
  }
}
