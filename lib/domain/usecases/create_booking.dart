import '../entities/api_booking.dart';
import '../repositories/booking_repository.dart';

/// Creates a booking through the [BookingRepository].
///
/// Kept as an explicit use-case so presentation code depends on an intention
/// rather than a data-store interface.
class CreateBooking {
  const CreateBooking(this._repository);

  final BookingRepository _repository;

  Future<ApiBooking> call({
    required String pitchId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) {
    return _repository.createBooking(
      pitchId: pitchId,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }
}
