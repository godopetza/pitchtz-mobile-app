/// A confirmed (or historical) booking.
class Booking {
  const Booking({
    required this.venue,
    required this.date,
    required this.time,
    required this.code,
    this.total,
    this.totalAmount,
    this.durationMinutes,
    this.status = BookingStatus.confirmed,
    this.priceLabel,
  });

  final String venue;
  final String date; // "Monday, 24 August"
  final String time; // "8:00 PM – 9:00 PM"
  final String code; // "PITCH-7284"
  final String? total; // formatted
  final int? totalAmount; // raw
  final String? durationMinutes; // "60 minutes"
  final BookingStatus status;
  final String? priceLabel; // for past bookings ("TSh 75,000")
}

enum BookingStatus { confirmed, completed }

/// Definition of an optional extra a player can add to a booking.
class ExtraDef {
  const ExtraDef({
    required this.key,
    required this.name,
    required this.price,
    required this.description,
  });

  final String key;
  final String name;
  final int price;
  final String description;
}

/// A single line on the price breakdown.
class PriceLine {
  const PriceLine(this.label, this.value);
  final String label;
  final String value;
}
