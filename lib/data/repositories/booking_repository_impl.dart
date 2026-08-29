import 'package:flutter/foundation.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/mock_data.dart';

class BookingRepositoryImpl extends ChangeNotifier implements BookingRepository {
  Booking? _last;

  @override
  Booking? get lastBooking => _last;

  @override
  List<ExtraDef> getExtraDefinitions() => MockData.extras;

  @override
  List<Booking> getUpcoming() => [
        if (_last != null) _last!,
        MockData.defaultUpcoming,
      ];

  @override
  List<Booking> getPast() => MockData.pastBookings;

  @override
  Booking createBooking({
    required String venue,
    required String date,
    required String time,
    required int total,
    required int durationMinutes,
  }) {
    // Booking code PITCH-7000..9999, mirroring the design's random generator.
    final code =
        'PITCH-${7000 + (DateTime.now().millisecondsSinceEpoch % 2999)}';
    _last = Booking(
      venue: venue,
      date: date,
      time: time,
      code: code,
      total: Formatters.tsh(total),
      totalAmount: total,
      durationMinutes: '$durationMinutes minutes',
    );
    notifyListeners();
    return _last!;
  }
}
