import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/pitch.dart';
import '../../../domain/repositories/city_repository.dart';
import '../../../domain/repositories/pitch_repository.dart';

enum HomeView { list, map }

enum ViewState { loading, ready, error }

class ExploreViewModel extends ChangeNotifier {
  ExploreViewModel(this._pitches, this._cities, this._toast);

  final PitchRepository _pitches;
  final CityRepository _cities;
  final ToastController _toast;

  // ---- Load state ----
  ViewState _state = ViewState.loading;
  String? _error;
  ViewState get state => _state;
  String? get error => _error;

  List<Pitch> _venues = [];
  List<City> _cities0 = [];
  City? _currentCity;

  List<Pitch> get venues => _venues;
  City? get currentCity => _currentCity;
  String get cityName => _currentCity?.name ?? 'Choose city';
  bool get isEmpty => _state == ViewState.ready && _venues.isEmpty;

  Future<void> load() async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _cities.getCities(),
        _pitches.getVenues(),
      ]);
      _cities0 = results[0] as List<City>;
      _currentCity = _cities0.firstWhere(
        (c) => c.live,
        orElse: () => _cities0.isNotEmpty
            ? _cities0.first
            : const City(id: '', name: 'Dar es Salaam', live: true),
      );
      _venues = results[1] as List<Pitch>;
      _state = ViewState.ready;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _state = ViewState.error;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // ---- Curated slices ----
  List<Pitch> get available => _venues;
  List<Pitch> get allVenues => _venues;

  List<Area> get areas {
    final counts = <String, int>{};
    for (final v in _venues) {
      if (v.area.isEmpty) continue;
      counts[v.area] = (counts[v.area] ?? 0) + 1;
    }
    return counts.entries.map((e) => Area(name: e.key, count: e.value)).toList();
  }

  // ---- Home view toggle ----
  HomeView _homeView = HomeView.list;
  HomeView get homeView => _homeView;
  void showMap() {
    _homeView = HomeView.map;
    _mapSel = null;
    notifyListeners();
  }

  void showList() {
    _homeView = HomeView.list;
    notifyListeners();
  }

  // ---- Filter chips (visual selection only; index-based so the selection
  // survives a language switch) ----
  final Set<int> _chipsOn = {0};
  bool isChipOn(int index) => _chipsOn.contains(index);
  void toggleChip(int index) {
    if (!_chipsOn.remove(index)) _chipsOn.add(index);
    notifyListeners();
  }

  // ---- Cities / waitlist ----
  List<City> get liveCities => _cities0.where((c) => c.live).toList();
  List<City> get waitlistCities => _cities0.where((c) => !c.live).toList();

  void selectCity(City c) {
    _currentCity = c;
    notifyListeners();
  }

  /// Joins a city's launch waitlist. The (localized) success copy comes from
  /// the view. Returns true on success.
  Future<bool> joinWaitlist(
    City city, {
    String? phone,
    String? email,
    required String successMessage,
  }) async {
    try {
      await _cities.joinWaitlist(cityId: city.id, phone: phone, email: email);
      _toast.show(successMessage);
      return true;
    } on ApiException catch (e) {
      _toast.show(e.userMessage);
      return false;
    }
  }

  // ---- Filter sheet options ----
  List<String> get filterAreas => _pitches.getFilterAreas();
  List<String> get filterAmenities => _pitches.getFilterAmenities();

  // ---- Gated actions (planned backend features). Copy is passed in from the
  // view so it is localized. ----
  void showComingSoon(String message) => _toast.show(message);

  // ---- Map state ----
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

  bool _mapSearchOpen = false;
  bool get mapSearchOpen => _mapSearchOpen;
  String _mapQuery = '';
  String get mapQueryLabel =>
      _mapQuery.isEmpty ? 'Search area, pitch or venue' : _mapQuery;
  bool get mapHasQuery => _mapQuery.isNotEmpty;

  void toggleMapSearch() {
    _mapSearchOpen = !_mapSearchOpen;
    notifyListeners();
  }

  void pickMapArea(String name) {
    _mapQuery = name;
    _mapSearchOpen = false;
    _mapSel = null;
    notifyListeners();
  }

  void pickMapVenue(Pitch v) {
    _mapQuery = v.name;
    _mapSearchOpen = false;
    _mapSel = v.id;
    notifyListeners();
  }
}
