import '../../core/network/api_client.dart';
import '../../domain/entities/watch_spot.dart';
import '../../domain/repositories/watch_spot_repository.dart';
import '../models/watch_spot_dto.dart';

/// Real implementation backed by the live `/watch-spots` endpoint.
class WatchSpotRepositoryImpl implements WatchSpotRepository {
  const WatchSpotRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<WatchSpot>> getWatchSpots() async {
    final raw = await _api.getList('/watch-spots');
    return raw
        .whereType<Map<String, dynamic>>()
        .map(WatchSpotDto.fromJson)
        .toList();
  }

  @override
  Future<void> applyWatchSpot({
    required String name,
    required String area,
    required String contactName,
    required String contactPhone,
    required String address,
    required double latitude,
    required double longitude,
    required int screens,
    required int entryTzs,
    required List<String> features,
  }) =>
      _api.post(
        '/watch-spots',
        body: {
          'name': name,
          'area': area,
          'contact_name': contactName,
          'contact_phone': contactPhone,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'screens': screens,
          'entry_tzs': entryTzs,
          'features': features,
        },
      );
}
