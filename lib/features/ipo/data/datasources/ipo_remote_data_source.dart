import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ipo_profile_model.dart';
import '../models/capital_allocation_model.dart';
import '../models/ipo_application_model.dart';
import '../models/ipo_trade_model.dart';

abstract class IpoRemoteDataSource {
  Stream<List<IpoProfileModel>> watchProfiles(String userId);
  Future<List<IpoProfileModel>> getProfiles(String userId);
  Future<void> saveProfile(String userId, IpoProfileModel profile);

  Stream<List<CapitalAllocationModel>> watchCapitalAllocations(String userId, {String? profileId});
  Future<void> addCapitalAllocation(String userId, CapitalAllocationModel allocation);
  Future<void> deleteCapitalAllocation(String userId, String allocationId);

  Stream<List<IpoApplicationModel>> watchApplications(String userId, {String? profileId});
  Future<IpoApplicationModel?> getApplicationById(String userId, String applicationId);
  Future<void> saveApplication(String userId, IpoApplicationModel application);
  Future<void> updateApplicationStatus(
    String userId,
    String applicationId, {
    required String status,
    DateTime? unblockedAt,
    DateTime? allotmentDate,
  });

  Stream<List<IpoTradeModel>> watchTrades(String userId, {String? profileId});
  Future<IpoTradeModel?> getTradeByApplicationId(String userId, String applicationId);
  Future<void> saveTrade(String userId, IpoTradeModel trade);
  Future<void> updateTradeSale(
    String userId,
    String tradeId, {
    required double sellPricePerShare,
    required double grossProceeds,
    required double netProfit,
    required DateTime soldAt,
    String? linkedIncomeTransactionId,
  });
}

class IpoRemoteDataSourceImpl implements IpoRemoteDataSource {
  final FirebaseFirestore firestore;

  IpoRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _profilesRef(String userId) {
    return firestore.collection('users').doc(userId).collection('ipo_profiles');
  }

  CollectionReference<Map<String, dynamic>> _allocationsRef(String userId) {
    return firestore.collection('users').doc(userId).collection('capital_allocations');
  }

  CollectionReference<Map<String, dynamic>> _applicationsRef(String userId) {
    return firestore.collection('users').doc(userId).collection('ipo_applications');
  }

  CollectionReference<Map<String, dynamic>> _tradesRef(String userId) {
    return firestore.collection('users').doc(userId).collection('ipo_trades');
  }

  @override
  Stream<List<IpoProfileModel>> watchProfiles(String userId) {
    return _profilesRef(userId).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => IpoProfileModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  @override
  Future<List<IpoProfileModel>> getProfiles(String userId) async {
    final snap = await _profilesRef(userId).get();
    final list = snap.docs.map((doc) => IpoProfileModel.fromFirestore(doc)).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<void> saveProfile(String userId, IpoProfileModel profile) async {
    final ref = _profilesRef(userId);
    if (profile.id.isNotEmpty) {
      await ref.doc(profile.id).set(profile.toJson(), SetOptions(merge: true));
    } else {
      await ref.add(profile.toJson());
    }
  }

  @override
  Stream<List<CapitalAllocationModel>> watchCapitalAllocations(String userId, {String? profileId}) {
    Query<Map<String, dynamic>> query = _allocationsRef(userId);
    if (profileId != null && profileId.isNotEmpty) {
      query = query.where('profileId', isEqualTo: profileId);
    }
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => CapitalAllocationModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  @override
  Future<void> addCapitalAllocation(String userId, CapitalAllocationModel allocation) async {
    final ref = _allocationsRef(userId);
    if (allocation.id.isNotEmpty) {
      await ref.doc(allocation.id).set(allocation.toJson(), SetOptions(merge: true));
    } else {
      await ref.add(allocation.toJson());
    }
  }

  @override
  Future<void> deleteCapitalAllocation(String userId, String allocationId) async {
    await _allocationsRef(userId).doc(allocationId).delete();
  }

  @override
  Stream<List<IpoApplicationModel>> watchApplications(String userId, {String? profileId}) {
    Query<Map<String, dynamic>> query = _applicationsRef(userId);
    if (profileId != null && profileId.isNotEmpty) {
      query = query.where('profileId', isEqualTo: profileId);
    }
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => IpoApplicationModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return list;
    });
  }

  @override
  Future<IpoApplicationModel?> getApplicationById(String userId, String applicationId) async {
    final doc = await _applicationsRef(userId).doc(applicationId).get();
    if (!doc.exists) return null;
    return IpoApplicationModel.fromFirestore(doc);
  }

  @override
  Future<void> saveApplication(String userId, IpoApplicationModel application) async {
    final ref = _applicationsRef(userId);
    if (application.id.isNotEmpty) {
      await ref.doc(application.id).set(application.toJson(), SetOptions(merge: true));
    } else {
      await ref.add(application.toJson());
    }
  }

  @override
  Future<void> updateApplicationStatus(
    String userId,
    String applicationId, {
    required String status,
    DateTime? unblockedAt,
    DateTime? allotmentDate,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
    };
    if (unblockedAt != null) {
      updateData['unblockedAt'] = Timestamp.fromDate(unblockedAt);
    }
    if (allotmentDate != null) {
      updateData['allotmentDate'] = Timestamp.fromDate(allotmentDate);
    }
    await _applicationsRef(userId).doc(applicationId).update(updateData);
  }

  @override
  Stream<List<IpoTradeModel>> watchTrades(String userId, {String? profileId}) {
    Query<Map<String, dynamic>> query = _tradesRef(userId);
    if (profileId != null && profileId.isNotEmpty) {
      query = query.where('profileId', isEqualTo: profileId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => IpoTradeModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<IpoTradeModel?> getTradeByApplicationId(String userId, String applicationId) async {
    final snap = await _tradesRef(userId).where('applicationId', isEqualTo: applicationId).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return IpoTradeModel.fromFirestore(snap.docs.first);
  }

  @override
  Future<void> saveTrade(String userId, IpoTradeModel trade) async {
    final ref = _tradesRef(userId);
    if (trade.id.isNotEmpty) {
      await ref.doc(trade.id).set(trade.toJson(), SetOptions(merge: true));
    } else {
      await ref.add(trade.toJson());
    }
  }

  @override
  Future<void> updateTradeSale(
    String userId,
    String tradeId, {
    required double sellPricePerShare,
    required double grossProceeds,
    required double netProfit,
    required DateTime soldAt,
    String? linkedIncomeTransactionId,
  }) async {
    final updateData = <String, dynamic>{
      'sellPricePerShare': sellPricePerShare,
      'grossProceeds': grossProceeds,
      'netProfit': netProfit,
      'soldAt': Timestamp.fromDate(soldAt),
    };
    if (linkedIncomeTransactionId != null) {
      updateData['linkedIncomeTransactionId'] = linkedIncomeTransactionId;
    }
    await _tradesRef(userId).doc(tradeId).update(updateData);
  }
}
