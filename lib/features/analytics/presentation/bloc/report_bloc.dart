import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/fingo_state.dart';
import '../../../../di/injection_container.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';
import '../../../expenses/domain/usecases/watch_transactions.dart';
import '../../domain/usecases/generate_report.dart';
import '../../domain/usecases/generate_insights.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final WatchTransactions watchTransactions;
  final GenerateReport generateReport;
  final GenerateInsights generateInsights;

  StreamSubscription? _transactionsSubscription;
  List<TransactionEntity> _allTransactions = [];

  // Store active filter details locally in Bloc
  ReportDurationType _currentDurationType = ReportDurationType.monthly;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;
  int? _selectedMonth;
  int? _selectedQuarter;
  int? _selectedYear;

  ReportBloc({
    required this.watchTransactions,
    required this.generateReport,
    required this.generateInsights,
  }) : super(ReportInitial()) {
    
    // Initialize default filter to current month
    final now = DateTime.now();
    _currentStartDate = DateTime(now.year, now.month, 1);
    _currentEndDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    _selectedMonth = now.month;
    _selectedYear = now.year;

    on<WatchReportTransactions>((event, emit) async {
      emit(ReportLoading());
      await _transactionsSubscription?.cancel();

      // Listen to real-time transaction updates from Firestore
      _transactionsSubscription = watchTransactions(event.userId).listen((result) {
        result.fold(
          (failure) => add(ReportTransactionsUpdated(const [])),
          (transactions) => add(ReportTransactionsUpdated(transactions)),
        );
      });
    });

    on<ReportTransactionsUpdated>((event, emit) {
      _allTransactions = List<TransactionEntity>.from(event.transactions);
      _recalculateAndEmit(emit);
    });

    on<ChangeReportFilter>((event, emit) {
      _currentDurationType = event.durationType;
      _currentStartDate = event.startDate;
      _currentEndDate = event.endDate;
      _selectedMonth = event.selectedMonth;
      _selectedQuarter = event.selectedQuarter;
      _selectedYear = event.selectedYear;

      _recalculateAndEmit(emit);
    });
  }

  void _recalculateAndEmit(Emitter<ReportState> emit) {
    try {
      final monthlyBudget = sl<FingoState>().monthlyBudget;

      // 1. Generate Report (pre-filtering is completed inside this usecase)
      final report = generateReport(
        transactions: _allTransactions,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );

      // 2. Generate Insights with optimized cache checks
      final insightsResult = generateInsights(
        report: report,
        allTransactions: _allTransactions,
        monthlyBudget: monthlyBudget,
      );

      emit(ReportLoaded(
        durationType: _currentDurationType,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        report: report,
        intelligence: insightsResult.intelligence,
        insights: insightsResult.insights,
        selectedMonth: _selectedMonth,
        selectedQuarter: _selectedQuarter,
        selectedYear: _selectedYear,
      ));
    } catch (e) {
      emit(ReportError('Failed to calculate financial intelligence: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
