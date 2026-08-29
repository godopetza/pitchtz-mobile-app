import '../entities/availability.dart';
import '../entities/pitch.dart';
import '../entities/review.dart';

/// Discovery reads against the live PitchTZ API.
abstract class PitchRepository {
  /// `GET /v1/venues` — optionally filtered by city and format short-code
  /// (`5`, `7`, `11`, `futsal`).
  Future<List<Pitch>> getVenues({String? cityId, String? format});

  /// `GET /v1/venues/:id`
  Future<Pitch> getVenue(String id);

  /// Venue detail bundled with `GET /v1/venues/:id/reviews` → amenities, rules,
  /// review tags, reviews and extras.
  Future<PitchDetails> getVenueDetails(String id);

  /// `GET /v1/venues/:id/availability?date=YYYY-MM-DD` — per-pitch unavailable
  /// windows; free slots are computed client-side.
  Future<List<PitchAvailability>> getAvailability(String venueId, {String? date});

  // Static filter-sheet options (no dedicated endpoint).
  List<String> getFilterAreas();
  List<String> getFilterAmenities();
}
