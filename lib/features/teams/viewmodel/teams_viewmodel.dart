import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../domain/entities/api_team.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/teams_repository.dart';

// ── ViewState ──────────────────────────────────────────────────────────────────

enum ViewState { loading, ready, error }

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// Owns all observable state for the Teams tab.
///
/// Wired to the real REST API via [TeamsRepository]. Auth-gated operations
/// check [_auth.isSignedIn] and emit [needsSignIn] = true so the view can
/// prompt the player to log in instead of throwing.
class TeamsViewModel extends ChangeNotifier {
  TeamsViewModel(this._repo, this._toast, this._auth) {
    _auth.addListener(_onAuthChanged);
  }

  final TeamsRepository _repo;
  final ToastController _toast;
  final AuthRepository _auth;

  // ── ViewState ──────────────────────────────────────────────────────────────

  ViewState _state = ViewState.loading;
  ViewState get state => _state;
  bool get isLoading => _state == ViewState.loading;
  bool get isReady => _state == ViewState.ready;
  bool get hasError => _state == ViewState.error;

  String? _error;
  String? get error => _error;

  // ── Auth guard ─────────────────────────────────────────────────────────────

  /// Flipped to true when an auth-gated action is attempted while signed out.
  /// The view should observe this and show a sign-in prompt, then reset it.
  bool _needsSignIn = false;
  bool get needsSignIn => _needsSignIn;

  void clearNeedsSignIn() {
    _needsSignIn = false;
    notifyListeners();
  }

  bool get _isAuthenticated => _auth.isSignedIn;

  /// Returns true if the caller should proceed; false means the view should
  /// show the sign-in prompt (needsSignIn has been set to true).
  bool _requireAuth() {
    if (_isAuthenticated) return true;
    _needsSignIn = true;
    notifyListeners();
    return false;
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  List<Team> _publicTeams = const [];
  List<Team> get publicTeams => _publicTeams;

  List<Team> _myTeams = const [];
  List<Team> get myTeams => _myTeams;

  List<OpenChallenge> _challenges = const [];
  List<OpenChallenge> get challenges => _challenges;

  List<String> _favoriteTeams = const [];
  List<String> get favoriteTeams => _favoriteTeams;

  // ── Mutation trackers (optimistic UI) ─────────────────────────────────────

  final Set<String> _joinRequested = {};
  final Set<String> _challengesSent = {};

  bool isJoinRequested(String teamId) => _joinRequested.contains(teamId);
  bool isChallengeSent(String teamId) => _challengesSent.contains(teamId);

  // ── 1. Load my teams: GET /me/teams ───────────────────────────────────────

  Future<void> loadMyTeams() async {
    if (!_requireAuth()) return;
    _setLoading();
    try {
      final results = await Future.wait([
        _repo.getMyTeams(),
        _repo.getFavoriteTeams(),
      ]);
      _myTeams = results[0] as List<Team>;
      _favoriteTeams = results[1] as List<String>;
      _setReady();
    } on ApiException catch (e) {
      _setError(_guardedUserMessage(e));
    } catch (e) {
      _setError('Could not load your teams. Please try again.');
    }
  }

  // ── 2. Load open challenges: GET /challenges?city_id=<current> ────────────

  Future<void> loadChallenges({String? cityId}) async {
    _setLoading();
    try {
      _challenges = await _repo.getChallenges(cityId: cityId);
      _setReady();
    } on ApiException catch (e) {
      _setError(e.userMessage);
    } catch (e) {
      _setError('Could not load challenges. Please try again.');
    }
  }

  // ── 3. Load public teams: GET /teams ──────────────────────────────────────

  Future<void> loadPublicTeams({
    String? query,
    String? cityId,
    String? format,
    bool? recruiting,
  }) async {
    _setLoading();
    try {
      _publicTeams = await _repo.getTeams(
        query: query,
        cityId: cityId,
        format: format,
        recruiting: recruiting,
      );
      _setReady();
    } on ApiException catch (e) {
      _setError(e.userMessage);
    } catch (e) {
      _setError('Could not load teams. Please try again.');
    }
  }

  /// Convenience: loads public teams + open challenges in parallel.
  Future<void> loadPublic({
    String? query,
    String? cityId,
    String? format,
    bool? recruiting,
  }) async {
    _setLoading();
    try {
      final results = await Future.wait([
        _repo.getTeams(
          query: query,
          cityId: cityId,
          format: format,
          recruiting: recruiting,
        ),
        _repo.getChallenges(cityId: cityId),
      ]);
      _publicTeams = results[0] as List<Team>;
      _challenges = results[1] as List<OpenChallenge>;
      _setReady();
    } on ApiException catch (e) {
      _setError(e.userMessage);
    } catch (e) {
      _setError('Could not load teams. Please try again.');
    }
  }

  // ── 4. createTeam → POST /teams ───────────────────────────────────────────

  /// Creates a new team. The signed-in player becomes the captain.
  ///
  /// Returns the newly created [Team] on success, or null if the request
  /// failed (an error toast is shown automatically).
  Future<Team?> createTeam({
    required String name,
    required String cityId,
    required String format,
    required String area,
    required String bio,
    required String badgeColor,
    required bool recruiting,
    required String needs,
  }) async {
    if (!_requireAuth()) return null;
    try {
      final team = await _repo.createTeam(
        name: name,
        cityId: cityId,
        format: format,
        area: area,
        bio: bio,
        badgeColor: badgeColor,
        recruiting: recruiting,
        needs: needs,
      );
      // Prepend to my teams list so it appears immediately.
      _myTeams = [team, ..._myTeams];
      _toast.show('Team "$name" created!');
      notifyListeners();
      return team;
    } on ApiException catch (e) {
      _toast.show(_guardedUserMessage(e));
      return null;
    } catch (e) {
      _toast.show('Could not create team. Please try again.');
      return null;
    }
  }

  // ── 5. joinTeam → POST /teams/:id/join ────────────────────────────────────

  /// Sends a join request (or confirms membership) for [teamId].
  /// Shows a contextual toast based on the response status code.
  Future<void> joinTeam(String teamId) async {
    if (!_requireAuth()) return;
    if (_joinRequested.contains(teamId)) return;
    try {
      final statusCode = await _repo.joinTeam(teamId);
      _joinRequested.add(teamId);
      final message =
          statusCode == 200 ? 'You have joined the team!' : 'Join request sent!';
      _toast.show(message);
      notifyListeners();
    } on ApiException catch (e) {
      _toast.show(_guardedUserMessage(e));
    } catch (e) {
      _toast.show('Could not send join request. Please try again.');
    }
  }

  // ── 6. postChallenge → POST /teams/:id/challenges ─────────────────────────

  /// Posts an open challenge on behalf of [teamId]. Captain only.
  Future<void> postChallenge({
    required String teamId,
    required String note,
    required DateTime proposedAt,
  }) async {
    if (!_requireAuth()) return;
    if (_challengesSent.contains(teamId)) return;
    try {
      final challenge = await _repo.postChallenge(
        teamId: teamId,
        note: note,
        proposedAt: proposedAt,
      );
      _challengesSent.add(teamId);
      // Prepend so it shows at the top of the live challenge feed.
      _challenges = [challenge, ..._challenges];
      _toast.show('Challenge posted!');
      notifyListeners();
    } on ApiException catch (e) {
      _toast.show(_guardedUserMessage(e));
    } catch (e) {
      _toast.show('Could not post challenge. Please try again.');
    }
  }

  // ── 7. acceptChallenge → POST /challenges/:id/accept ──────────────────────

  /// Accepts an open challenge, pairing [myTeamId] against the challenger.
  /// Captain only. Removes the accepted challenge from the local list on
  /// success.
  Future<void> acceptChallenge({
    required String challengeId,
    required String myTeamId,
  }) async {
    if (!_requireAuth()) return;
    try {
      await _repo.acceptChallenge(
        challengeId: challengeId,
        teamId: myTeamId,
      );
      // Remove the now-matched challenge from the open list.
      _challenges =
          _challenges.where((c) => c.id != challengeId).toList();
      _toast.show('Challenge accepted!');
      notifyListeners();
    } on ApiException catch (e) {
      _toast.show(_guardedUserMessage(e));
    } catch (e) {
      _toast.show('Could not accept challenge. Please try again.');
    }
  }

  // ── 8. loadFavoriteTeams → GET /me/favorite-teams ─────────────────────────

  Future<void> loadFavoriteTeams() async {
    if (!_requireAuth()) return;
    try {
      _favoriteTeams = await _repo.getFavoriteTeams();
      notifyListeners();
    } on ApiException catch (e) {
      _toast.show(_guardedUserMessage(e));
    } catch (e) {
      _toast.show('Could not load favourites. Please try again.');
    }
  }

  // ── 9. saveFavoriteTeams → PUT /me/favorite-teams ─────────────────────────

  Future<void> saveFavoriteTeams(List<String> teamNames) async {
    if (!_requireAuth()) return;
    final previous = List<String>.from(_favoriteTeams);
    // Optimistic update.
    _favoriteTeams = List<String>.from(teamNames);
    notifyListeners();
    try {
      await _repo.setFavoriteTeams(teamNames);
    } on ApiException catch (e) {
      // Rollback on failure.
      _favoriteTeams = previous;
      notifyListeners();
      _toast.show(_guardedUserMessage(e));
    } catch (e) {
      _favoriteTeams = previous;
      notifyListeners();
      _toast.show('Could not save favourites. Please try again.');
    }
  }

  /// Toggles a single team name in the favourites list and persists via API.
  Future<void> toggleFavorite(String teamName) async {
    final updated = List<String>.from(_favoriteTeams);
    if (updated.contains(teamName)) {
      updated.remove(teamName);
    } else {
      updated.add(teamName);
    }
    await saveFavoriteTeams(updated);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _setLoading() {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
  }

  void _setReady() {
    _state = ViewState.ready;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = ViewState.error;
    _error = message;
    notifyListeners();
  }

  /// Maps a 401 [ApiException] to a sign-in prompt; returns the normal user
  /// message for all other errors.
  String _guardedUserMessage(ApiException e) {
    if (e.statusCode == 401) {
      _needsSignIn = true;
      return 'Please sign in to continue.';
    }
    return e.userMessage;
  }

  void _onAuthChanged() {
    // When the player signs out, clear private data immediately.
    if (!_auth.isSignedIn) {
      _myTeams = const [];
      _favoriteTeams = const [];
      _joinRequested.clear();
      _challengesSent.clear();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
