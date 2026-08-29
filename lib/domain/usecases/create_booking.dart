import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Confirms a booking through the [BookingRepository]. Kept as an explicit
/// use-case so the payment ViewModel depends on an intention, not a data store.
class CreateBooking {
  const CreateBooking(this._repository);

  final BookingRepository _repository;

  Booking call({
    required String venue,
    required String date,
    required String time,
    required int total,
    required int durationMinutes,
  }) {
    return _repository.createBooking(
      venue: venue,
      date: date,
      time: time,
      total: total,
      durationMinutes: durationMinutes,
    );
  }
}
