import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/fixture.dart';
import '../../../domain/repositories/fixture_repository.dart';

enum ViewState { loading, ready, error }

/// Attribution required by LiveScore data terms.
const String liveScoreCredit = 'Data courtesy of LiveScore';

/// Drives the fixtures screen: loads, filters, groups, and polls live scores.
///
/// Filter setters call [load] automatically so the view only needs to bind
/// to the relevant getters and call [load] once on init.
class FixturesViewModel extends ChangeNotifier {
  FixturesViewModel(this._repo);

  final FixtureRepository _repo;

  // ── State ─────────────────────────────────────────────────────────────────

  ViewState _state = ViewState.loading;
  String _error = '';

  List<Fixture> _fixtures = [];
  String _selectedSport = 'all'; // 'all' | 'football' | 'basketball'
  String? _selectedDate;          // 'YYYY-MM-DD' or null for today
  String? _selectedLeague;

  Map<String, dynamic> _fixtureDetail = {};

  Timer? _pollTimer;

  // ── Getters ───────────────────────────────────────────────────────────────

  ViewState get state => _state;
  String get error => _error;

  String get selectedSport => _selectedSport;
  String? get selectedDate => _selectedDate;
  String? get selectedLeague => _selectedLeague;

  Map<String, dynamic> get fixtureDetail => _fixtureDetail;

  // Filtered fixture list (sport + league already applied server-side; we keep
  // a client-side sport guard for any cached data mismatch).
  List<Fixture> get _filtered {
    if (_selectedSport == 'all') return _fixtures;
    return _fixtures
        .where((f) => f.sport.toLowerCase() == _selectedSport)
        .toList();
  }

  List<Fixture> get liveFixtures =>
      _filtered.where((f) => f.live).toList();

  List<Fixture> get favoriteFixtures =>
      _filtered.where((f) => f.isFavorite).toList();

  List<Fixture> get upcomingFixtures {
    final now = DateTime.now();
    return _filtered
        .where((f) => !f.live && f.kickoffAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.kickoffAt.compareTo(b.kickoffAt));
  }

  List<Fixture> get pastFixtures {
    final now = DateTime.now();
    return _filtered
        .where((f) => !f.live && !f.kickoffAt.isAfter(now))
        .toList()
      ..sort((a, b) => b.kickoffAt.compareTo(a.kickoffAt));
  }

  bool get hasLive => liveFixtures.isNotEmpty;

  // ── Filter setters ────────────────────────────────────────────────────────

  void setSport(String sport) {
    _selectedSport = sport;
    notifyListeners();
    load();
  }

  void setDate(String? date) {
    _selectedDate = date;
    notifyListeners();
    load();
  }

  void setLeague(String? league) {
    _selectedLeague = league;
    notifyListeners();
    load();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  /// Fetches fixtures from the repository using the current filter state.
  /// Kicks off or stops the live-score polling timer based on results.
  Future<void> load() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _fixtures = await _repo.getFixtures(
        sport: _selectedSport == 'all' ? null : _selectedSport,
        league: _selectedLeague,
        date: _selectedDate,
      );
      _state = ViewState.ready;
      _managePollTimer();
    } on ApiException catch (e) {
      _error = e.userMessage;
      _state = ViewState.error;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  // ── Detail ────────────────────────────────────────────────────────────────

  /// Fetches the raw detail map for a single fixture (structure varies by sport).
  Future<void> loadDetail(String fixtureId) async {
    try {
      _fixtureDetail = await _repo.getFixtureDetail(fixtureId);
      notifyListeners();
    } on ApiException {
      // Silently swallow; callers can inspect [fixtureDetail] being empty.
    } catch (_) {
      // Non-critical — detail panel shows empty state.
    }
  }

  // ── Polling ───────────────────────────────────────────────────────────────

  void _managePollTimer() {
    if (hasLive) {
      _pollTimer ??= Timer.periodic(const Duration(seconds: 60), (_) async {
        // Reload silently — only update data, don't flash loading state.
        try {
          final refreshed = await _repo.getFixtures(
            sport: _selectedSport == 'all' ? null : _selectedSport,
            league: _selectedLeague,
            date: _selectedDate,
          );
          _fixtures = refreshed;
          if (!hasLive) _stopPollTimer();
          notifyListeners();
        } catch (_) {
          // Polling failures are non-fatal; next tick will retry.
        }
      });
    } else {
      _stopPollTimer();
    }
  }

  void _stopPollTimer() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _stopPollTimer();
    super.dispose();
  }
}
