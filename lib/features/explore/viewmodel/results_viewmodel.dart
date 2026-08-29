import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/pitch.dart';
import '../../../domain/repositories/pitch_repository.dart';

enum ResultsView { list, map }

enum ResultsState { loading, ready, error }

class ResultsViewModel extends ChangeNotifier {
  ResultsViewModel(this._pitches);

  final PitchRepository _pitches;

  ResultsState _state = ResultsState.loading;
  String? _error;
  List<Pitch> _venues = [];

  ResultsState get state => _state;
  String? get error => _error;
  List<Pitch> get venues => _venues;
  int get resultCount => _venues.length;
  bool get isEmpty => _state == ResultsState.ready && _venues.isEmpty;

  Future<void> load() async {
    _state = ResultsState.loading;
    _error = null;
    notifyListeners();
    try {
      _venues = await _pitches.getVenues();
      _state = ResultsState.ready;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _state = ResultsState.error;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      _state = ResultsState.error;
    }
    notifyListeners();
  }

  ResultsView _view = ResultsView.list;
  ResultsView get view => _view;
  void setList() {
    _view = ResultsView.list;
    notifyListeners();
  }

  void setMap() {
    _view = ResultsView.map;
    notifyListeners();
  }

  String? _mapSel;
  String? get mapSel => _mapSel;
  bool get hasMapSel => _mapSel != null;
  Pitch? get mapSelPitch {
    if (_mapSel == null) return null;
    for (final v in _venues) {
      if (v.id == _mapSel) return v;
    }
    return null;
  }

  void selectPin(String id) {
    _mapSel = id;
    notifyListeners();
  }
}
