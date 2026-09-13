import 'package:flutter_test/flutter_test.dart';
import 'package:fingo/core/utils/fingo_state.dart';
import 'package:fingo/di/injection_container.dart' as di;
import 'package:fingo/di/injection_container.dart';
import 'package:fingo/core/services/quest/quest_engine_service.dart';
import 'package:fingo/core/domain/entities/quest_event.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('Reward system diagnostic test - verify zero rewards fire on app restart', () async {
    final Map<String, String> diskStorage = {};

    // --- SIMULATED LAUNCH 1 ---
    await GetIt.instance.reset();
    await di.init();
    FlutterSecureStorage.setMockInitialValues(Map<String, String>.from(diskStorage));

    final state1 = sl<FingoState>();
    final storage1 = sl<FlutterSecureStorage>();

    // 1. Initial load
    await state1.loadStats();
    
    // Check-in reward should be queued on first open of the day
    expect(state1.pendingRewards.contains(RewardType.daily), isTrue);

    // 2. recordEvent (appOpen) and transaction sync
    final engine1 = sl<QuestEngineService>();
    await engine1.ensureQuestsForCurrentPeriods('test_user', 1, 20000.0);
    await engine1.recordEvent(
      QuestEvent(type: QuestEventType.appOpen, timestamp: DateTime.now()),
      'test_user',
    );
    state1.syncWithTransactions([]);

    // 3. User claims all rewards (clearing pending queue)
    if (state1.pendingRewards.isNotEmpty) {
      final list = List<RewardType>.from(state1.pendingRewards);
      for (final r in list) {
        await state1.clearPendingReward(r);
      }
    }
    if (state1.pendingQuestRewards.isNotEmpty) {
      await state1.clearAllPendingQuestRewards();
    }

    // Save final storage values
    diskStorage.clear();
    diskStorage.addAll(await storage1.readAll());

    // --- SIMULATED LAUNCH 2 (RESTART) ---
    await GetIt.instance.reset();
    await di.init();
    FlutterSecureStorage.setMockInitialValues(Map<String, String>.from(diskStorage));

    final state2 = sl<FingoState>();

    // 1. Load stats on launch 2 - MUST be empty at start
    await state2.loadStats();
    expect(state2.pendingRewards, isEmpty, reason: 'pendingRewards must be empty on restart');
    expect(state2.pendingQuestRewards, isEmpty, reason: 'pendingQuestRewards must be empty on restart');

    // 2. recordEvent (appOpen) and transaction sync on launch 2 - should not trigger new rewards
    final engine2 = sl<QuestEngineService>();
    await engine2.ensureQuestsForCurrentPeriods('test_user', 1, 20000.0);
    await engine2.recordEvent(
      QuestEvent(type: QuestEventType.appOpen, timestamp: DateTime.now()),
      'test_user',
    );
    state2.syncWithTransactions([]);

    // Assert that the reward screen/fires exactly ZERO times on second launch
    expect(state2.pendingRewards, isEmpty, reason: 'No budget or streak rewards should fire on second launch');
    expect(state2.pendingQuestRewards, isEmpty, reason: 'No quest rewards should fire on second launch');
  });
}
