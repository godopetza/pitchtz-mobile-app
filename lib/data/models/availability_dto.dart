import '../../domain/entities/availability.dart';
import 'json.dart';

/// Maps the availability payload (`{ venue_id, from, to, pitches: [...] }`) to
/// a list of [PitchAvailability].
class AvailabilityDto {
  static List<PitchAvailability> toEntity(Map<String, dynamic> data) {
    final pitches = J.objList(data, 'pitches');
    return pitches.map((entry) {
      final pitch = J.obj(entry, 'pitch') ?? const {};
      final windows = J.objList(entry, 'unavailable').map((w) {
        return UnavailableWindow(
          startsAt: J.date(w, 'starts_at') ?? DateTime.fromMillisecondsSinceEpoch(0),
          endsAt: J.date(w, 'ends_at') ?? DateTime.fromMillisecondsSinceEpoch(0),
          kind: J.str(w, 'kind', fallback: 'blocked'),
        );
      }).toList();

      return PitchAvailability(
        pitchId: J.str(pitch, 'id'),
        pitchName: J.str(pitch, 'name', fallback: 'Pitch'),
        format: Display.format(J.str(pitch, 'format')),
        basePriceTzs: J.intVal(pitch, 'base_price_tzs'),
        unavailable: windows,
      );
    }).toList();
  }
}
