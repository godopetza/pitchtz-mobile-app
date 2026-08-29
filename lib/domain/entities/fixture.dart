class Fixture {
  const Fixture({
    required this.id,
    required this.sport,
    required this.league,
    required this.country,
    required this.home,
    required this.away,
    required this.homeScore,
    required this.awayScore,
    required this.kickoffAt,
    required this.status,
    required this.live,
    required this.isFavorite,
  });

  final String id;
  final String sport;       // football | basketball | tennis …
  final String league;      // "Ligi Kuu Bara"
  final String country;
  final String home;
  final String away;
  final String homeScore;
  final String awayScore;
  final DateTime kickoffAt;
  final String status;      // NS | 1H | HT | 2H | FT …
  final bool live;
  final bool isFavorite;
}
