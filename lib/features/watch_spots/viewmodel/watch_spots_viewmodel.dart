import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/watch_spot.dart';
import '../../../domain/repositories/watch_spot_repository.dart';

enum ViewState { loading, ready, error }

/// Drives the Watch Spots screen: lists nearby venues that screen live sport,
/// and allows fans / bar owners to apply to be listed.
class WatchSpotsViewModel extends ChangeNotifier {
  WatchSpotsViewModel(this._repo);

  final WatchSpotRepository _repo;

  // ── State ─────────────────────────────────────────────────────────────────

  ViewState _state = ViewState.loading;
  String _error = '';

  List<WatchSpot> _spots = [];
  bool _submitting = false;
  String? _submitError;
  bool _submitSuccess = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  ViewState get state => _state;
  String get error => _error;

  List<WatchSpot> get spots => List.unmodifiable(_spots);

  bool get submitting => _submitting;
  String? get submitError => _submitError;
  bool get submitSuccess => _submitSuccess;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _spots = await _repo.getWatchSpots();
      _state = ViewState.ready;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _state = ViewState.error;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  // ── Application ───────────────────────────────────────────────────────────

  /// Submits a watch-spot listing application.
  ///
  /// Returns `true` on success, `false` on failure. The view can read
  /// [submitError] for a user-facing message on failure.
  Future<bool> submitApplication({
    required String name,
    required String area,
    required String contactName,
    required String contactPhone,
    required String address,
    required double lat,
    required double lng,
    required int screens,
    required int entry,
    required List<String> features,
  }) async {
    _submitting = true;
    _submitError = null;
    _submitSuccess = false;
    notifyListeners();

    try {
      await _repo.applyWatchSpot(
        name: name,
        area: area,
        contactName: contactName,
        contactPhone: contactPhone,
        address: address,
        latitude: lat,
        longitude: lng,
        screens: screens,
        entryTzs: entry,
        features: features,
      );
      _submitSuccess = true;
      _submitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _submitError = e.userMessage;
      _submitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _submitError = 'Could not submit application. Please try again.';
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Resets submission state so the form can be re-used without remounting.
  void resetSubmission() {
    _submitError = null;
    _submitSuccess = false;
    notifyListeners();
  }
}
