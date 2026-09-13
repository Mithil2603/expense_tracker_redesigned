import 'package:equatable/equatable.dart';
import '../../domain/entities/capital_allocation_entity.dart';
import '../../domain/entities/ipo_application_entity.dart';
import '../../domain/entities/ipo_pool_summary.dart';
import '../../domain/entities/ipo_profile_entity.dart';
import '../../domain/entities/ipo_trade_entity.dart';

abstract class IpoHubState extends Equatable {
  const IpoHubState();

  @override
  List<Object?> get props => [];
}

class IpoHubInitial extends IpoHubState {}

class IpoHubLoading extends IpoHubState {}

class IpoHubLoaded extends IpoHubState {
  final List<IpoProfileEntity> profiles;
  final String? selectedProfileId; // null = Consolidated / All
  final List<CapitalAllocationEntity> allAllocations;
  final List<IpoApplicationEntity> allApplications;
  final List<IpoTradeEntity> allTrades;

  final List<CapitalAllocationEntity> filteredAllocations;
  final List<IpoApplicationEntity> filteredApplications;
  final List<IpoTradeEntity> filteredTrades;

  final IpoPoolSummary summary;
  final String? message;
  final String? errorMessage;

  const IpoHubLoaded({
    required this.profiles,
    this.selectedProfileId,
    required this.allAllocations,
    required this.allApplications,
    required this.allTrades,
    required this.filteredAllocations,
    required this.filteredApplications,
    required this.filteredTrades,
    required this.summary,
    this.message,
    this.errorMessage,
  });

  IpoProfileEntity? get selectedProfile {
    if (selectedProfileId == null) return null;
    try {
      return profiles.firstWhere((p) => p.id == selectedProfileId);
    } catch (_) {
      return null;
    }
  }

  IpoHubLoaded copyWith({
    List<IpoProfileEntity>? profiles,
    String? selectedProfileId,
    bool clearSelectedProfile = false,
    List<CapitalAllocationEntity>? allAllocations,
    List<IpoApplicationEntity>? allApplications,
    List<IpoTradeEntity>? allTrades,
    List<CapitalAllocationEntity>? filteredAllocations,
    List<IpoApplicationEntity>? filteredApplications,
    List<IpoTradeEntity>? filteredTrades,
    IpoPoolSummary? summary,
    String? message,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return IpoHubLoaded(
      profiles: profiles ?? this.profiles,
      selectedProfileId: clearSelectedProfile ? null : (selectedProfileId ?? this.selectedProfileId),
      allAllocations: allAllocations ?? this.allAllocations,
      allApplications: allApplications ?? this.allApplications,
      allTrades: allTrades ?? this.allTrades,
      filteredAllocations: filteredAllocations ?? this.filteredAllocations,
      filteredApplications: filteredApplications ?? this.filteredApplications,
      filteredTrades: filteredTrades ?? this.filteredTrades,
      summary: summary ?? this.summary,
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        profiles,
        selectedProfileId,
        allAllocations,
        allApplications,
        allTrades,
        filteredAllocations,
        filteredApplications,
        filteredTrades,
        summary,
        message,
        errorMessage,
      ];
}

class IpoHubError extends IpoHubState {
  final String message;

  const IpoHubError(this.message);

  @override
  List<Object?> get props => [message];
}
