import '../entities/api_team.dart';

/// Contract for all teams-related API interactions.
///
/// Every method maps 1-to-1 to an endpoint documented in the PitchTZ
/// OpenAPI contract. Auth-gated methods will throw [ApiException] with
/// a 401 status when called without a valid session.
abstract class TeamsRepository {
  // ── Public endpoints ──────────────────────────────────────────────────────

  /// GET /teams?q=&city_id=&format=&recruiting=
  ///
  /// Returns all teams, optionally filtered. Any null parameter is omitted
  /// from the query string.
  Future<List<Team>> getTeams({
    String? query,
    String? cityId,
    String? format,
    bool? recruiting,
  });

  /// GET /teams/:id
  ///
  /// Returns the team detail together with its full member roster.
  Future<({Team team, List<TeamMember> members})> getTeam(String id);

  /// GET /challenges?city_id=
  ///
  /// Returns open challenges, optionally filtered by city.
  Future<List<OpenChallenge>> getChallenges({String? cityId});

  // ── Auth-gated endpoints ──────────────────────────────────────────────────

  /// POST /teams
  ///
  /// Creates a new team. The signed-in user becomes the captain.
  Future<Team> createTeam({
    required String name,
    required String cityId,
    required String format,
    required String area,
    required String bio,
    required String badgeColor,
    required bool recruiting,
    required String needs,
  });

  /// POST /teams/:id/join
  ///
  /// Sends a join request (or confirms, depending on server logic).
  /// Returns the HTTP status code (200 or 201) for the caller to act on.
  Future<int> joinTeam(String teamId);

  /// POST /teams/:id/decide
  ///
  /// Accepts or rejects a pending join request. Captain only.
  Future<void> decideMembership({
    required String teamId,
    required String userId,
    required bool accept,
  });

  /// POST /teams/:id/challenges
  ///
  /// Posts an open challenge on behalf of the team. Captain only.
  Future<OpenChallenge> postChallenge({
    required String teamId,
    required String note,
    required DateTime proposedAt,
  });

  /// POST /challenges/:id/accept
  ///
  /// Accepts an open challenge, pairing [teamId] against the challenger.
  /// Captain only.
  Future<void> acceptChallenge({
    required String challengeId,
    required String teamId,
  });

  /// GET /me/teams
  ///
  /// Returns all teams the authenticated user belongs to (any status).
  Future<List<Team>> getMyTeams();

  /// GET /me/favorite-teams
  ///
  /// Returns the list of favourite team names for the authenticated user.
  Future<List<String>> getFavoriteTeams();

  /// PUT /me/favorite-teams
  ///
  /// Replaces the authenticated user's favourite-team list.
  Future<void> setFavoriteTeams(List<String> teamNames);
}
