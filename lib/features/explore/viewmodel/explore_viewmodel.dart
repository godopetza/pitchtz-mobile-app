import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/pitch.dart';
import '../../../domain/repositories/city_repository.dart';
import '../../../domain/repositories/pitch_repository.dart';

enum HomeView { list, map }

enum ViewState { loading, ready, error }

/// A Places API (New) autocomplete suggestion.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
  final String placeId;
  final String mainText;
  final String secondaryText;
}

class ExploreViewModel extends ChangeNotifier {
  ExploreViewModel(this._pitches, this._cities, this._toast);

  final PitchRepository _pitches;
  final CityRepository _cities;
  final ToastController _toast;

  static const _mapsApiKey = 'AIzaSyAz7McqqrKhEB-D4BPWEuQuXmLe4Zu6Llg';
  static const _placesBaseUrl = 'https://places.googleapis.com/v1';

  // Dar es Salaam default centre
  static const LatLng _dsm = LatLng(-6.7924, 39.2083);

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

  // ---- Filter chips ----
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
    _mapSel = (_mapSel == id) ? null : id; // tap again to dismiss
    notifyListeners();
  }

  void clearMapSel() {
    _mapSel = null;
    notifyListeners();
  }

  // ---- User location (set by the map view after permission granted) ----
  LatLng _userLocation = _dsm;
  LatLng get userLocation => _userLocation;

  void setUserLocation(LatLng pos) {
    _userLocation = pos;
    notifyListeners();
  }

  // ---- Camera target (drives map movement from the viewmodel) ----
  LatLng? _cameraTarget;
  double _cameraZoom = 13.5;
  LatLng? get cameraTarget => _cameraTarget;
  double get cameraZoom => _cameraZoom;

  void _moveCameraTo(LatLng target, {double zoom = 15}) {
    _cameraTarget = target;
    _cameraZoom = zoom;
    notifyListeners();
  }

  void cameraConsumed() {
    _cameraTarget = null;
  }

  // ---- Map search / Places autocomplete ----
  bool _mapSearchOpen = false;
  bool get mapSearchOpen => _mapSearchOpen;

  String _mapQuery = '';
  String get mapQueryLabel =>
      _mapQuery.isEmpty ? 'Search area, pitch or venue' : _mapQuery;
  bool get mapHasQuery => _mapQuery.isNotEmpty;

  List<PlaceSuggestion> _suggestions = [];
  List<PlaceSuggestion> get suggestions => _suggestions;
  bool _suggestionsLoading = false;
  bool get suggestionsLoading => _suggestionsLoading;

  Timer? _debounce;

  void toggleMapSearch() {
    _mapSearchOpen = !_mapSearchOpen;
    if (!_mapSearchOpen) {
      _suggestions = [];
      _mapQuery = '';
    }
    notifyListeners();
  }

  void openMapSearch() {
    _mapSearchOpen = true;
    notifyListeners();
  }

  void closeMapSearch() {
    _mapSearchOpen = false;
    _suggestions = [];
    _mapQuery = '';
    notifyListeners();
  }

  /// Called when the user types in the search box.
  void onSearchChanged(String query) {
    _mapQuery = query;
    notifyListeners();
    _debounce?.cancel();
    if (query.trim().length < 2) {
      _suggestions = [];
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _fetchSuggestions(query));
  }

  Future<void> _fetchSuggestions(String input) async {
    _suggestionsLoading = true;
    notifyListeners();
    try {
      final dio = Dio();
      final resp = await dio.post(
        '$_placesBaseUrl/places:autocomplete',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _mapsApiKey,
        }),
        data: {
          'input': input,
          'locationBias': {
            'circle': {
              'center': {
                'latitude': _userLocation.latitude,
                'longitude': _userLocation.longitude,
              },
              'radius': 60000.0,
            },
          },
          'includedRegionCodes': ['tz'],
        },
      );
      final raw = resp.data as Map<String, dynamic>;
      final list = (raw['suggestions'] as List? ?? []);
      _suggestions = list.map((s) {
        final pred = s['placePrediction'] as Map<String, dynamic>? ?? {};
        final sf = pred['structuredFormat'] as Map<String, dynamic>? ?? {};
        final main = (sf['mainText'] as Map?)?['text'] as String? ?? '';
        final sec = (sf['secondaryText'] as Map?)?['text'] as String? ?? '';
        return PlaceSuggestion(
          placeId: pred['placeId'] as String? ?? '',
          mainText: main,
          secondaryText: sec,
        );
      }).where((s) => s.placeId.isNotEmpty).toList();
    } catch (e) {
      debugPrint('Places autocomplete error: $e');
      _suggestions = [];
    } finally {
      _suggestionsLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the lat/lng of a place and moves the map camera to it.
  Future<void> selectSuggestion(PlaceSuggestion s) async {
    _mapQuery = s.mainText;
    _mapSearchOpen = false;
    _suggestions = [];
    notifyListeners();
    try {
      final dio = Dio();
      final resp = await dio.get(
        '$_placesBaseUrl/places/${s.placeId}',
        options: Options(headers: {
          'X-Goog-Api-Key': _mapsApiKey,
          'X-Goog-FieldMask': 'id,location',
        }),
      );
      final data = resp.data as Map<String, dynamic>;
      final loc = data['location'] as Map<String, dynamic>?;
      if (loc != null) {
        final lat = (loc['latitude'] as num).toDouble();
        final lng = (loc['longitude'] as num).toDouble();
        _moveCameraTo(LatLng(lat, lng), zoom: 15);
      }
    } catch (e) {
      debugPrint('Place detail error: $e');
    }
  }

  void pickMapArea(String name) {
    _mapQuery = name;
    _mapSearchOpen = false;
    _mapSel = null;
    _suggestions = [];
    notifyListeners();
    // Try to find the area centre from our venue coords
    final inArea = _venues.where((v) =>
        v.area.toLowerCase() == name.toLowerCase() &&
        v.latitude != null &&
        v.longitude != null);
    if (inArea.isNotEmpty) {
      final lat =
          inArea.map((v) => v.latitude!).reduce((a, b) => a + b) / inArea.length;
      final lng =
          inArea.map((v) => v.longitude!).reduce((a, b) => a + b) / inArea.length;
      _moveCameraTo(LatLng(lat, lng), zoom: 14);
    }
  }

  void pickMapVenue(Pitch v) {
    _mapQuery = v.name;
    _mapSearchOpen = false;
    _suggestions = [];
    _mapSel = v.id;
    notifyListeners();
    if (v.latitude != null && v.longitude != null) {
      _moveCameraTo(LatLng(v.latitude!, v.longitude!), zoom: 16);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
