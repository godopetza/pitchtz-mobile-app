/// The player's own team card on the Teams screen.
class MyTeam {
  const MyTeam({
    required this.name,
    required this.league,
    required this.rank,
    required this.stats,
  });

  final String name;
  final String league;
  final String rank;
  final List<TeamStat> stats;
}

class TeamStat {
  const TeamStat(this.label, this.value);
  final String label;
  final String value;
}

/// A row in the league standings.
class StandingRow {
  const StandingRow({
    required this.position,
    required this.team,
    required this.points,
    this.highlighted = false,
  });

  final String position;
  final String team;
  final String points;
  final bool highlighted;
}

/// An open inter-team challenge near the player.
class Challenge {
  const Challenge({
    required this.id,
    required this.team,
    required this.meta,
    required this.when,
  });

  final int id;
  final String team;
  final String meta; // "5-a-side · Intermediate"
  final String when; // "Sat 6:00 PM · Mikocheni Arena"
}

/// A team currently recruiting players.
class JoinableTeam {
  const JoinableTeam({
    required this.id,
    required this.tag,
    required this.team,
    required this.needs,
    required this.meta,
  });

  final String id;
  final String tag; // "SU"
  final String team;
  final String needs; // "Needs 2 players"
  final String meta;
}

/// Fantasy Premier League linkage summary.
class FplInfo {
  const FplInfo({required this.linked});
  final bool linked;

  String get subtitle => linked
      ? 'Linked · you are 14th of 1,208'
      : 'Link your FPL team · league code PITCHTZ';
  String get action => linked ? 'View table ›' : 'Link ›';
}
