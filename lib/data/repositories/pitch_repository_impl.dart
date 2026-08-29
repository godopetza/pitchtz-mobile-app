import '../../core/network/api_client.dart';
import '../../domain/entities/availability.dart';
import '../../domain/entities/pitch.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/pitch_repository.dart';
import '../datasources/mock_data.dart';
import '../models/availability_dto.dart';
import '../models/review_dto.dart';
import '../models/venue_dto.dart';

class PitchRepositoryImpl implements PitchRepository {
  PitchRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Pitch>> getVenues({String? cityId, String? format}) async {
    final list = await _api.getList('/venues', query: {
      if (cityId != null) 'city_id': cityId,
      if (format != null) 'format': format,
    });
    return list
        .whereType<Map>()
        .map((m) => VenueDto.toPitch(m.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<Pitch> getVenue(String id) async {
    final m = await _api.getObject('/venues/$id');
    return VenueDto.toPitch(m);
  }

  @override
  Future<PitchDetails> getVenueDetails(String id) async {
    // Venue detail (amenities/rules/extras) + public reviews, in parallel.
    final results = await Future.wait([
      _api.getObject('/venues/$id'),
      _api.getList('/venues/$id/reviews'),
    ]);
    final venue = results[0] as Map<String, dynamic>;
    final reviewsJson = results[1] as List;

    final bits = VenueDto.detailBits(venue);
    final reviews = reviewsJson
        .whereType<Map>()
        .map((m) => ReviewDto.toEntity(m.cast<String, dynamic>()))
        .toList();

    // Aggregate distinct review tags for the "tags" chips.
    final tags = <String>{};
    for (final r in reviews) {
      tags.addAll(r.tags);
    }

    return PitchDetails(
      amenities: bits.amenities,
      goodToKnow: bits.rules,
      reviewTags: tags.toList(),
      reviews: reviews,
      extras: bits.extras,
    );
  }

  @override
  Future<List<PitchAvailability>> getAvailability(String venueId,
      {String? date}) async {
    final data = await _api.getObject('/venues/$venueId/availability', query: {
      if (date != null) 'date': date,
    });
    return AvailabilityDto.toEntity(data);
  }

  @override
  List<String> getFilterAreas() => MockData.filterAreas;

  @override
  List<String> getFilterAmenities() => MockData.filterAmenities;
}
