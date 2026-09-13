import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/quest.dart';

class QuestFirestoreService {
  final FirebaseFirestore? _firestoreOverride;

  QuestFirestoreService({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;
  FlutterSecureStorage get _storage => GetIt.instance<FlutterSecureStorage>();

  CollectionReference<Map<String, dynamic>> _questsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('quests');
  }

  Future<List<Quest>> _loadLocalQuests(String userId) async {
    try {
      final jsonStr = await _storage.read(key: 'fingo_quests_cache_$userId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => Quest.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveLocalQuests(String userId, List<Quest> quests) async {
    try {
      final jsonStr = jsonEncode(quests.map((q) => q.toJson()).toList());
      await _storage.write(key: 'fingo_quests_cache_$userId', value: jsonStr);
    } catch (_) {}
  }

  Future<void> saveQuest(String userId, Quest quest) async {
    try {
      await _questsRef(userId).doc(quest.id).set(quest.toJson());
    } catch (_) {}
    try {
      final local = await _loadLocalQuests(userId);
      final idx = local.indexWhere((q) => q.id == quest.id);
      if (idx >= 0) {
        local[idx] = quest;
      } else {
        local.add(quest);
      }
      await _saveLocalQuests(userId, local);
    } catch (_) {}
  }

  Future<void> saveQuests(String userId, List<Quest> quests) async {
    if (quests.isEmpty) return;
    try {
      final batch = _firestore.batch();
      final ref = _questsRef(userId);
      for (final quest in quests) {
        batch.set(ref.doc(quest.id), quest.toJson());
      }
      await batch.commit();
    } catch (_) {}
    try {
      final local = await _loadLocalQuests(userId);
      final map = {for (var q in local) q.id: q};
      for (final quest in quests) {
        map[quest.id] = quest;
      }
      await _saveLocalQuests(userId, map.values.toList());
    } catch (_) {}
  }

  Future<void> updateProgress(
    String userId,
    String questId,
    int newProgress,
    QuestStatus status,
    DateTime? completedAt,
  ) async {
    try {
      final updates = <String, dynamic>{
        'currentProgress': newProgress,
        'status': status.name,
      };
      if (completedAt != null) {
        updates['completedAt'] = completedAt.toUtc().toIso8601String();
      }
      await _questsRef(userId).doc(questId).update(updates).catchError((_) {});
    } catch (_) {}
    try {
      final local = await _loadLocalQuests(userId);
      final idx = local.indexWhere((q) => q.id == questId);
      if (idx >= 0) {
        local[idx] = local[idx].copyWith(
          currentProgress: newProgress,
          status: status,
          completedAt: completedAt,
        );
        await _saveLocalQuests(userId, local);
      }
    } catch (_) {}
  }

  Future<List<Quest>> loadAllQuests(String userId) async {
    final localQuests = await _loadLocalQuests(userId);
    final Map<String, Quest> merged = {for (var q in localQuests) q.id: q};

    try {
      final snapshot = await _questsRef(userId).get();
      final firestoreQuests = snapshot.docs.map((doc) => Quest.fromFirestore(doc)).toList();
      for (var fq in firestoreQuests) {
        final lq = merged[fq.id];
        if (lq == null) {
          merged[fq.id] = fq;
        } else {
          // If local quest is completed or rewarded, preserve its status over an active state from server
          if ((lq.status == QuestStatus.completed || lq.status == QuestStatus.rewarded) &&
              fq.status == QuestStatus.active) {
            merged[fq.id] = lq;
          } else {
            merged[fq.id] = fq;
          }
        }
      }
      final result = merged.values.toList();
      await _saveLocalQuests(userId, result);
      return result;
    } catch (_) {
      return localQuests;
    }
  }

  Future<void> markRewarded(String userId, String questId) async {
    try {
      await _questsRef(userId).doc(questId).update({
        'status': QuestStatus.rewarded.name,
        'isRewarded': true,
      }).catchError((_) {});
    } catch (_) {}
    try {
      final local = await _loadLocalQuests(userId);
      final idx = local.indexWhere((q) => q.id == questId);
      if (idx >= 0) {
        local[idx] = local[idx].copyWith(
          status: QuestStatus.rewarded,
          isRewarded: true,
        );
        await _saveLocalQuests(userId, local);
      }
    } catch (_) {}
  }

  Future<void> expireQuests(String userId, List<String> questIds) async {
    if (questIds.isEmpty) return;
    try {
      final batch = _firestore.batch();
      final ref = _questsRef(userId);
      for (final id in questIds) {
        batch.update(ref.doc(id), {'status': QuestStatus.expired.name});
      }
      await batch.commit().catchError((_) {});
    } catch (_) {}
    try {
      final local = await _loadLocalQuests(userId);
      bool changed = false;
      for (int i = 0; i < local.length; i++) {
        if (questIds.contains(local[i].id)) {
          local[i] = local[i].copyWith(status: QuestStatus.expired);
          changed = true;
        }
      }
      if (changed) {
        await _saveLocalQuests(userId, local);
      }
    } catch (_) {}
  }
}
