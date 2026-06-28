import 'dart:math';
import 'finny_asset_resolver.dart';

enum FinnyTrigger {
  genericTap,
  expenseLogged,
  streakBroken,
  streakMaintained,
  goalAchieved,
  levelUp,
}

class FinnyMessageBank {
  static final Random _random = Random();
  static final Map<FinnyTrigger, int> _lastUsedIndices = {};

  static final Map<FinnyTrigger, List<String>> _messagePools = {
    FinnyTrigger.genericTap: [
      "I'm here to help you reach your goals!",
      "Every small saving adds up!",
      "Let's conquer your budget together!",
      "You're doing great. Keep tracking!",
    ],
    FinnyTrigger.expenseLogged: [
      "Got it! I've logged that for you.",
      "Tracked and ready to analyze!",
      "Awesome, keeping a close eye on the budget.",
      "Logged! Knowledge is financial power.",
    ],
    FinnyTrigger.streakBroken: [
      "No worries! Let's start a fresh new streak today.",
      "Life happens! Today is a great day to begin again.",
      "We can always bounce back. Ready to track?",
    ],
    FinnyTrigger.streakMaintained: [
      "You're on fire! Keep that streak going!",
      "Another day, another save. Amazing consistency!",
      "Your tracking habits are getting stronger!",
      "Consistency unlocked! Great job.",
    ],
    FinnyTrigger.goalAchieved: [
      "Wow! You crushed that goal!",
      "Goal achieved! Time to celebrate!",
      "You did it! I'm so proud of your progress.",
    ],
    FinnyTrigger.levelUp: [
      "Level up! You are mastering your money.",
      "Congratulations! A new level of financial wisdom.",
      "Woohoo! More XP, more financial power!",
    ],
  };

  static final Map<FinnyTrigger, FinnyEmotion> _triggerEmotions = {
    FinnyTrigger.genericTap: FinnyEmotion.happy,
    FinnyTrigger.expenseLogged: FinnyEmotion.focused,
    FinnyTrigger.streakBroken: FinnyEmotion.cheerUp,
    FinnyTrigger.streakMaintained: FinnyEmotion.excited,
    FinnyTrigger.goalAchieved: FinnyEmotion.excited,
    FinnyTrigger.levelUp: FinnyEmotion.excited,
  };

  /// Retrieves a non-repeating message for the given trigger,
  /// and the corresponding emotion state.
  static ({String message, FinnyEmotion emotion}) getMessageForTrigger(FinnyTrigger trigger) {
    final pool = _messagePools[trigger] ?? _messagePools[FinnyTrigger.genericTap]!;
    final emotion = _triggerEmotions[trigger] ?? FinnyEmotion.happy;

    if (pool.isEmpty) return (message: "I'm here!", emotion: emotion);
    if (pool.length == 1) return (message: pool.first, emotion: emotion);

    int lastIndex = _lastUsedIndices[trigger] ?? -1;
    int nextIndex;

    // Simple no-repeat-twice-in-a-row logic
    do {
      nextIndex = _random.nextInt(pool.length);
    } while (nextIndex == lastIndex);

    _lastUsedIndices[trigger] = nextIndex;
    
    return (message: pool[nextIndex], emotion: emotion);
  }
}
