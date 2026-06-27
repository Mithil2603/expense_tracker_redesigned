import 'package:equatable/equatable.dart';
import '../../domain/entities/financial_report.dart';
import '../../domain/entities/financial_insight.dart';
import '../../domain/entities/financial_intelligence.dart';
import 'report_event.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final ReportDurationType durationType;
  final DateTime startDate;
  final DateTime endDate;
  final FinancialReport report;
  final FinancialIntelligence intelligence;
  final List<FinancialInsight> insights;
  
  final int? selectedMonth;
  final int? selectedQuarter;
  final int? selectedYear;

  const ReportLoaded({
    required this.durationType,
    required this.startDate,
    required this.endDate,
    required this.report,
    required this.intelligence,
    required this.insights,
    this.selectedMonth,
    this.selectedQuarter,
    this.selectedYear,
  });

  @override
  List<Object?> get props => [
        durationType,
        startDate,
        endDate,
        report,
        intelligence,
        insights,
        selectedMonth,
        selectedQuarter,
        selectedYear,
      ];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
