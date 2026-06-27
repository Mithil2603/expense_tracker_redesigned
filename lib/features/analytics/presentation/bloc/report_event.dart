import 'package:equatable/equatable.dart';

enum ReportDurationType { monthly, quarterly, yearly, custom }

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class WatchReportTransactions extends ReportEvent {
  final String userId;
  const WatchReportTransactions(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ChangeReportFilter extends ReportEvent {
  final ReportDurationType durationType;
  final DateTime startDate;
  final DateTime endDate;
  
  // Specific markers for display labels
  final int? selectedMonth;   // 1-12
  final int? selectedQuarter; // 1-4
  final int? selectedYear;    // YYYY

  const ChangeReportFilter({
    required this.durationType,
    required this.startDate,
    required this.endDate,
    this.selectedMonth,
    this.selectedQuarter,
    this.selectedYear,
  });

  @override
  List<Object?> get props => [
        durationType,
        startDate,
        endDate,
        selectedMonth,
        selectedQuarter,
        selectedYear,
      ];
}

class ReportTransactionsUpdated extends ReportEvent {
  final List<dynamic> transactions;
  const ReportTransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}
