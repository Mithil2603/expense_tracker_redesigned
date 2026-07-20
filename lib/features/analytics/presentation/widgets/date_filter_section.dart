import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../bloc/report_event.dart';

class DateFilterSection extends StatelessWidget {
  final ReportDurationType selectedDuration;
  final int selectedMonth;
  final int selectedQuarter;
  final int selectedYear;
  final DateTime customStartDate;
  final DateTime customEndDate;
  final ValueChanged<ReportDurationType> onDurationChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onQuarterChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<DateTimeRange> onCustomDateRangeSelected;

  const DateFilterSection({
    super.key,
    required this.selectedDuration,
    required this.selectedMonth,
    required this.selectedQuarter,
    required this.selectedYear,
    required this.customStartDate,
    required this.customEndDate,
    required this.onDurationChanged,
    required this.onMonthChanged,
    required this.onQuarterChanged,
    required this.onYearChanged,
    required this.onCustomDateRangeSelected,
  });

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: customStartDate, end: customEndDate),
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
      onCustomDateRangeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;
    final textColor = isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDurationSelector(isLight, outlineColor),
        const SizedBox(height: 12),
        _buildPeriodPickerControls(context, isLight, outlineColor, textColor),
      ],
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
          final isSelected = selectedDuration == type;
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
              onTap: () => onDurationChanged(type),
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

  Widget _buildPeriodPickerControls(
    BuildContext context,
    bool isLight,
    Color outlineColor,
    Color textColor,
  ) {
    if (selectedDuration == ReportDurationType.monthly) {
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
                value: selectedMonth,
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
                    onMonthChanged(val);
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
                value: selectedYear,
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
                    onYearChanged(val);
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else if (selectedDuration == ReportDurationType.quarterly) {
      return Row(
        children: [
          Expanded(
            child: _buildDropdownWrapper(
              isLight: isLight,
              outlineColor: outlineColor,
              child: DropdownButton<int>(
                value: selectedQuarter,
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
                    onQuarterChanged(val);
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
                value: selectedYear,
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
                    onYearChanged(val);
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else if (selectedDuration == ReportDurationType.yearly) {
      return _buildDropdownWrapper(
        isLight: isLight,
        outlineColor: outlineColor,
        child: DropdownButton<int>(
          value: selectedYear,
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
              onYearChanged(val);
            }
          },
        ),
      );
    } else {
      // Custom Range Selection Button
      final df = DateFormat('MMM dd, yyyy');
      return GestureDetector(
        onTap: () => _selectCustomDateRange(context),
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
                    '${df.format(customStartDate)} - ${df.format(customEndDate)}',
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
}
