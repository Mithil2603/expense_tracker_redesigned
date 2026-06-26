import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/feature.dart';
import 'models/subscription_entity.dart';
import 'models/subscription_plan.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  /// Updates the current subscription manually
  Future<void> updateSubscription(String userId, SubscriptionEntity entity);

  /// Initializes the service and loads persisted subscription
  Future<void> init();
}

class EntitlementServiceImpl implements EntitlementService {
  // In Phase 4, we will connect this to RevenueCat via SubscriptionRepository.
  // For now, we mock it.
  
  final _controller = StreamController<SubscriptionEntity>.broadcast();
  
  SubscriptionEntity _current = const SubscriptionEntity(
    plan: SubscriptionPlan.free, // Default to free, init() will load from storage
    status: SubscriptionStatus.active,
  );

  EntitlementServiceImpl() {
    _controller.add(_current);
  }

  @override
  Future<void> init() async {
    try {
      final storage = GetIt.instance<FlutterSecureStorage>();
      final savedPlanStr = await storage.read(key: 'fingo_subscription_plan');
      
      if (savedPlanStr != null) {
        final plan = SubscriptionPlan.values.firstWhere(
          (e) => e.name == savedPlanStr,
          orElse: () => SubscriptionPlan.free,
        );
        _current = SubscriptionEntity(
          plan: plan,
          status: SubscriptionStatus.active,
        );
        _controller.add(_current);
      }
    } catch (_) {}
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

  @override
  Future<void> updateSubscription(String userId, SubscriptionEntity entity) async {
    _current = entity;
    _controller.add(_current);
    
    try {
      final storage = GetIt.instance<FlutterSecureStorage>();
      await storage.write(key: 'fingo_subscription_plan', value: entity.plan.name);
    } catch (_) {}
  }

  // Define feature gating mapping
  static const Set<Feature> _freeFeatures = {
    Feature.basicExpenseTracking,
    Feature.basicBudgets,
    Feature.autoDetectionBasic, // Free users now have access, but gated by Gamification Health
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
