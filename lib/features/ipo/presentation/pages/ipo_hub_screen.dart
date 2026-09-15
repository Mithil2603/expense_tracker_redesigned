import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/capital_allocation_entity.dart';
import '../../domain/entities/ipo_application_entity.dart';
import '../../domain/entities/ipo_profile_entity.dart';
import '../../domain/entities/ipo_trade_entity.dart';
import '../bloc/ipo_hub_bloc.dart';
import '../bloc/ipo_hub_event.dart';
import '../bloc/ipo_hub_state.dart';
import '../widgets/ipo_action_sheets.dart';
import '../widgets/ipo_dashboard_widgets.dart';

class IpoHubScreen extends StatefulWidget {
  final String userId;

  const IpoHubScreen({super.key, required this.userId});

  @override
  State<IpoHubScreen> createState() => _IpoHubScreenState();
}

class _IpoHubScreenState extends State<IpoHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IpoHubBloc>(
      create: (_) => sl<IpoHubBloc>()..add(LoadIpoHubEvent(widget.userId)),
      child: BlocConsumer<IpoHubBloc, IpoHubState>(
        listener: (context, state) {
          if (state is IpoHubLoaded) {
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: const Color(0xFF0F766E),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final scaffoldBg = isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9);
          final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF090D16) : Colors.white,
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(
                'IPO capital hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF3B82F6),
                    unselectedLabelColor: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF3B82F6),
                    indicatorWeight: 2.0,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: 'Pool and bids'),
                      Tab(text: 'Allocations'),
                      Tab(text: 'History'),
                    ],
                  ),
                ),
              ),
            ),
            body: state is IpoHubLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    ),
                  )
                : state is IpoHubError
                    ? Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Color(0xFFEF4444)),
                        ),
                      )
                    : state is IpoHubLoaded
                        ? _buildLoadedBody(context, state, isDark)
                        : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, IpoHubLoaded state, bool isDark) {
    return Column(
      children: [
        // Top 3-Profile Switcher
        _buildProfileSwitcher(context, state, isDark),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. Overview & Active Bids
              _buildOverviewTab(context, state, isDark),

              // 2. Capital Allocations Breakdown
              _buildAllocationsTab(context, state, isDark),

              // 3. Trade & Application History
              _buildHistoryTab(context, state, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSwitcher(BuildContext context, IpoHubLoaded state, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ProfileChip(
              title: 'All profiles',
              isSelected: state.selectedProfileId == null,
              onTap: () {
                context.read<IpoHubBloc>().add(const SelectProfileEvent(null));
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            ...state.profiles.map((p) {
              final isSelected = state.selectedProfileId == p.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ProfileChip(
                  title: p.name,
                  isSelected: isSelected,
                  onTap: () {
                    context.read<IpoHubBloc>().add(SelectProfileEvent(p.id));
                  },
                  isDark: isDark,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, IpoHubLoaded state, bool isDark) {
    final activeBids = state.filteredApplications
        .where((app) => app.status == IpoApplicationStatus.held || app.status == IpoApplicationStatus.allotted)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<IpoHubBloc>().add(LoadIpoHubEvent(widget.userId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Working Capital Matrix
          WorkingCapitalMatrixWidget(
            summary: state.summary,
            onAddCapital: () => _showAddCapitalSheet(context, state),
          ),
          const SizedBox(height: 16),

          // Recycling Velocity Meter
          RecyclingVelocityMeterWidget(summary: state.summary),
          const SizedBox(height: 16),

          // Action Buttons Bar
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateBidSheet(context, state),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Apply ASBA bid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddCapitalSheet(context, state),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Inject / return'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Bids Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE BIDS AND ALLOTMENTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
                ),
              ),
              Text(
                '${activeBids.length} active',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (activeBids.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 36,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active ASBA bids',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Apply ASBA bid" to block funds and begin recycling.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...activeBids.map((app) {
              final profile = state.profiles.cast<IpoProfileEntity?>().firstWhere(
                    (p) => p?.id == app.profileId,
                    orElse: () => null,
                  );
              final trade = state.allTrades.cast<IpoTradeEntity?>().firstWhere(
                    (t) => t?.applicationId == app.id,
                    orElse: () => null,
                  );

              return IpoBidCard(
                application: app,
                profile: profile,
                trade: trade,
                onUnblock: () => _confirmUnblock(context, app),
                onAllot: () => _showAllotmentDialog(context, app),
                onSell: trade != null ? () => _showSellDialog(context, app, trade) : null,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAllocationsTab(BuildContext context, IpoHubLoaded state, bool isDark) {
    final allocations = state.filteredAllocations;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'WORKING CAPITAL ALLOCATION LEDGER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: subColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showAddCapitalSheet(context, state),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (allocations.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              'No capital transfers recorded for this profile.',
              style: TextStyle(color: subColor, fontSize: 13),
            ),
          )
        else
          ...allocations.map((alloc) {
            final profile = state.profiles.cast<IpoProfileEntity?>().firstWhere(
                  (p) => p?.id == alloc.profileId,
                  orElse: () => null,
                );

            Color typeColor;
            IconData typeIcon;
            switch (alloc.type) {
              case AllocationType.fundInjection:
                typeColor = const Color(0xFF059669);
                typeIcon = Icons.arrow_downward_rounded;
                break;
              case AllocationType.repatriation:
                typeColor = const Color(0xFF3B82F6);
                typeIcon = Icons.arrow_upward_rounded;
                break;
              case AllocationType.parentRetention:
                typeColor = const Color(0xFFF59E0B);
                typeIcon = Icons.remove_circle_outline_rounded;
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, size: 18, color: typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              alloc.type.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(alloc.amount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${profile?.name ?? "Profile"} • ${AppFormatters.formatDate(alloc.date)}',
                              style: TextStyle(fontSize: 11, color: subColor),
                            ),
                            if (alloc.notes.isNotEmpty)
                              Flexible(
                                child: Text(
                                  alloc.notes,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF475569),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    onPressed: () {
                      context.read<IpoHubBloc>().add(
                            DeleteAllocationEvent(
                              userId: widget.userId,
                              allocationId: alloc.id,
                            ),
                          );
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context, IpoHubLoaded state, bool isDark) {
    final applications = state.filteredApplications;
    final subColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'ALL APPLICATIONS & TRADES (${applications.length})',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: subColor,
          ),
        ),
        const SizedBox(height: 12),
        if (applications.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No applications recorded yet.',
                style: TextStyle(color: subColor),
              ),
            ),
          )
        else
          ...applications.map((app) {
            final profile = state.profiles.cast<IpoProfileEntity?>().firstWhere(
                  (p) => p?.id == app.profileId,
                  orElse: () => null,
                );
            final trade = state.allTrades.cast<IpoTradeEntity?>().firstWhere(
                  (t) => t?.applicationId == app.id,
                  orElse: () => null,
                );

            return IpoBidCard(
              application: app,
              profile: profile,
              trade: trade,
              onUnblock: () => _confirmUnblock(context, app),
              onAllot: () => _showAllotmentDialog(context, app),
              onSell: trade != null ? () => _showSellDialog(context, app, trade) : null,
            );
          }),
      ],
    );
  }

  void _showCreateBidSheet(BuildContext context, IpoHubLoaded state) {
    final bloc = context.read<IpoHubBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CreateBidSheet(
          profiles: state.profiles,
          selectedProfileId: state.selectedProfileId,
          availableBalance: state.summary.availableToBid,
          onSubmit: ({
            required String profileId,
            required String ipoName,
            required double bidAmount,
            required int sharesApplied,
          }) {
            bloc.add(
              SubmitBidEvent(
                userId: widget.userId,
                profileId: profileId,
                ipoName: ipoName,
                bidAmount: bidAmount,
                sharesApplied: sharesApplied,
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCapitalSheet(BuildContext context, IpoHubLoaded state) {
    final bloc = context.read<IpoHubBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CapitalAllocationSheet(
          profiles: state.profiles,
          selectedProfileId: state.selectedProfileId,
          onSubmit: ({
            required String profileId,
            required AllocationType type,
            required double amount,
            required String notes,
          }) {
            bloc.add(
              AddAllocationEvent(
                userId: widget.userId,
                profileId: profileId,
                type: type,
                amount: amount,
                notes: notes,
              ),
            );
          },
        );
      },
    );
  }

  void _confirmUnblock(BuildContext context, IpoApplicationEntity app) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          title: const Text('Unblock / Refund ASBA Hold?'),
          content: Text(
            'This releases ₹${app.bidAmount.toStringAsFixed(0)} back to the Available pool for recycling. Zero expense entries will touch your ledger.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.read<IpoHubBloc>().add(
                      UnblockBidEvent(
                        userId: widget.userId,
                        applicationId: app.id,
                      ),
                    );
              },
              child: const Text('UNBLOCK HOLD'),
            ),
          ],
        );
      },
    );
  }

  void _showAllotmentDialog(BuildContext context, IpoApplicationEntity app) {
    final bloc = context.read<IpoHubBloc>();
    showDialog(
      context: context,
      builder: (_) {
        return AllotmentConfirmDialog(
          application: app,
          onConfirm: (allottedShares, debitAmount) {
            bloc.add(
              AllotBidEvent(
                userId: widget.userId,
                applicationId: app.id,
                allottedShares: allottedShares,
                debitAmount: debitAmount,
              ),
            );
          },
        );
      },
    );
  }

  void _showSellDialog(BuildContext context, IpoApplicationEntity app, IpoTradeEntity trade) {
    final bloc = context.read<IpoHubBloc>();
    showDialog(
      context: context,
      builder: (_) {
        return SellExecutionDialog(
          application: app,
          trade: trade,
          onConfirm: ({
            required double sellPricePerShare,
            required double grossProceeds,
            required double netProfit,
          }) {
            bloc.add(
              SellTradeEvent(
                userId: widget.userId,
                tradeId: trade.id,
                sellPricePerShare: sellPricePerShare,
                grossProceeds: grossProceeds,
                netProfit: netProfit,
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ProfileChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? (isDark ? const Color(0xFF0F1E36) : const Color(0xFFE0F2FE))
        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9));
    final borderColor = isSelected
        ? const Color(0xFF3B82F6)
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
    final textColor = isSelected
        ? (isDark ? Colors.white : const Color(0xFF0284C7))
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
