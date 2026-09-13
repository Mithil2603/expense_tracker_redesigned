import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ipo_application_entity.dart';

class IpoApplicationModel extends IpoApplicationEntity {
  const IpoApplicationModel({
    required super.id,
    required super.profileId,
    required super.ipoName,
    required super.bidAmount,
    required super.sharesApplied,
    required super.status,
    required super.appliedAt,
    super.unblockedAt,
    super.allotmentDate,
  });

  factory IpoApplicationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return IpoApplicationModel(
      id: doc.id,
      profileId: data['profileId'] as String? ?? '',
      ipoName: data['ipoName'] as String? ?? '',
      bidAmount: (data['bidAmount'] as num?)?.toDouble() ?? 0.0,
      sharesApplied: (data['sharesApplied'] as num?)?.toInt() ?? 0,
      status: IpoApplicationStatusExtension.fromString(data['status'] as String? ?? 'HELD'),
      appliedAt: (data['appliedAt'] is Timestamp)
          ? (data['appliedAt'] as Timestamp).toDate()
          : (data['appliedAt'] != null
              ? DateTime.tryParse(data['appliedAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      unblockedAt: (data['unblockedAt'] is Timestamp)
          ? (data['unblockedAt'] as Timestamp).toDate()
          : (data['unblockedAt'] != null
              ? DateTime.tryParse(data['unblockedAt'].toString())
              : null),
      allotmentDate: (data['allotmentDate'] is Timestamp)
          ? (data['allotmentDate'] as Timestamp).toDate()
          : (data['allotmentDate'] != null
              ? DateTime.tryParse(data['allotmentDate'].toString())
              : null),
    );
  }

  factory IpoApplicationModel.fromEntity(IpoApplicationEntity entity) {
    return IpoApplicationModel(
      id: entity.id,
      profileId: entity.profileId,
      ipoName: entity.ipoName,
      bidAmount: entity.bidAmount,
      sharesApplied: entity.sharesApplied,
      status: entity.status,
      appliedAt: entity.appliedAt,
      unblockedAt: entity.unblockedAt,
      allotmentDate: entity.allotmentDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'ipoName': ipoName,
      'bidAmount': bidAmount,
      'sharesApplied': sharesApplied,
      'status': status.nameString,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'unblockedAt': unblockedAt != null ? Timestamp.fromDate(unblockedAt!) : null,
      'allotmentDate': allotmentDate != null ? Timestamp.fromDate(allotmentDate!) : null,
    };
  }
}
