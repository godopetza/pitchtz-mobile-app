import '../entities/watch_spot.dart';

abstract class WatchSpotRepository {
  Future<List<WatchSpot>> getWatchSpots();
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
  });
}
