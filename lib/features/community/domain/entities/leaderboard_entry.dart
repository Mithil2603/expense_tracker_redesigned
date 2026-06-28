class LeaderboardEntry {
  final String id;
  final String name;
  final int xp;
  final int level;
  final bool isCurrentUser;
  final bool isBot;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.xp,
    required this.level,
    this.isCurrentUser = false,
    this.isBot = false,
  });
}
