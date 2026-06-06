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

  // ─── Sub-routes / Detail Screens ───────────────────────────────────────────
  static const String addExpensePath = 'add-expense';
  static const String addExpenseName = 'add-expense';

  static const String editExpensePath = 'edit-expense';
  static const String editExpenseName = 'edit-expense';

  // ─── Authentication ────────────────────────────────────────────────────────
  static const String authPath = '/auth';
  static const String authName = 'auth';
}
