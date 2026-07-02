enum AnimalLeague {
  ant,
  squirrel,
  beaver,
  fox,
  owl,
  wolf,
  eagle,
  lion,
  elephant,
  dragon,
}

extension AnimalLeagueExtension on AnimalLeague {
  String get displayName {
    switch (this) {
      case AnimalLeague.ant: return 'Ant';
      case AnimalLeague.squirrel: return 'Squirrel';
      case AnimalLeague.beaver: return 'Beaver';
      case AnimalLeague.fox: return 'Fox';
      case AnimalLeague.owl: return 'Owl';
      case AnimalLeague.wolf: return 'Wolf';
      case AnimalLeague.eagle: return 'Eagle';
      case AnimalLeague.lion: return 'Lion';
      case AnimalLeague.elephant: return 'Elephant';
      case AnimalLeague.dragon: return 'Dragon';
    }
  }

  String get emoji {
    switch (this) {
      case AnimalLeague.ant: return '🐜';
      case AnimalLeague.squirrel: return '🐿️';
      case AnimalLeague.beaver: return '🦫';
      case AnimalLeague.fox: return '🦊';
      case AnimalLeague.owl: return '🦉';
      case AnimalLeague.wolf: return '🐺';
      case AnimalLeague.eagle: return '🦅';
      case AnimalLeague.lion: return '🦁';
      case AnimalLeague.elephant: return '🐘';
      case AnimalLeague.dragon: return '🐉';
    }
  }
}

class LeagueUtils {
  static AnimalLeague getLeagueForLevel(int level) {
    if (level <= 3) return AnimalLeague.ant;
    if (level <= 6) return AnimalLeague.squirrel;
    if (level <= 9) return AnimalLeague.beaver;
    if (level <= 12) return AnimalLeague.fox;
    if (level <= 15) return AnimalLeague.owl;
    if (level <= 18) return AnimalLeague.wolf;
    if (level <= 21) return AnimalLeague.eagle;
    if (level <= 24) return AnimalLeague.lion;
    if (level <= 27) return AnimalLeague.elephant;
    return AnimalLeague.dragon;
  }
}
