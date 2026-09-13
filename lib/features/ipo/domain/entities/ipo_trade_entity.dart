import 'package:equatable/equatable.dart';

class IpoTradeEntity extends Equatable {
  final String id;
  final String applicationId;
  final String profileId;
  final int allottedShares;
  final double debitAmount;
  final double? sellPricePerShare;
  final double? grossProceeds;
  final double? netProfit;
  final DateTime? soldAt;
  final String? linkedExpenseTransactionId;
  final String? linkedIncomeTransactionId;

  const IpoTradeEntity({
    required this.id,
    required this.applicationId,
    required this.profileId,
    required this.allottedShares,
    required this.debitAmount,
    this.sellPricePerShare,
    this.grossProceeds,
    this.netProfit,
    this.soldAt,
    this.linkedExpenseTransactionId,
    this.linkedIncomeTransactionId,
  });

  bool get isSold => soldAt != null;

  IpoTradeEntity copyWith({
    String? id,
    String? applicationId,
    String? profileId,
    int? allottedShares,
    double? debitAmount,
    double? sellPricePerShare,
    double? grossProceeds,
    double? netProfit,
    DateTime? soldAt,
    String? linkedExpenseTransactionId,
    String? linkedIncomeTransactionId,
  }) {
    return IpoTradeEntity(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      profileId: profileId ?? this.profileId,
      allottedShares: allottedShares ?? this.allottedShares,
      debitAmount: debitAmount ?? this.debitAmount,
      sellPricePerShare: sellPricePerShare ?? this.sellPricePerShare,
      grossProceeds: grossProceeds ?? this.grossProceeds,
      netProfit: netProfit ?? this.netProfit,
      soldAt: soldAt ?? this.soldAt,
      linkedExpenseTransactionId: linkedExpenseTransactionId ?? this.linkedExpenseTransactionId,
      linkedIncomeTransactionId: linkedIncomeTransactionId ?? this.linkedIncomeTransactionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        applicationId,
        profileId,
        allottedShares,
        debitAmount,
        sellPricePerShare,
        grossProceeds,
        netProfit,
        soldAt,
        linkedExpenseTransactionId,
        linkedIncomeTransactionId,
      ];
}
