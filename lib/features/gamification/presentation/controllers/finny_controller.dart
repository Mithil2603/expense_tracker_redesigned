import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/finny_asset_resolver.dart';
import '../utils/finny_message_bank.dart';

class FinnyController extends ChangeNotifier {
  FinnyEmotion _currentEmotion = FinnyEmotion.happy;
  String? _currentMessage;
  Timer? _revertTimer;
  bool _isVisible = true;

  FinnyEmotion get currentEmotion => _currentEmotion;
  String? get currentMessage => _currentMessage;
  bool get isVisible => _isVisible;

  /// Triggers a specific event from the message bank, updating emotion and dialogue.
  /// Automatically reverts to the baseline happy state after the specified duration.
  void triggerEvent(FinnyTrigger trigger, {Duration duration = const Duration(seconds: 4)}) {
    final result = FinnyMessageBank.getMessageForTrigger(trigger);
    
    _currentEmotion = result.emotion;
    _currentMessage = result.message;
    notifyListeners();

    _revertTimer?.cancel();
    _revertTimer = Timer(duration, _revertToBaseline);
  }

  /// Manually force an emotion (useful for testing or specific non-bank scenarios)
  void setEmotion(FinnyEmotion emotion, {String? message, Duration? duration}) {
    _currentEmotion = emotion;
    _currentMessage = message;
    notifyListeners();

    _revertTimer?.cancel();
    if (duration != null) {
      _revertTimer = Timer(duration, _revertToBaseline);
    }
  }

  void hideMessage() {
    _currentMessage = null;
    notifyListeners();
  }
  
  void setVisibility(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      notifyListeners();
    }
  }

  void _revertToBaseline() {
    _currentEmotion = FinnyEmotion.happy;
    _currentMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }
}
