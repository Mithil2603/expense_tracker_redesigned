import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../../domain/entities/financial_report.dart';
import '../../domain/entities/financial_insight.dart';
import '../../domain/entities/financial_intelligence.dart';

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

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _customStartDate, end: _customEndDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        return Theme(
          data: isLight ? AppTheme.light : AppTheme.dark,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
      _triggerFilterUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;
    final textColor = isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final secTextColor = isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;
    final cardBgColor = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;

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
              final primaryInsight = insights.first;

              // Color coding based on highest-priority insight
              Color coachColor = AppColors.primary;
              Color coachBg = isLight ? AppColors.successSurfaceLight : AppColors.successSurfaceDark;
              if (primaryInsight.priority == InsightPriority.critical) {
                coachColor = AppColors.error;
                coachBg = isLight ? AppColors.errorSurfaceLight : AppColors.errorSurfaceDark;
              } else if (primaryInsight.priority == InsightPriority.important) {
                coachColor = AppColors.secondary;
                coachBg = isLight ? AppColors.warningSurfaceLight : AppColors.warningSurfaceDark;
              } else if (primaryInsight.priority == InsightPriority.achievement) {
                coachColor = AppColors.accent;
                coachBg = isLight ? AppColors.accentLight : AppColors.surfaceDark;
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHPadding, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Duration Picker Segmented Selector
                      _buildDurationSelector(isLight, outlineColor),
                      const SizedBox(height: 12),

                      // 2. Specific Duration Picker Sub-Controls
                      _buildPeriodPickerControls(isLight, outlineColor, textColor),
                      const SizedBox(height: 20),

                      // 3. Finny Mascot Speech Coaching Bubble
                      _buildFinnyCoachBubble(isLight, coachColor, coachBg, primaryInsight),
                      const SizedBox(height: 20),

                      // 4. Financial Health Score Circular Gauge
                      _buildHealthScoreGauge(isLight, outlineColor, textColor, secTextColor, intel.healthScore),
                      const SizedBox(height: 20),

                      // 5. Weekly Review (Narrative Story Review)
                      _buildWeeklyReview(isLight, cardBgColor, outlineColor, textColor, secTextColor, intel.weeklyReview),
                      const SizedBox(height: 20),

                      // 6. Flat-3D Main Metrics Summary Grid
                      _buildMetricsSummaryGrid(isLight, report),
                      const SizedBox(height: 20),

                      // 7. Money Leaks Detection Panel
                      if (intel.moneyLeaks.isNotEmpty) ...[
                        _buildMoneyLeaksPanel(isLight, intel.moneyLeaks),
                        const SizedBox(height: 20),
                      ],

                      // 8. Goal Prediction Panel
                      _buildGoalPrediction(isLight, cardBgColor, outlineColor, textColor, secTextColor, intel.goalPrediction),
                      const SizedBox(height: 20),

                      // 9. Financial Story Timeline
                      _buildStoryTimeline(isLight, cardBgColor, outlineColor, textColor, secTextColor, intel.timelineEvents, intel.personality),
                      const SizedBox(height: 20),

                      // 10. Category Distributions Lists
                      _buildCategoryBreakdowns(isLight, cardBgColor, outlineColor, textColor, report),
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

  Widget _buildDurationSelector(bool isLight, Color outlineColor) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF0F0F0) : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: outlineColor, width: AppSizes.borderThin),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ReportDurationType.values.map((type) {
          final isSelected = _selectedDuration == type;
          String label = 'Monthly';
          if (type == ReportDurationType.quarterly) {
            label = 'Quarterly';
          } else if (type == ReportDurationType.yearly) {
            label = 'Yearly';
          } else if (type == ReportDurationType.custom) {
            label = 'Custom';
          }

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDuration = type;
                });
                _triggerFilterUpdate();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isLight ? Colors.white : AppColors.surfaceElevatedDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSM.copyWith(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : (isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodPickerControls(bool isLight, Color outlineColor, Color textColor) {
    if (_selectedDuration == ReportDurationType.monthly) {
      final monthsList = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return Row(
        children: [
          Expanded(
            child: _buildDropdownWrapper(
              isLight: isLight,
              outlineColor: outlineColor,
              child: DropdownButton<int>(
                value: _selectedMonth,
                dropdownColor: isLight ? Colors.white : AppColors.surfaceDark,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                underline: const SizedBox(),
                isExpanded: true,
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(monthsList[index]),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedMonth = val);
                    _triggerFilterUpdate();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdownWrapper(
              isLight: isLight,
              outlineColor: outlineColor,
              child: DropdownButton<int>(
                value: _selectedYear,
                dropdownColor: isLight ? Colors.white : AppColors.surfaceDark,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                underline: const SizedBox(),
                isExpanded: true,
                items: [2024, 2025, 2026, 2027].map((yr) {
                  return DropdownMenuItem<int>(
                    value: yr,
                    child: Text(yr.toString()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedYear = val);
                    _triggerFilterUpdate();
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else if (_selectedDuration == ReportDurationType.quarterly) {
      return Row(
        children: [
          Expanded(
            child: _buildDropdownWrapper(
              isLight: isLight,
              outlineColor: outlineColor,
              child: DropdownButton<int>(
                value: _selectedQuarter,
                dropdownColor: isLight ? Colors.white : AppColors.surfaceDark,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                underline: const SizedBox(),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Q1 (Jan - Mar)')),
                  DropdownMenuItem(value: 2, child: Text('Q2 (Apr - Jun)')),
                  DropdownMenuItem(value: 3, child: Text('Q3 (Jul - Sep)')),
                  DropdownMenuItem(value: 4, child: Text('Q4 (Oct - Dec)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedQuarter = val);
                    _triggerFilterUpdate();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdownWrapper(
              isLight: isLight,
              outlineColor: outlineColor,
              child: DropdownButton<int>(
                value: _selectedYear,
                dropdownColor: isLight ? Colors.white : AppColors.surfaceDark,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                underline: const SizedBox(),
                isExpanded: true,
                items: [2024, 2025, 2026, 2027].map((yr) {
                  return DropdownMenuItem<int>(
                    value: yr,
                    child: Text(yr.toString()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedYear = val);
                    _triggerFilterUpdate();
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else if (_selectedDuration == ReportDurationType.yearly) {
      return _buildDropdownWrapper(
        isLight: isLight,
        outlineColor: outlineColor,
        child: DropdownButton<int>(
          value: _selectedYear,
          dropdownColor: isLight ? Colors.white : AppColors.surfaceDark,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          underline: const SizedBox(),
          isExpanded: true,
          items: [2024, 2025, 2026, 2027].map((yr) {
            return DropdownMenuItem<int>(
              value: yr,
              child: Text('Year $yr'),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedYear = val);
              _triggerFilterUpdate();
            }
          },
        ),
      );
    } else {
      // Custom Range Selection Button
      final df = DateFormat('MMM dd, yyyy');
      return GestureDetector(
        onTap: _selectCustomDateRange,
        child: Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(color: outlineColor, width: AppSizes.borderThick),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${df.format(_customStartDate)} - ${df.format(_customEndDate)}',
                    style: AppTextStyles.labelSM.copyWith(color: textColor),
                  ),
                ],
              ),
              const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 18),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDropdownWrapper({
    required bool isLight,
    required Color outlineColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: outlineColor, width: AppSizes.borderThick),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Widget _buildFinnyCoachBubble(
    bool isLight,
    Color coachColor,
    Color coachBg,
    FinancialInsight insight,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Finny Mascot Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            shape: BoxShape.circle,
            border: Border.all(color: coachColor, width: AppSizes.borderThick),
          ),
          child: Image.asset(
            'assets/fingo_mascot.png',
            height: 42,
            width: 42,
            errorBuilder: (context, error, stackTrace) =>
                const Text('🦉', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(width: 12),
        // Coaching Speech Bubble
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: coachBg,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppSizes.radiusLG),
                bottomLeft: Radius.circular(AppSizes.radiusLG),
                bottomRight: Radius.circular(AppSizes.radiusLG),
              ),
              border: Border.all(color: coachColor, width: AppSizes.borderThick),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      insight.title,
                      style: AppTextStyles.labelSM.copyWith(color: coachColor, fontWeight: FontWeight.w900),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: coachColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        insight.priority.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  insight.finnyMessage,
                  style: AppTextStyles.bodySM.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScoreGauge(
    bool isLight,
    Color outlineColor,
    Color textColor,
    Color secTextColor,
    HealthScore score,
  ) {
    Color scoreColor = AppColors.primary;
    if (score.score < 50) {
      scoreColor = AppColors.error;
    } else if (score.score < 80) {
      scoreColor = AppColors.secondary;
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Circular Indicator Stack
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score.score / 100.0,
                        strokeWidth: 8,
                        color: scoreColor,
                        backgroundColor: isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark,
                      ),
                      Text(
                        '${score.score}',
                        style: AppTextStyles.h1.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Score Explanation Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            'FINANCIAL HEALTH SCORE',
                            style: AppTextStyles.overline.copyWith(color: scoreColor, fontWeight: FontWeight.w900),
                          ),
                          if (score.delta != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: score.delta > 0 ? AppColors.successSurfaceLight : AppColors.errorSurfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                score.delta > 0 ? '+${score.delta}' : '${score.delta}',
                                style: TextStyle(
                                  color: score.delta > 0 ? AppColors.primaryDark : AppColors.errorDark,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        score.explanation,
                        style: AppTextStyles.bodySM.copyWith(color: secTextColor, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (score.positiveReasons.isNotEmpty || score.negativeReasons.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ...score.positiveReasons.map((reason) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: AppTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )),
              ...score.negativeReasons.map((reason) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: AppTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyReview(
    bool isLight,
    Color cardBgColor,
    Color outlineColor,
    Color textColor,
    Color secTextColor,
    WeeklyReview review,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.summarize_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'WEEKLY REVIEW',
                  style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.narrativeSummary,
              style: AppTextStyles.bodySM.copyWith(color: textColor, height: 1.3, fontWeight: FontWeight.w600),
            ),
            if (review.majorEvents.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'MAJOR SPENDING EVENTS:',
                style: AppTextStyles.overline.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...review.majorEvents.map((evt) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right_rounded, color: AppColors.error, size: 16),
                        Expanded(
                          child: Text(
                            evt,
                            style: AppTextStyles.bodySM.copyWith(color: secTextColor),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSummaryGrid(bool isLight, FinancialReport report) {
    return Row(
      children: [
        // 1. Income Card
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              children: [
                const Icon(Icons.arrow_downward_rounded, color: AppColors.primary, size: 18),
                const SizedBox(height: 4),
                Text('INCOME', style: AppTextStyles.overline),
                const SizedBox(height: 4),
                Text(
                  report.totalIncome.toCurrency(),
                  style: AppTextStyles.amountSM.copyWith(color: AppColors.primary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 2. Expenses Card
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              children: [
                const Icon(Icons.arrow_upward_rounded, color: AppColors.error, size: 18),
                const SizedBox(height: 4),
                Text('SPENT', style: AppTextStyles.overline),
                const SizedBox(height: 4),
                Text(
                  report.totalExpense.toCurrency(),
                  style: AppTextStyles.amountSM.copyWith(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 3. Savings Card
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              children: [
                const Icon(Icons.savings_rounded, color: AppColors.secondary, size: 18),
                const SizedBox(height: 4),
                Text('SAVINGS', style: AppTextStyles.overline),
                const SizedBox(height: 4),
                Text(
                  '${report.savingsRate.toStringAsFixed(0)}%',
                  style: AppTextStyles.amountSM.copyWith(color: AppColors.secondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyLeaksPanel(bool isLight, List<MoneyLeak> leaks) {
    final panelColor = AppColors.secondary;
    final panelBg = isLight ? AppColors.successSurfaceLight : AppColors.successSurfaceDark;

    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: panelColor, width: AppSizes.borderThick),
      ),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: panelColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'SAVINGS OPPORTUNITIES',
                style: AppTextStyles.labelSM.copyWith(
                  color: panelColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...leaks.map((leak) {
            Color confColor = Colors.orange;
            if (leak.confidenceLevel.toLowerCase() == 'high') {
              confColor = Colors.green;
            } else if (leak.confidenceLevel.toLowerCase() == 'low') {
              confColor = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leak.category,
                        style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: confColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: confColor, width: 1),
                        ),
                        child: Text(
                          '${leak.confidenceLevel} Confidence',
                          style: TextStyle(color: confColor, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    leak.leakReason,
                    style: AppTextStyles.bodySM.copyWith(height: 1.3, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  // Financial opportunity details
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'POTENTIAL MONTHLY SAVINGS',
                              style: AppTextStyles.overline.copyWith(fontSize: 8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              leak.potentialMonthlySavings.toCurrency(),
                              style: AppTextStyles.labelMD.copyWith(color: panelColor, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'POTENTIAL ANNUAL SAVINGS',
                              style: AppTextStyles.overline.copyWith(fontSize: 8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              leak.potentialAnnualSavings.toCurrency(),
                              style: AppTextStyles.labelMD.copyWith(color: panelColor, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💡 Actionable Tip: ${leak.actionableTip}',
                    style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                  ),
                  if (leaks.indexOf(leak) != leaks.length - 1)
                    Divider(height: 20, color: panelColor.withValues(alpha: 0.3)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalPrediction(
    bool isLight,
    Color cardBgColor,
    Color outlineColor,
    Color textColor,
    Color secTextColor,
    GoalPrediction pred,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GOAL INTELLIGENCE',
                      style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Text(
                  'Pace: ${pred.pace}',
                  style: AppTextStyles.overline.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: LinearProgressIndicator(
                      value: pred.goalProgress / 100.0,
                      minHeight: 12,
                      color: AppColors.primary,
                      backgroundColor: isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${pred.goalProgress.toStringAsFixed(0)}%',
                  style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pred.earlyCompletionSuggestion,
              style: AppTextStyles.bodySM.copyWith(color: textColor, height: 1.3, fontWeight: FontWeight.w600),
            ),
            if (pred.estimatedCompletionDate != null) ...[
              const SizedBox(height: 6),
              Text(
                'Estimated Completion Date: ${DateFormat('MMMM yyyy').format(pred.estimatedCompletionDate!)}',
                style: AppTextStyles.caption.copyWith(color: secTextColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoryTimeline(
    bool isLight,
    Color cardBgColor,
    Color outlineColor,
    Color textColor,
    Color secTextColor,
    List<String> timeline,
    FinancialPersonality personality,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timeline_rounded, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'FINANCIAL STORY TIMELINE',
                      style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    personality.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Personality: ${personality.description}',
              style: AppTextStyles.bodySM.copyWith(color: secTextColor, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 14),
            // Draw Vertical Narrative Timeline Items
            ...timeline.map((event) {
              final index = timeline.indexOf(event);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index != timeline.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: outlineColor,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        event,
                        style: AppTextStyles.bodySM.copyWith(color: textColor, height: 1.3),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdowns(
    bool isLight,
    Color cardBgColor,
    Color outlineColor,
    Color textColor,
    FinancialReport report,
  ) {
    final hasExpenses = report.categoryExpenses.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Category Breakdown', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        if (!hasExpenses)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  const Icon(Icons.pie_chart_outline_rounded, color: AppColors.textTertiary, size: 48),
                  const SizedBox(height: 12),
                  Text('No expenses logged for this range.', style: AppTextStyles.labelMD),
                ],
              ),
            ),
          )
        else
          ...report.categoryExpenses.entries.map((entry) {
            final cat = entry.key;
            final amount = entry.value;
            final percentage = report.totalExpense > 0
                ? (amount / report.totalExpense * 100.0)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(cat.icon, color: cat.color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat.displayName, style: AppTextStyles.labelSM),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100.0,
                              minHeight: 6,
                              color: cat.color,
                              backgroundColor: isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(amount.toCurrency(), style: AppTextStyles.amountSM.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
