import 'package:equatable/equatable.dart';

enum AllocationType {
  fundInjection,
  repatriation,
  parentRetention,
}

extension AllocationTypeExtension on AllocationType {
  String get nameString {
    switch (this) {
      case AllocationType.fundInjection:
        return 'FUND_INJECTION';
      case AllocationType.repatriation:
        return 'REPATRIATION';
      case AllocationType.parentRetention:
        return 'PARENT_RETENTION';
    }
  }

  String get displayName {
    switch (this) {
      case AllocationType.fundInjection:
        return 'Capital Injected';
      case AllocationType.repatriation:
        return 'Repatriated to Self';
      case AllocationType.parentRetention:
        return 'Parent Retention (Household/Rounding)';
    }
  }

  static AllocationType fromString(String val) {
    switch (val.toUpperCase()) {
      case 'FUND_INJECTION':
        return AllocationType.fundInjection;
      case 'REPATRIATION':
        return AllocationType.repatriation;
      case 'PARENT_RETENTION':
      default:
        return AllocationType.parentRetention;
    }
  }
}

class CapitalAllocationEntity extends Equatable {
  final String id;
  final String profileId;
  final AllocationType type;
  final double amount;
  final DateTime date;
  final String notes;

  const CapitalAllocationEntity({
    required this.id,
    required this.profileId,
    required this.type,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  @override
  List<Object?> get props => [id, profileId, type, amount, date, notes];
}
