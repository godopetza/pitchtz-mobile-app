import '../../domain/entities/watch_spot.dart';
import 'json.dart';

class WatchSpotDto {
  static WatchSpot fromJson(Map<String, dynamic> m) => WatchSpot(
        id: J.str(m, 'id'),
        name: J.str(m, 'name'),
        area: J.str(m, 'area'),
        address: J.str(m, 'address'),
        latitude: J.dblOrNull(m, 'latitude'),
        longitude: J.dblOrNull(m, 'longitude'),
        screens: J.intVal(m, 'screens'),
        capacity: J.str(m, 'capacity'),
        entryTzs: J.intVal(m, 'entry_tzs'),
        features: J.strList(m, 'features'),
        photoUrl: J.strOrNull(m, 'photo_url'),
      );
}
