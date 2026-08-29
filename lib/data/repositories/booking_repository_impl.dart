import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/api_booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_dto.dart';

/// Live implementation of [BookingRepository] backed by the PitchTZ REST API.
///
/// State is cached in memory so the Bookings tab can render synchronously after
/// the first network load. [notifyListeners] is called whenever [cachedBookings]
/// or [lastCreated] change.
class BookingRepositoryImpl extends ChangeNotifier implements BookingRepository {
  BookingRepositoryImpl(this._client);

  final ApiClient _client;

  List<ApiBooking> _bookings = const [];
  ApiBooking? _lastCreated;

  @override
  List<ApiBooking> get cachedBookings => _bookings;

  @override
  ApiBooking? get lastCreated => _lastCreated;

  // ---------------------------------------------------------------------------
  // Write operations
  // ---------------------------------------------------------------------------

  /// POST /bookings
  ///
  /// Body: { pitch_id, starts_at (RFC3339), ends_at (RFC3339) }
  /// Returns the created [ApiBooking] (HTTP 201 with envelope).
  @override
  Future<ApiBooking> createBooking({
    required String pitchId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    final raw = await _client.post(
      '/bookings',
      body: {
        'pitch_id': pitchId,
        'starts_at': startsAt.toUtc().toIso8601String(),
        'ends_at': endsAt.toUtc().toIso8601String(),
      },
    ) as Map<String, dynamic>;

    final booking = BookingDto.fromJson(raw);
    _lastCreated = booking;

    // Prepend to cache so it appears immediately on the Bookings tab.
    _bookings = [booking, ..._bookings];
    notifyListeners();
    return booking;
  }

  /// POST /bookings/:id/pay
  ///
  /// Initiates a full-amount mobile-money charge. Poll [getBooking] afterwards
  /// to track the payment status transition.
  @override
  Future<void> payFull({
    required String bookingId,
    required String phone,
    required String operator,
  }) async {
    await _client.post(
      '/bookings/$bookingId/pay',
      body: {'phone': phone, 'operator': operator},
    );
  }

  /// POST /bookings/:id/split
  ///
  /// Splits the booking bill into [ways] equal shares.
  /// Returns the updated [ApiBooking] (with the `shares` array populated).
  @override
  Future<ApiBooking> splitBill({
    required String bookingId,
    required int ways,
  }) async {
    final raw = await _client.post(
      '/bookings/$bookingId/split',
      body: {'ways': ways},
    ) as Map<String, dynamic>;

    final updated = BookingDto.fromJson(raw);
    _updateCache(updated);
    return updated;
  }

  /// POST /bookings/:id/deposit
  ///
  /// Charges the deposit amount via mobile money.
  @override
  Future<void> payDeposit({
    required String bookingId,
    required String phone,
    required String operator,
  }) async {
    await _client.post(
      '/bookings/$bookingId/deposit',
      body: {'phone': phone, 'operator': operator},
    );
  }

  /// POST /pay/shares/:id/pay
  ///
  /// Pays a single split share via mobile money (public endpoint, no auth
  /// required by the server, but ApiClient still attaches the token when
  /// present).
  @override
  Future<void> payShare({
    required String shareId,
    required String phone,
    required String operator,
  }) async {
    await _client.post(
      '/pay/shares/$shareId/pay',
      body: {'phone': phone, 'operator': operator},
    );
  }

  // ---------------------------------------------------------------------------
  // Read operations
  // ---------------------------------------------------------------------------

  /// GET /bookings — returns all bookings for the authenticated player.
  @override
  Future<List<ApiBooking>> getMyBookings() async {
    final raw = await _client.getList('/bookings');
    final bookings = raw
        .whereType<Map<String, dynamic>>()
        .map(BookingDto.fromJson)
        .toList();

    _bookings = bookings;
    notifyListeners();
    return bookings;
  }

  /// GET /bookings/:id — fetches a single booking by ID.
  ///
  /// Also updates the matching entry in [cachedBookings] so any listening
  /// widget reflects the latest state (e.g. after polling post-payment).
  @override
  Future<ApiBooking> getBooking(String id) async {
    final raw = await _client.getObject('/bookings/$id');
    final booking = BookingDto.fromJson(raw);
    _updateCache(booking);
    return booking;
  }

  /// GET /pay/shares/:id — public endpoint that returns a [PublicShare].
  @override
  Future<PublicShare> getShare(String shareId) async {
    final raw = await _client.getObject('/pay/shares/$shareId');
    return PublicShareDto.fromJson(raw);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Replace a stale entry in [_bookings] with [updated], or append if absent.
  void _updateCache(ApiBooking updated) {
    final idx = _bookings.indexWhere((b) => b.id == updated.id);
    if (idx >= 0) {
      final copy = List<ApiBooking>.from(_bookings);
      copy[idx] = updated;
      _bookings = copy;
    } else {
      _bookings = [..._bookings, updated];
    }

    if (_lastCreated?.id == updated.id) {
      _lastCreated = updated;
    }

    notifyListeners();
  }
}
