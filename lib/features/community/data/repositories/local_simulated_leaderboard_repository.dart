import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

class LocalSimulatedLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<List<LeaderboardEntry>> getLeaderboard(int userXp) async {
    // Artificial delay to simulate network fetch
    await Future.delayed(const Duration(milliseconds: 300));

    // Dynamic XP scaling for bots to keep competition engaging but fair
    // Minimum XP boundaries ensure bots don't have negative XP early on
    final List<LeaderboardEntry> entries = [
      LeaderboardEntry(
        id: 'user',
        name: 'Mithil (You)',
        xp: userXp,
        level: (userXp / 50).floor() + 1,
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        id: 'bot_alpha',
        name: 'Finny Alpha',
        xp: userXp + 120, // Always slightly ahead
        level: (userXp / 50).floor() + 1,
        isBot: true,
      ),
      LeaderboardEntry(
        id: 'bot_saver_07',
        name: 'Saver_07',
        xp: (userXp - 50).clamp(0, 99999), // Always slightly behind
        level: ((userXp / 50).floor() + 1) > 1 ? (userXp / 50).floor() : 1,
        isBot: true,
      ),
      LeaderboardEntry(
        id: 'bot_thrifty',
        name: 'ThriftyGuru',
        xp: userXp + 45, // Close competition
        level: (userXp / 50).floor() + 1,
        isBot: true,
      ),
      LeaderboardEntry(
        id: 'bot_omega',
        name: 'Finny Omega',
        xp: (userXp - 15).clamp(0, 99999), // Very close behind
        level: (userXp / 50).floor() + 1,
        isBot: true,
      ),
    ];

    // Sort descending by XP
    entries.sort((a, b) => b.xp.compareTo(a.xp));
    return entries;
  }
}
