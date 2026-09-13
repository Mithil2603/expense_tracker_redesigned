import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ipo_trade_entity.dart';

class IpoTradeModel extends IpoTradeEntity {
  const IpoTradeModel({
    required super.id,
    required super.applicationId,
    required super.profileId,
    required super.allottedShares,
    required super.debitAmount,
    super.sellPricePerShare,
    super.grossProceeds,
    super.netProfit,
    super.soldAt,
    super.linkedExpenseTransactionId,
    super.linkedIncomeTransactionId,
  });

  factory IpoTradeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return IpoTradeModel(
      id: doc.id,
      applicationId: data['applicationId'] as String? ?? '',
      profileId: data['profileId'] as String? ?? '',
      allottedShares: (data['allottedShares'] as num?)?.toInt() ?? 0,
      debitAmount: (data['debitAmount'] as num?)?.toDouble() ?? 0.0,
      sellPricePerShare: (data['sellPricePerShare'] as num?)?.toDouble(),
      grossProceeds: (data['grossProceeds'] as num?)?.toDouble(),
      netProfit: (data['netProfit'] as num?)?.toDouble(),
      soldAt: (data['soldAt'] is Timestamp)
          ? (data['soldAt'] as Timestamp).toDate()
          : (data['soldAt'] != null
              ? DateTime.tryParse(data['soldAt'].toString())
              : null),
      linkedExpenseTransactionId: data['linkedExpenseTransactionId'] as String?,
      linkedIncomeTransactionId: data['linkedIncomeTransactionId'] as String?,
    );
  }

  factory IpoTradeModel.fromEntity(IpoTradeEntity entity) {
    return IpoTradeModel(
      id: entity.id,
      applicationId: entity.applicationId,
      profileId: entity.profileId,
      allottedShares: entity.allottedShares,
      debitAmount: entity.debitAmount,
      sellPricePerShare: entity.sellPricePerShare,
      grossProceeds: entity.grossProceeds,
      netProfit: entity.netProfit,
      soldAt: entity.soldAt,
      linkedExpenseTransactionId: entity.linkedExpenseTransactionId,
      linkedIncomeTransactionId: entity.linkedIncomeTransactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'profileId': profileId,
      'allottedShares': allottedShares,
      'debitAmount': debitAmount,
      'sellPricePerShare': sellPricePerShare,
      'grossProceeds': grossProceeds,
      'netProfit': netProfit,
      'soldAt': soldAt != null ? Timestamp.fromDate(soldAt!) : null,
      'linkedExpenseTransactionId': linkedExpenseTransactionId,
      'linkedIncomeTransactionId': linkedIncomeTransactionId,
    };
  }
}
