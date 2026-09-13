import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ipo_profile_entity.dart';

class IpoProfileModel extends IpoProfileEntity {
  const IpoProfileModel({
    required super.id,
    required super.name,
    required super.type,
    super.panNumber,
    super.dmatAccount,
    required super.createdAt,
  });

  factory IpoProfileModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return IpoProfileModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Profile',
      type: ProfileTypeExtension.fromString(data['type'] as String? ?? 'PROXY_PARENT'),
      panNumber: data['panNumber'] as String?,
      dmatAccount: data['dmatAccount'] as String?,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  factory IpoProfileModel.fromEntity(IpoProfileEntity entity) {
    return IpoProfileModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      panNumber: entity.panNumber,
      dmatAccount: entity.dmatAccount,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.nameString,
      'panNumber': panNumber,
      'dmatAccount': dmatAccount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
