import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/capital_allocation_entity.dart';
import '../../domain/entities/ipo_application_entity.dart';
import '../../domain/entities/ipo_pool_summary.dart';
import '../../domain/entities/ipo_profile_entity.dart';
import '../../domain/entities/ipo_trade_entity.dart';
import '../../domain/repositories/ipo_repository.dart';
import 'ipo_hub_event.dart';
import 'ipo_hub_state.dart';

class IpoHubBloc extends Bloc<IpoHubEvent, IpoHubState> {
  final IpoRepository ipoRepository;

  StreamSubscription<List<IpoProfileEntity>>? _profilesSub;
  StreamSubscription<List<CapitalAllocationEntity>>? _allocationsSub;
  StreamSubscription<List<IpoApplicationEntity>>? _applicationsSub;
  StreamSubscription<List<IpoTradeEntity>>? _tradesSub;

  IpoHubBloc({required this.ipoRepository}) : super(IpoHubInitial()) {
    on<LoadIpoHubEvent>(_onLoadIpoHub);
    on<SelectProfileEvent>(_onSelectProfile);
    on<InternalProfilesUpdatedEvent>(_onProfilesUpdated);
    on<InternalAllocationsUpdatedEvent>(_onAllocationsUpdated);
    on<InternalApplicationsUpdatedEvent>(_onApplicationsUpdated);
    on<InternalTradesUpdatedEvent>(_onTradesUpdated);
    on<AddAllocationEvent>(_onAddAllocation);
    on<DeleteAllocationEvent>(_onDeleteAllocation);
    on<SubmitBidEvent>(_onSubmitBid);
    on<UnblockBidEvent>(_onUnblockBid);
    on<AllotBidEvent>(_onAllotBid);
    on<SellTradeEvent>(_onSellTrade);
  }

  Future<void> _onLoadIpoHub(LoadIpoHubEvent event, Emitter<IpoHubState> emit) async {
    emit(IpoHubLoading());

    try {
      // 1. Ensure default 3 profiles exist (Self, Father, Mother)
      await ipoRepository.seedDefaultProfilesIfEmpty(event.userId);

      // 2. Cancel existing subscriptions
      await _cancelSubscriptions();

      // 3. Listen to profiles
      _profilesSub = ipoRepository.watchProfiles(event.userId).listen((profiles) {
        add(InternalProfilesUpdatedEvent(profiles));
      });

      // 4. Listen to allocations
      _allocationsSub = ipoRepository.watchCapitalAllocations(event.userId).listen((allocations) {
        add(InternalAllocationsUpdatedEvent(allocations));
      });

      // 5. Listen to applications
      _applicationsSub = ipoRepository.watchApplications(event.userId).listen((apps) {
        add(InternalApplicationsUpdatedEvent(apps));
      });

      // 6. Listen to trades
      _tradesSub = ipoRepository.watchTrades(event.userId).listen((trades) {
        add(InternalTradesUpdatedEvent(trades));
      });
    } catch (e) {
      AppLogger.e('Error loading IPO Hub: $e');
      emit(IpoHubError('Failed to initialize IPO Capital Hub: $e'));
    }
  }

  void _onProfilesUpdated(InternalProfilesUpdatedEvent event, Emitter<IpoHubState> emit) {
    if (state is IpoHubLoaded) {
      final current = state as IpoHubLoaded;
      emit(_recalculate(
        current.copyWith(profiles: event.profiles),
      ));
    } else {
      emit(_recalculate(
        IpoHubLoaded(
          profiles: event.profiles,
          selectedProfileId: event.profiles.isNotEmpty ? event.profiles.first.id : null,
          allAllocations: const [],
          allApplications: const [],
          allTrades: const [],
          filteredAllocations: const [],
          filteredApplications: const [],
          filteredTrades: const [],
          summary: IpoPoolSummary.empty,
        ),
      ));
    }
  }

  void _onAllocationsUpdated(InternalAllocationsUpdatedEvent event, Emitter<IpoHubState> emit) {
    if (state is IpoHubLoaded) {
      final current = state as IpoHubLoaded;
      emit(_recalculate(current.copyWith(allAllocations: event.allocations)));
    }
  }

  void _onApplicationsUpdated(InternalApplicationsUpdatedEvent event, Emitter<IpoHubState> emit) {
    if (state is IpoHubLoaded) {
      final current = state as IpoHubLoaded;
      emit(_recalculate(current.copyWith(allApplications: event.applications)));
    }
  }

  void _onTradesUpdated(InternalTradesUpdatedEvent event, Emitter<IpoHubState> emit) {
    if (state is IpoHubLoaded) {
      final current = state as IpoHubLoaded;
      emit(_recalculate(current.copyWith(allTrades: event.trades)));
    }
  }

  void _onSelectProfile(SelectProfileEvent event, Emitter<IpoHubState> emit) {
    if (state is IpoHubLoaded) {
      final current = state as IpoHubLoaded;
      if (event.profileId == null) {
        emit(_recalculate(current.copyWith(clearSelectedProfile: true)));
      } else {
        emit(_recalculate(current.copyWith(selectedProfileId: event.profileId)));
      }
    }
  }

  Future<void> _onAddAllocation(AddAllocationEvent event, Emitter<IpoHubState> emit) async {
    try {
      final allocation = CapitalAllocationEntity(
        id: const Uuid().v4(),
        profileId: event.profileId,
        type: event.type,
        amount: event.amount,
        date: DateTime.now(),
        notes: event.notes,
      );
      await ipoRepository.addCapitalAllocation(event.userId, allocation);
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(message: 'Capital allocation recorded'));
      }
    } catch (e) {
      AppLogger.e('Error adding allocation: $e');
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(errorMessage: 'Failed to record allocation: $e'));
      }
    }
  }

  Future<void> _onDeleteAllocation(DeleteAllocationEvent event, Emitter<IpoHubState> emit) async {
    try {
      await ipoRepository.deleteCapitalAllocation(event.userId, event.allocationId);
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(message: 'Allocation deleted'));
      }
    } catch (e) {
      AppLogger.e('Error deleting allocation: $e');
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(errorMessage: 'Failed to delete allocation: $e'));
      }
    }
  }

  Future<void> _onSubmitBid(SubmitBidEvent event, Emitter<IpoHubState> emit) async {
    if (state is! IpoHubLoaded) return;
    final current = state as IpoHubLoaded;

    // Check available capital for this profile
    final profileSummary = _computeSummaryForProfile(
      event.profileId,
      current.allAllocations,
      current.allApplications,
      current.allTrades,
    );

    if (event.bidAmount > profileSummary.availableToBid) {
      emit(current.copyWith(
        errorMessage:
            'Insufficient Available Capital! Available: ₹${profileSummary.availableToBid.toStringAsFixed(0)}, Bid: ₹${event.bidAmount.toStringAsFixed(0)}',
      ));
      return;
    }

    try {
      final application = IpoApplicationEntity(
        id: const Uuid().v4(),
        profileId: event.profileId,
        ipoName: event.ipoName,
        bidAmount: event.bidAmount,
        sharesApplied: event.sharesApplied,
        status: IpoApplicationStatus.held,
        appliedAt: DateTime.now(),
      );
      await ipoRepository.addApplication(event.userId, application);
      emit(current.copyWith(message: 'ASBA Bid placed: ₹${event.bidAmount.toStringAsFixed(0)} blocked'));
    } catch (e) {
      AppLogger.e('Error submitting bid: $e');
      emit(current.copyWith(errorMessage: 'Failed to submit bid: $e'));
    }
  }

  Future<void> _onUnblockBid(UnblockBidEvent event, Emitter<IpoHubState> emit) async {
    try {
      await ipoRepository.unblockApplication(event.userId, event.applicationId);
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(message: 'Hold released! Funds recycled back to Available pool'));
      }
    } catch (e) {
      AppLogger.e('Error unblocking bid: $e');
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(errorMessage: 'Failed to unblock: $e'));
      }
    }
  }

  Future<void> _onAllotBid(AllotBidEvent event, Emitter<IpoHubState> emit) async {
    try {
      await ipoRepository.allotApplication(
        event.userId,
        applicationId: event.applicationId,
        allottedShares: event.allottedShares,
        debitAmount: event.debitAmount,
      );
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(message: 'Allotment confirmed! ₹${event.debitAmount.toStringAsFixed(0)} debited to ledger'));
      }
    } catch (e) {
      AppLogger.e('Error allotting bid: $e');
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(errorMessage: 'Failed to confirm allotment: $e'));
      }
    }
  }

  Future<void> _onSellTrade(SellTradeEvent event, Emitter<IpoHubState> emit) async {
    try {
      await ipoRepository.sellTrade(
        event.userId,
        tradeId: event.tradeId,
        sellPricePerShare: event.sellPricePerShare,
        grossProceeds: event.grossProceeds,
        netProfit: event.netProfit,
      );
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(message: 'Trade sold! Proceeds ₹${event.grossProceeds.toStringAsFixed(0)} credited to ledger'));
      }
    } catch (e) {
      AppLogger.e('Error selling trade: $e');
      if (state is IpoHubLoaded) {
        final current = state as IpoHubLoaded;
        emit(current.copyWith(errorMessage: 'Failed to process sale: $e'));
      }
    }
  }

  IpoHubLoaded _recalculate(IpoHubLoaded state) {
    final selectedId = state.selectedProfileId;

    final filteredAllocations = selectedId == null
        ? state.allAllocations
        : state.allAllocations.where((a) => a.profileId == selectedId).toList();

    final filteredApplications = selectedId == null
        ? state.allApplications
        : state.allApplications.where((a) => a.profileId == selectedId).toList();

    final filteredTrades = selectedId == null
        ? state.allTrades
        : state.allTrades.where((t) => t.profileId == selectedId).toList();

    final summary = IpoPoolSummary.fromData(
      allocations: filteredAllocations,
      applications: filteredApplications,
      trades: filteredTrades,
    );

    return state.copyWith(
      filteredAllocations: filteredAllocations,
      filteredApplications: filteredApplications,
      filteredTrades: filteredTrades,
      summary: summary,
    );
  }

  IpoPoolSummary _computeSummaryForProfile(
    String profileId,
    List<CapitalAllocationEntity> allocations,
    List<IpoApplicationEntity> applications,
    List<IpoTradeEntity> trades,
  ) {
    return IpoPoolSummary.fromData(
      allocations: allocations.where((a) => a.profileId == profileId).toList(),
      applications: applications.where((a) => a.profileId == profileId).toList(),
      trades: trades.where((t) => t.profileId == profileId).toList(),
    );
  }

  Future<void> _cancelSubscriptions() async {
    await _profilesSub?.cancel();
    await _allocationsSub?.cancel();
    await _applicationsSub?.cancel();
    await _tradesSub?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
