import '../../domain/entities/city.dart';
import 'json.dart';

/// Maps a `City` JSON object to the [City] entity.
class CityDto {
  static City toEntity(Map<String, dynamic> m) {
    final status = J.str(m, 'status');
    final live = status == 'live';
    final eta = J.date(m, 'launch_eta');
    return City(
      id: J.str(m, 'id'),
      name: J.str(m, 'name'),
      live: live,
      eta: live || eta == null ? null : 'Launching ${Display.monthYear(eta)}',
      latitude: J.dblOrNull(m, 'latitude'),
      longitude: J.dblOrNull(m, 'longitude'),
    );
  }
}
