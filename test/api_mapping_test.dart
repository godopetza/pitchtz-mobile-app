import 'package:flutter_test/flutter_test.dart';

import 'package:pitchtz/data/models/availability_dto.dart';
import 'package:pitchtz/data/models/city_dto.dart';
import 'package:pitchtz/data/models/json.dart';
import 'package:pitchtz/data/models/review_dto.dart';
import 'package:pitchtz/data/models/venue_dto.dart';

void main() {
  group('CityDto', () {
    test('maps a live city from the real production payload', () {
      final city = CityDto.toEntity({
        'id': '674feec9-86cf-46ec-a54b-66cf35a16256',
        'name': 'Dar es Salaam',
        'status': 'live',
        'latitude': -6.7924,
        'longitude': 39.2083,
      });
      expect(city.id, '674feec9-86cf-46ec-a54b-66cf35a16256');
      expect(city.name, 'Dar es Salaam');
      expect(city.live, isTrue);
      expect(city.eta, isNull);
      expect(city.latitude, closeTo(-6.7924, 1e-9));
    });

    test('maps a waitlist city with a launch ETA', () {
      final city = CityDto.toEntity({
        'id': 'x',
        'name': 'Arusha',
        'status': 'waitlist',
        'launch_eta': '2026-11-01T00:00:00.000Z',
      });
      expect(city.live, isFalse);
      expect(city.eta, 'Launching Nov 2026');
    });
  });

  group('VenueDto', () {
    // Verbatim from GET /v1/venues on production.
    final venueJson = {
      'id': '3694ba4f-5c0d-49d7-bdda-f7c3c5a1752b',
      'name': 'Test Venue (bootstrap)',
      'area': 'Masaki',
      'city': {
        'id': '674feec9-86cf-46ec-a54b-66cf35a16256',
        'name': 'Dar es Salaam',
        'status': 'live',
        'latitude': -6.7924,
        'longitude': 39.2083,
      },
      'latitude': -6.75,
      'longitude': 39.27,
      'verified': true,
      'rating': 0,
      'amenities': <String>[],
      'rules': <String>[],
      'cancel_window_hours': 24,
      'auto_confirm': false,
      'price_from_tzs': 40000,
      'pitches': [
        {
          'id': '81a779a1-f455-4d1c-a343-1f0bb0dce363',
          'name': 'Pitch A',
          'format': '5-a-side',
          'surface': 'artificial_turf',
          'base_price_tzs': 40000,
          'open_hours': <String, dynamic>{},
        },
      ],
      'photos': <Map<String, dynamic>>[],
      'extras': <Map<String, dynamic>>[],
    };

    test('maps the real production venue', () {
      final p = VenueDto.toPitch(venueJson);
      expect(p.id, '3694ba4f-5c0d-49d7-bdda-f7c3c5a1752b');
      expect(p.name, 'Test Venue (bootstrap)');
      expect(p.area, 'Masaki');
      expect(p.pricePerHour, 40000);
      expect(p.format, '5-a-side');
      expect(p.surface, 'Artificial turf');
      expect(p.verified, isTrue);
      expect(p.imageUrl, isNull); // no photos yet
      expect(p.ratingLabel, 'New'); // rating 0 → "New"
      expect(p.latitude, closeTo(-6.75, 1e-9));
    });

    test('falls back to cheapest pitch price when price_from_tzs is absent',
        () {
      final m = Map<String, dynamic>.from(venueJson)..remove('price_from_tzs');
      m['pitches'] = [
        {'base_price_tzs': 90000, 'format': '7', 'surface': 'natural_grass'},
        {'base_price_tzs': 55000, 'format': '5', 'surface': 'natural_grass'},
      ];
      expect(VenueDto.toPitch(m).pricePerHour, 55000);
    });

    test('normalises short format codes', () {
      expect(Display.format('5'), '5-a-side');
      expect(Display.format('futsal'), 'Futsal');
      expect(Display.format('5-a-side'), '5-a-side');
      expect(Display.surface('artificial_turf'), 'Artificial turf');
    });

    test('tolerates camelCase keys (handoff doc shape)', () {
      final p = VenueDto.toPitch({
        'id': 'v1',
        'name': 'Camel Park',
        'area': 'Sinza',
        'rating': 4.5,
        'priceFromTzs': 60000,
        'pitches': [
          {'basePriceTzs': 60000, 'format': '7', 'surface': 'natural_grass'},
        ],
      });
      expect(p.pricePerHour, 60000);
      expect(p.format, '7-a-side');
    });
  });

  group('ReviewDto', () {
    test('maps a review', () {
      final r = ReviewDto.toEntity({
        'id': 'r1',
        'stars': 4,
        'text': 'Great turf.',
        'tags': ['Good turf', 'Clean'],
        'created_at': '2026-07-15T12:00:00.000Z',
        'owner_reply': null,
      });
      expect(r.stars, 4);
      expect(r.starsLabel, '★★★★☆');
      expect(r.tags, ['Good turf', 'Clean']);
      expect(r.date, 'Jul 2026');
    });
  });

  group('AvailabilityDto', () {
    test('maps per-pitch unavailable windows', () {
      final list = AvailabilityDto.toEntity({
        'venue_id': 'v1',
        'from': '2026-08-26T00:00:00.000Z',
        'to': '2026-08-27T00:00:00.000Z',
        'pitches': [
          {
            'pitch': {
              'id': 'p1',
              'name': 'Pitch A',
              'format': '5',
              'base_price_tzs': 40000,
            },
            'unavailable': [
              {
                'starts_at': '2026-08-26T17:00:00.000Z',
                'ends_at': '2026-08-26T19:00:00.000Z',
                'kind': 'booked',
              },
            ],
          },
        ],
      });
      expect(list, hasLength(1));
      expect(list.first.pitchId, 'p1');
      expect(list.first.format, '5-a-side');
      expect(list.first.unavailable, hasLength(1));
      expect(list.first.unavailable.first.kind, 'booked');
    });
  });
}
