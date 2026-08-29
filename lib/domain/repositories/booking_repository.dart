import 'package:flutter/foundation.dart';

import '../entities/booking.dart';

/// Creates bookings and exposes upcoming / past lists. Extends [Listenable] so
/// the Bookings tab refreshes after a new booking is confirmed.
abstract class BookingRepository implements Listenable {
  List<ExtraDef> getExtraDefinitions();

  Booking? get lastBooking;
  List<Booking> getUpcoming();
  List<Booking> getPast();

  /// Persists a freshly confirmed booking and returns it.
  Booking createBooking({
    required String venue,
    required String date,
    required String time,
    required int total,
    required int durationMinutes,
  });
}
