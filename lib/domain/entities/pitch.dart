/// A venue (the card unit throughout discovery). Populated from the live
/// `GET /v1/venues` and `/v1/venues/:id` responses.
class Pitch {
  const Pitch({
    required this.id,
    required this.name,
    required this.area,
    required this.rating,
    this.reviewCount = 0,
    required this.pricePerHour,
    required this.format,
    required this.surface,
    this.imageUrl,
    this.photoUrls = const [],
    this.latitude,
    this.longitude,
    this.verified = false,
    this.distance,
    this.nextSlot,
  });

  final String id; // venue UUID
  final String name;
  final String area;
  final double rating;
  final int reviewCount;
  final int pricePerHour; // price_from_tzs (TZS)
  final String format; // display, e.g. "5-a-side"
  final String surface; // display, e.g. "Artificial turf"
  final String? imageUrl; // first venue photo, if any
  final List<String> photoUrls; // all venue photos sorted by sort order
  final double? latitude;
  final double? longitude;
  final bool verified;
  final String? distance; // e.g. "2.4 km", when known
  final String? nextSlot; // e.g. "8:00 PM", when known

  /// Peak price (7–10 PM) — 25% premium, matching the design.
  int get peakPrice => (pricePerHour * 1.25).round();

  String get ratingLabel => rating > 0 ? rating.toStringAsFixed(1) : 'New';

  /// Deterministic two-tone "mowed grass" gradient derived from the id, used as
  /// the photo fallback so each venue looks distinct even without a photo.
  int get gradient1 => _palette[id.hashCode.abs() % _palette.length][0];
  int get gradient2 => _palette[id.hashCode.abs() % _palette.length][1];

  static const List<List<int>> _palette = [
    [0xFF2F7E52, 0xFF2A734B],
    [0xFF2C6E5E, 0xFF276456],
    [0xFF5F8A46, 0xFF557E3F],
    [0xFF4C7D3E, 0xFF447237],
    [0xFF33705F, 0xFF2D6555],
    [0xFF587A4A, 0xFF4F6E43],
  ];

  Pitch copyWith({String? distance, String? nextSlot}) => Pitch(
        id: id,
        name: name,
        area: area,
        rating: rating,
        reviewCount: reviewCount,
        pricePerHour: pricePerHour,
        format: format,
        surface: surface,
        imageUrl: imageUrl,
        photoUrls: photoUrls,
        latitude: latitude,
        longitude: longitude,
        verified: verified,
        distance: distance ?? this.distance,
        nextSlot: nextSlot ?? this.nextSlot,
      );
}

/// A neighbourhood grouping used on Explore / filters (computed client-side
/// from the venue list, since the API has no area endpoint).
class Area {
  const Area({required this.name, required this.count});
  final String name;
  final int count;
}
