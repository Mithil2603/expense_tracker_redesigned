import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

import '../widgets/date_filter_section.dart';
import '../widgets/summary_cards.dart';
import '../widgets/health_score_card.dart';
import '../widgets/insights_section.dart';
import '../widgets/category_breakdown_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = sl<AuthNotifier>().user?.uid ?? 'test-user-id';

    return BlocProvider<ReportBloc>(
      create: (context) => sl<ReportBloc>()..add(WatchReportTransactions(userId)),
      child: const AnalyticsView(),
    );
  }
}

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  ReportDurationType _selectedDuration = ReportDurationType.monthly;
  
  // Cache current values to feed into date filter updates
  int _selectedMonth = DateTime.now().month;
  int _selectedQuarter = 2; // Default to Q2
  int _selectedYear = DateTime.now().year;
  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _customEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Dispatch default filter on startup
    _triggerFilterUpdate();
  }

  void _triggerFilterUpdate() {
    DateTime start;
    DateTime end;

    switch (_selectedDuration) {
      case ReportDurationType.monthly:
        start = DateTime(_selectedYear, _selectedMonth, 1);
        end = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
        break;
      case ReportDurationType.quarterly:
        if (_selectedQuarter == 1) {
          start = DateTime(_selectedYear, 1, 1);
          end = DateTime(_selectedYear, 3, 31, 23, 59, 59);
        } else if (_selectedQuarter == 2) {
          start = DateTime(_selectedYear, 4, 1);
          end = DateTime(_selectedYear, 6, 30, 23, 59, 59);
        } else if (_selectedQuarter == 3) {
          start = DateTime(_selectedYear, 7, 1);
          end = DateTime(_selectedYear, 9, 30, 23, 59, 59);
        } else {
          start = DateTime(_selectedYear, 10, 1);
          end = DateTime(_selectedYear, 12, 31, 23, 59, 59);
        }
        break;
      case ReportDurationType.yearly:
        start = DateTime(_selectedYear, 1, 1);
        end = DateTime(_selectedYear, 12, 31, 23, 59, 59);
        break;
      case ReportDurationType.custom:
        start = _customStartDate;
        end = _customEndDate;
        break;
    }

    context.read<ReportBloc>().add(ChangeReportFilter(
          durationType: _selectedDuration,
          startDate: start,
          endDate: end,
          selectedMonth: _selectedDuration == ReportDurationType.monthly ? _selectedMonth : null,
          selectedQuarter: _selectedDuration == ReportDurationType.quarterly ? _selectedQuarter : null,
          selectedYear: _selectedYear,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.bgLight : AppColors.bgDark,
      body: SafeArea(
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (state is ReportError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTextStyles.labelMD.copyWith(color: AppColors.error),
                ),
              );
            }

            if (state is ReportLoaded) {
              final report = state.report;
              final intel = state.intelligence;
              final insights = state.insights;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHPadding, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1 & 2. Duration Picker Selector and Sub-controls
                      DateFilterSection(
                        selectedDuration: _selectedDuration,
                        selectedMonth: _selectedMonth,
                        selectedQuarter: _selectedQuarter,
                        selectedYear: _selectedYear,
                        customStartDate: _customStartDate,
                        customEndDate: _customEndDate,
                        onDurationChanged: (type) {
                          setState(() => _selectedDuration = type);
                          _triggerFilterUpdate();
                        },
                        onMonthChanged: (month) {
                          setState(() => _selectedMonth = month);
                          _triggerFilterUpdate();
                        },
                        onQuarterChanged: (quarter) {
                          setState(() => _selectedQuarter = quarter);
                          _triggerFilterUpdate();
                        },
                        onYearChanged: (year) {
                          setState(() => _selectedYear = year);
                          _triggerFilterUpdate();
                        },
                        onCustomDateRangeSelected: (picked) {
                          setState(() {
                            _customStartDate = picked.start;
                            _customEndDate = picked.end;
                          });
                          _triggerFilterUpdate();
                        },
                      ),
                      const SizedBox(height: 20),

                      // 3. Financial Health Score Circular Gauge
                      HealthScoreCard(score: intel.healthScore),
                      const SizedBox(height: 20),

                      // 4. Flat-3D Main Metrics Summary Grid
                      SummaryCards(report: report),
                      const SizedBox(height: 20),

                      // 5. Data-driven Insights Section
                      InsightsSection(insights: insights),
                      const SizedBox(height: 20),

                      // 6. Category Distributions Lists
                      CategoryBreakdownCard(report: report),
                      const SizedBox(height: 120), // Spacing for bottom navbar
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Loading Report Data...'));
          },
        ),
      ),
    );
  }
}
