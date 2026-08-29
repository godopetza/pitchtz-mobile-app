import '../../domain/entities/fixture.dart';
import 'json.dart';

class FixtureDto {
  static Fixture fromJson(Map<String, dynamic> m) => Fixture(
        id: J.str(m, 'id'),
        sport: J.str(m, 'sport'),
        league: J.str(m, 'league'),
        country: J.str(m, 'country'),
        home: J.str(m, 'home'),
        away: J.str(m, 'away'),
        homeScore: J.str(m, 'home_score'),
        awayScore: J.str(m, 'away_score'),
        kickoffAt: J.date(m, 'kickoff_at') ?? DateTime(0),
        status: J.str(m, 'status'),
        live: J.boolean(m, 'live'),
        isFavorite: J.boolean(m, 'is_favorite'),
      );
}
