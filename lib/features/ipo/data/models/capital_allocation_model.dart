import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/capital_allocation_entity.dart';

class CapitalAllocationModel extends CapitalAllocationEntity {
  const CapitalAllocationModel({
    required super.id,
    required super.profileId,
    required super.type,
    required super.amount,
    required super.date,
    super.notes,
  });

  factory CapitalAllocationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CapitalAllocationModel(
      id: doc.id,
      profileId: data['profileId'] as String? ?? '',
      type: AllocationTypeExtension.fromString(data['type'] as String? ?? 'PARENT_RETENTION'),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : (data['date'] != null
              ? DateTime.tryParse(data['date'].toString()) ?? DateTime.now()
              : DateTime.now()),
      notes: data['notes'] as String? ?? '',
    );
  }

  factory CapitalAllocationModel.fromEntity(CapitalAllocationEntity entity) {
    return CapitalAllocationModel(
      id: entity.id,
      profileId: entity.profileId,
      type: entity.type,
      amount: entity.amount,
      date: entity.date,
      notes: entity.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'type': type.nameString,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }
}
