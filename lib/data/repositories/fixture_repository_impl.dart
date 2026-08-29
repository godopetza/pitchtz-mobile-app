import '../../core/network/api_client.dart';
import '../../domain/entities/fixture.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../models/fixture_dto.dart';

/// Real implementation backed by the live `/fixtures` endpoints.
class FixtureRepositoryImpl implements FixtureRepository {
  const FixtureRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Fixture>> getFixtures({
    String? sport,
    String? league,
    String? date,
  }) async {
    final raw = await _api.getList(
      '/fixtures',
      query: {
        if (sport != null) 'sport': sport,
        if (league != null) 'league': league,
        if (date != null) 'date': date,
      },
    );
    return raw
        .whereType<Map<String, dynamic>>()
        .map(FixtureDto.fromJson)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getFixtureDetail(String fixtureId) =>
      _api.getObject('/fixtures/$fixtureId/detail');
}
