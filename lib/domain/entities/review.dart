import 'venue_extra.dart';

/// A public venue review (`GET /v1/venues/:id/reviews`). The API returns
/// anonymous reviews (no author name) with an integer star rating and tags.
class Review {
  const Review({
    required this.stars,
    required this.text,
    this.tags = const [],
    this.date = '',
    this.ownerReply,
  });

  final int stars; // 1..5
  final String text;
  final List<String> tags;
  final String date; // formatted created_at
  final String? ownerReply;

  String get starsLabel => '★' * stars + '☆' * (5 - stars);
}

/// Bundled detail content for the pitch detail screen.
class PitchDetails {
  const PitchDetails({
    required this.amenities,
    required this.goodToKnow,
    required this.reviewTags,
    required this.reviews,
    required this.extras,
  });

  final List<String> amenities; // venue.amenities
  final List<String> goodToKnow; // venue.rules
  final List<String> reviewTags; // aggregated from reviews[].tags
  final List<Review> reviews;
  final List<VenueExtra> extras;

  double get averageStars => reviews.isEmpty
      ? 0
      : reviews.map((r) => r.stars).reduce((a, b) => a + b) / reviews.length;
}
