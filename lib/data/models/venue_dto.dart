import '../../domain/entities/pitch.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/venue_extra.dart';
import 'json.dart';

/// Maps a `Venue` JSON object (list item or detail) to domain types.
///
/// A venue becomes the card-level [Pitch] the UI uses; its embedded
/// `amenities`, `rules` and `extras` feed [PitchDetails].
class VenueDto {
  static Pitch toPitch(Map<String, dynamic> m) {
    final pitches = J.objList(m, 'pitches');
    final firstPitch = pitches.isNotEmpty ? pitches.first : const <String, dynamic>{};
    final photos = J.objList(m, 'photos');
    final allUrls = _allPhotoUrls(photos);

    return Pitch(
      id: J.str(m, 'id'),
      name: J.str(m, 'name'),
      area: J.str(m, 'area'),
      rating: J.dbl(m, 'rating'),
      pricePerHour: _priceFrom(m, pitches),
      format: Display.format(J.str(firstPitch, 'format')),
      surface: Display.surface(J.str(firstPitch, 'surface')),
      imageUrl: allUrls.isNotEmpty ? allUrls.first : null,
      photoUrls: allUrls,
      latitude: J.dblOrNull(m, 'latitude'),
      longitude: J.dblOrNull(m, 'longitude'),
      verified: J.boolean(m, 'verified'),
    );
  }

  /// Amenities + rules + embedded extras from a venue-detail payload.
  static ({List<String> amenities, List<String> rules, List<VenueExtra> extras})
      detailBits(Map<String, dynamic> m) {
    return (
      amenities: J.strList(m, 'amenities'),
      rules: J.strList(m, 'rules'),
      extras: J.objList(m, 'extras').map(ExtraDto.toEntity).toList(),
    );
  }

  static int _priceFrom(Map<String, dynamic> m, List<Map<String, dynamic>> pitches) {
    final fromField = J.intVal(m, 'price_from_tzs');
    if (fromField > 0) return fromField;
    // Fall back to the cheapest pitch base price.
    final prices =
        pitches.map((p) => J.intVal(p, 'base_price_tzs')).where((p) => p > 0);
    return prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
  }

  static bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && url.contains('.');
  }

  static List<String> _allPhotoUrls(List<Map<String, dynamic>> photos) {
    if (photos.isEmpty) return const [];
    final sorted = [...photos]
      ..sort((a, b) => J.intVal(a, 'sort').compareTo(J.intVal(b, 'sort')));
    return sorted
        .map((p) => J.strOrNull(p, 'url'))
        .where(_isValidUrl)
        .cast<String>()
        .toList();
  }
}

/// Maps an `ExtraCatalog` JSON object to [VenueExtra].
class ExtraDto {
  static VenueExtra toEntity(Map<String, dynamic> m) => VenueExtra(
        id: J.str(m, 'id'),
        kind: J.str(m, 'kind'),
        name: J.str(m, 'name'),
        priceTzs: J.intVal(m, 'price_tzs'),
        unit: J.str(m, 'unit'),
        available: J.boolean(m, 'available', fallback: true),
      );
}
