import '../entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  /// Fetches the current leaderboard, optionally accepting the user's current XP
  /// so that simulated or scaled leaderboards can adjust accordingly.
  Future<List<LeaderboardEntry>> getLeaderboard(int userXp);
}
