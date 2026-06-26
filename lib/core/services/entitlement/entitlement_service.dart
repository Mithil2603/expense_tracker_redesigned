import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/feature.dart';
import 'models/subscription_entity.dart';
import 'models/subscription_plan.dart';

/// The single source of truth for all feature gating and entitlement logic.
/// Abstracts away the underlying billing provider (e.g. RevenueCat) from feature modules.
abstract class EntitlementService {
  /// Stream of current subscription state
  Stream<SubscriptionEntity> get subscriptionStream;

  /// Get the current subscription state synchronously
  SubscriptionEntity get currentSubscription;

  /// Check if the user has access to a specific feature
  bool hasAccess(Feature feature);

  /// Check if the user is on at least a certain plan
  bool hasMinimumPlan(SubscriptionPlan plan);

  /// Triggers a refresh of entitlements from the backend
  Future<void> refreshEntitlements();
}

class EntitlementServiceImpl implements EntitlementService {
  // In Phase 4, we will connect this to RevenueCat via SubscriptionRepository.
  // For now, we mock it.
  
  final _controller = StreamController<SubscriptionEntity>.broadcast();
  
  SubscriptionEntity _current = const SubscriptionEntity(
    plan: SubscriptionPlan.free,
    status: SubscriptionStatus.active,
  );

  EntitlementServiceImpl() {
    _controller.add(_current);
  }

  @override
  Stream<SubscriptionEntity> get subscriptionStream => _controller.stream;

  @override
  SubscriptionEntity get currentSubscription => _current;

  @override
  bool hasAccess(Feature feature) {
    if (!_current.isActive) return false;

    switch (_current.plan) {
      case SubscriptionPlan.free:
        return _freeFeatures.contains(feature);
      case SubscriptionPlan.plus:
        return _freeFeatures.contains(feature) || _plusFeatures.contains(feature);
      case SubscriptionPlan.premium:
        return true; // Premium has access to everything
    }
  }

  @override
  bool hasMinimumPlan(SubscriptionPlan plan) {
    if (!_current.isActive && plan != SubscriptionPlan.free) return false;
    
    switch (plan) {
      case SubscriptionPlan.free:
        return true;
      case SubscriptionPlan.plus:
        return _current.plan == SubscriptionPlan.plus || _current.plan == SubscriptionPlan.premium;
      case SubscriptionPlan.premium:
        return _current.plan == SubscriptionPlan.premium;
    }
  }

  @override
  Future<void> refreshEntitlements() async {
    // Phase 4: Await RevenueCat refresh
    // _current = await _subscriptionRepository.getSubscription();
    // _controller.add(_current);
  }

  // Define feature gating mapping
  static const Set<Feature> _freeFeatures = {
    Feature.basicExpenseTracking,
    Feature.basicBudgets,
  };

  static const Set<Feature> _plusFeatures = {
    Feature.autoDetectionBasic,
    Feature.customCategories,
    Feature.advancedStats,
  };

  /// For testing UI states during development
  @visibleForTesting
  void mockPlan(SubscriptionPlan plan) {
    _current = SubscriptionEntity(plan: plan, status: SubscriptionStatus.active);
    _controller.add(_current);
  }
}
