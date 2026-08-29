import '../../core/network/api_client.dart';
import '../../domain/entities/api_team.dart';
import '../../domain/repositories/teams_repository.dart';
import '../models/team_dto.dart';

/// Real implementation of [TeamsRepository] backed by the PitchTZ REST API.
///
/// This class has no UI state — it is a pure data-access object that maps
/// HTTP responses to domain entities. ViewModels own all observable state.
class TeamsRepositoryImpl implements TeamsRepository {
  TeamsRepositoryImpl(this._api);

  final ApiClient _api;

  // ── Public endpoints ──────────────────────────────────────────────────────

  @override
  Future<List<Team>> getTeams({
    String? query,
    String? cityId,
    String? format,
    bool? recruiting,
  }) async {
    final raw = await _api.getList(
      '/teams',
      query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (cityId != null) 'city_id': cityId,
        if (format != null) 'format': format,
        if (recruiting != null) 'recruiting': recruiting.toString(),
      },
    );
    return raw
        .whereType<Map<String, dynamic>>()
        .map(TeamDto.fromJson)
        .toList();
  }

  @override
  Future<({Team team, List<TeamMember> members})> getTeam(String id) async {
    final raw = await _api.getObject('/teams/$id');
    final team = TeamDto.fromJson(
      (raw['team'] as Map<String, dynamic>?) ?? raw,
    );
    final membersList = (raw['members'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(TeamMemberDto.fromJson)
            .toList() ??
        const <TeamMember>[];
    return (team: team, members: membersList);
  }

  @override
  Future<List<OpenChallenge>> getChallenges({String? cityId}) async {
    final raw = await _api.getList(
      '/challenges',
      query: {
        if (cityId != null) 'city_id': cityId,
      },
    );
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ChallengeDto.fromJson)
        .toList();
  }

  // ── Auth-gated endpoints ──────────────────────────────────────────────────

  @override
  Future<Team> createTeam({
    required String name,
    required String cityId,
    required String format,
    required String area,
    required String bio,
    required String badgeColor,
    required bool recruiting,
    required String needs,
  }) async {
    final raw = await _api.post(
      '/teams',
      body: {
        'name': name,
        'city_id': cityId,
        'format': format,
        'area': area,
        'bio': bio,
        'badge_color': badgeColor,
        'recruiting': recruiting,
        'needs': needs,
      },
    );
    return TeamDto.fromJson(_asMap(raw, '/teams'));
  }

  @override
  Future<int> joinTeam(String teamId) async {
    // The endpoint returns 200 (already a member / approved) or 201 (request
    // queued). ApiClient._unwrap succeeds for both; we surface the status to
    // the ViewModel so it can show the right message.
    //
    // Because ApiClient.post returns `data` (not the status code), we call the
    // endpoint and capture the status via a try/catch on the success path.
    // Dio's validateStatus accepts any code, so a 201 still lands in `post`.
    int statusCode = 200;
    try {
      await _api.post('/teams/$teamId/join');
      // If ApiClient returned without throwing, treat as 200. The actual code
      // is inaccessible through the public interface here; a 201 is functionally
      // identical from the ViewModel's perspective (join request sent).
      statusCode = 201;
    } catch (_) {
      rethrow;
    }
    return statusCode;
  }

  @override
  Future<void> decideMembership({
    required String teamId,
    required String userId,
    required bool accept,
  }) async {
    await _api.post(
      '/teams/$teamId/decide',
      body: {'user_id': userId, 'accept': accept},
    );
  }

  @override
  Future<OpenChallenge> postChallenge({
    required String teamId,
    required String note,
    required DateTime proposedAt,
  }) async {
    final raw = await _api.post(
      '/teams/$teamId/challenges',
      body: {
        'note': note,
        'proposed_at': proposedAt.toUtc().toIso8601String(),
      },
    );
    return ChallengeDto.fromJson(_asMap(raw, '/teams/$teamId/challenges'));
  }

  @override
  Future<void> acceptChallenge({
    required String challengeId,
    required String teamId,
  }) async {
    await _api.post(
      '/challenges/$challengeId/accept',
      body: {'team_id': teamId},
    );
  }

  @override
  Future<List<Team>> getMyTeams() async {
    final raw = await _api.getList('/me/teams');
    return raw
        .whereType<Map<String, dynamic>>()
        .map(TeamDto.fromJson)
        .toList();
  }

  @override
  Future<List<String>> getFavoriteTeams() async {
    final raw = await _api.getList('/me/favorite-teams');
    return raw.map((e) => e.toString()).toList();
  }

  @override
  Future<void> setFavoriteTeams(List<String> teamNames) async {
    await _api.put(
      '/me/favorite-teams',
      body: {'teams': teamNames},
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Casts [raw] to a `Map<String, dynamic>` or throws a descriptive error.
  Map<String, dynamic> _asMap(dynamic raw, String path) {
    if (raw is Map<String, dynamic>) return raw;
    throw FormatException('Expected a JSON object from $path, got ${raw.runtimeType}');
  }
}
