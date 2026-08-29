import '../entities/fixture.dart';

abstract class FixtureRepository {
  // GET /fixtures?sport=&league=&date=YYYY-MM-DD
  Future<List<Fixture>> getFixtures({String? sport, String? league, String? date});

  // GET /fixtures/:id/detail — returns raw dynamic (structure varies by sport)
  Future<Map<String, dynamic>> getFixtureDetail(String fixtureId);
}
