import 'package:equatable/equatable.dart';
import '../../domain/entities/capital_allocation_entity.dart';
import '../../domain/entities/ipo_application_entity.dart';
import '../../domain/entities/ipo_profile_entity.dart';
import '../../domain/entities/ipo_trade_entity.dart';

abstract class IpoHubEvent extends Equatable {
  const IpoHubEvent();

  @override
  List<Object?> get props => [];
}

class LoadIpoHubEvent extends IpoHubEvent {
  final String userId;

  const LoadIpoHubEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SelectProfileEvent extends IpoHubEvent {
  final String? profileId; // null = Consolidated / All

  const SelectProfileEvent(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

class InternalProfilesUpdatedEvent extends IpoHubEvent {
  final List<IpoProfileEntity> profiles;

  const InternalProfilesUpdatedEvent(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

class InternalAllocationsUpdatedEvent extends IpoHubEvent {
  final List<CapitalAllocationEntity> allocations;

  const InternalAllocationsUpdatedEvent(this.allocations);

  @override
  List<Object?> get props => [allocations];
}

class InternalApplicationsUpdatedEvent extends IpoHubEvent {
  final List<IpoApplicationEntity> applications;

  const InternalApplicationsUpdatedEvent(this.applications);

  @override
  List<Object?> get props => [applications];
}

class InternalTradesUpdatedEvent extends IpoHubEvent {
  final List<IpoTradeEntity> trades;

  const InternalTradesUpdatedEvent(this.trades);

  @override
  List<Object?> get props => [trades];
}

class AddAllocationEvent extends IpoHubEvent {
  final String userId;
  final String profileId;
  final AllocationType type;
  final double amount;
  final String notes;

  const AddAllocationEvent({
    required this.userId,
    required this.profileId,
    required this.type,
    required this.amount,
    required this.notes,
  });

  @override
  List<Object?> get props => [userId, profileId, type, amount, notes];
}

class DeleteAllocationEvent extends IpoHubEvent {
  final String userId;
  final String allocationId;

  const DeleteAllocationEvent({
    required this.userId,
    required this.allocationId,
  });

  @override
  List<Object?> get props => [userId, allocationId];
}

class SubmitBidEvent extends IpoHubEvent {
  final String userId;
  final String profileId;
  final String ipoName;
  final double bidAmount;
  final int sharesApplied;

  const SubmitBidEvent({
    required this.userId,
    required this.profileId,
    required this.ipoName,
    required this.bidAmount,
    required this.sharesApplied,
  });

  @override
  List<Object?> get props => [userId, profileId, ipoName, bidAmount, sharesApplied];
}

class UnblockBidEvent extends IpoHubEvent {
  final String userId;
  final String applicationId;

  const UnblockBidEvent({
    required this.userId,
    required this.applicationId,
  });

  @override
  List<Object?> get props => [userId, applicationId];
}

class AllotBidEvent extends IpoHubEvent {
  final String userId;
  final String applicationId;
  final int allottedShares;
  final double debitAmount;

  const AllotBidEvent({
    required this.userId,
    required this.applicationId,
    required this.allottedShares,
    required this.debitAmount,
  });

  @override
  List<Object?> get props => [userId, applicationId, allottedShares, debitAmount];
}

class SellTradeEvent extends IpoHubEvent {
  final String userId;
  final String tradeId;
  final double sellPricePerShare;
  final double grossProceeds;
  final double netProfit;

  const SellTradeEvent({
    required this.userId,
    required this.tradeId,
    required this.sellPricePerShare,
    required this.grossProceeds,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [userId, tradeId, sellPricePerShare, grossProceeds, netProfit];
}
