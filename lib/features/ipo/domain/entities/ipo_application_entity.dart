import 'package:equatable/equatable.dart';

enum IpoApplicationStatus {
  held,
  unblocked,
  allotted,
  sold,
}

extension IpoApplicationStatusExtension on IpoApplicationStatus {
  String get nameString {
    switch (this) {
      case IpoApplicationStatus.held:
        return 'HELD';
      case IpoApplicationStatus.unblocked:
        return 'UNBLOCKED';
      case IpoApplicationStatus.allotted:
        return 'ALLOTTED';
      case IpoApplicationStatus.sold:
        return 'SOLD';
    }
  }

  String get displayName {
    switch (this) {
      case IpoApplicationStatus.held:
        return 'ASBA Blocked';
      case IpoApplicationStatus.unblocked:
        return 'Unblocked / Refunded';
      case IpoApplicationStatus.allotted:
        return 'Allotted';
      case IpoApplicationStatus.sold:
        return 'Sold / Exited';
    }
  }

  static IpoApplicationStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'HELD':
        return IpoApplicationStatus.held;
      case 'UNBLOCKED':
        return IpoApplicationStatus.unblocked;
      case 'ALLOTTED':
        return IpoApplicationStatus.allotted;
      case 'SOLD':
        return IpoApplicationStatus.sold;
      default:
        return IpoApplicationStatus.held;
    }
  }
}

class IpoApplicationEntity extends Equatable {
  final String id;
  final String profileId;
  final String ipoName;
  final double bidAmount;
  final int sharesApplied;
  final IpoApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? unblockedAt;
  final DateTime? allotmentDate;

  const IpoApplicationEntity({
    required this.id,
    required this.profileId,
    required this.ipoName,
    required this.bidAmount,
    required this.sharesApplied,
    required this.status,
    required this.appliedAt,
    this.unblockedAt,
    this.allotmentDate,
  });

  IpoApplicationEntity copyWith({
    String? id,
    String? profileId,
    String? ipoName,
    double? bidAmount,
    int? sharesApplied,
    IpoApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? unblockedAt,
    DateTime? allotmentDate,
  }) {
    return IpoApplicationEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      ipoName: ipoName ?? this.ipoName,
      bidAmount: bidAmount ?? this.bidAmount,
      sharesApplied: sharesApplied ?? this.sharesApplied,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      unblockedAt: unblockedAt ?? this.unblockedAt,
      allotmentDate: allotmentDate ?? this.allotmentDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        ipoName,
        bidAmount,
        sharesApplied,
        status,
        appliedAt,
        unblockedAt,
        allotmentDate,
      ];
}
