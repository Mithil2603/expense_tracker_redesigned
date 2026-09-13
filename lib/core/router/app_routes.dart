/// AppRoutes — single source of truth for routing paths and route names.
abstract final class AppRoutes {
  // ─── Main Sections ─────────────────────────────────────────────────────────
  static const String root = '/';

  static const String dashboardPath = '/dashboard';
  static const String dashboardName = 'dashboard';

  static const String questsPath = '/quests';
  static const String questsName = 'quests';

  static const String analyticsPath = '/analytics';
  static const String analyticsName = 'analytics';

  static const String profilePath = '/profile';
  static const String profileName = 'profile';

  static const String subscriptionsPath = '/subscriptions';
  static const String subscriptionsName = 'subscriptions';

  static const String feedPath = '/feed';
  static const String feedName = 'feed';

  // ─── Sub-routes / Detail Screens ───────────────────────────────────────────
  static const String addExpensePath = 'add-expense';
  static const String addExpenseName = 'add-expense';

  static const String editExpensePath = 'edit-expense';
  static const String editExpenseName = 'edit-expense';

  // ─── Authentication ────────────────────────────────────────────────────────
  static const String authPath = '/auth';
  static const String authName = 'auth';

  // ─── Onboarding ────────────────────────────────────────────────────────────
  /// Shown once on first launch (after auth, before dashboard) to request
  /// POST_NOTIFICATIONS + Notification Listener Access permissions.
  static const String notificationOnboardingPath = '/notification-onboarding';
  static const String notificationOnboardingName = 'notification-onboarding';

  // ─── Pending Transaction Review ────────────────────────────────────────────
  /// Deep-link target when user taps a system notification for an auto-detected transaction.
  /// [:transactionId] is the Firestore document ID of the pending transaction.
  static const String pendingReviewPath = '/pending-review/:transactionId';
  static const String pendingReviewName = 'pending-review';

  // ─── IPO Capital Hub & ASBA Engine ─────────────────────────────────────────
  static const String ipoHubPath = '/ipo-hub';
  static const String ipoHubName = 'ipo-hub';
}

