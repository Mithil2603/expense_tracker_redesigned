import 'subscription_plan.dart';

class SubscriptionEntity {
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime? expiryDate;
  final String? originalTransactionId;

  const SubscriptionEntity({
    required this.plan,
    required this.status,
    this.expiryDate,
    this.originalTransactionId,
  });

  bool get isActive {
    if (plan == SubscriptionPlan.free) return true;
    if (status == SubscriptionStatus.active || status == SubscriptionStatus.gracePeriod) {
      if (expiryDate != null) {
        return DateTime.now().isBefore(expiryDate!);
      }
      return true; // Lifetime or unexpiring
    }
    return false;
  }
}
