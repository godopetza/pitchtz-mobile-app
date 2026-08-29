import 'package:flutter/foundation.dart';
import '../entities/api_booking.dart';

abstract class BookingRepository implements Listenable {
  Future<ApiBooking> createBooking({
    required String pitchId,
    required DateTime startsAt,
    required DateTime endsAt,
  });

  Future<List<ApiBooking>> getMyBookings();
  Future<ApiBooking> getBooking(String id);

  Future<void> payFull({
    required String bookingId,
    required String phone,
    required String operator,
  });

  Future<ApiBooking> splitBill({
    required String bookingId,
    required int ways,
  });

  Future<void> payDeposit({
    required String bookingId,
    required String phone,
    required String operator,
  });

  Future<PublicShare> getShare(String shareId);

  Future<void> payShare({
    required String shareId,
    required String phone,
    required String operator,
  });

  /// Cached result of the last [getMyBookings] call — available synchronously
  /// so the Bookings tab can render without waiting for a fresh network load.
  List<ApiBooking> get cachedBookings;

  /// The most recently created booking (set after [createBooking] succeeds).
  ApiBooking? get lastCreated;
}
