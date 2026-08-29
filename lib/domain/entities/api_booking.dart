class ApiBooking {
  const ApiBooking({
    required this.id,
    required this.code,
    required this.pitchId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.pitchFeeTzs,
    required this.serviceFeeTzs,
    required this.totalTzs,
    required this.paidTzs,
    required this.holdExpiresAt,
    required this.balanceAtVenue,
    required this.balanceDueTzs,
    required this.shares,
  });

  final String id;
  final String code;        // "PTZ-4K7Q2M"
  final String pitchId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;      // pending | part_paid | confirmed | cancelled | completed
  final int pitchFeeTzs;
  final int serviceFeeTzs;
  final int totalTzs;
  final int paidTzs;
  final DateTime holdExpiresAt;
  final bool balanceAtVenue;
  final int balanceDueTzs;
  final List<BookingShare> shares;

  bool get isHoldActive => holdExpiresAt.isAfter(DateTime.now().toUtc());
  Duration get holdRemaining => holdExpiresAt.difference(DateTime.now().toUtc());
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed' || status == 'part_paid';
  bool get isCompleted => status == 'completed';
}

class BookingShare {
  const BookingShare({
    required this.id,
    required this.amountTzs,
    required this.kind,
    required this.status,
    this.paidAt,
    this.payUrl,
  });

  final String id;
  final int amountTzs;
  final String kind;    // split | gateway | deposit
  final String status;  // unpaid | paid | failed
  final DateTime? paidAt;
  final String? payUrl; // deep-link / QR target
}

class PublicShare {
  const PublicShare({
    required this.shareId,
    required this.amountTzs,
    required this.status,
    required this.bookingCode,
    required this.startsAt,
    required this.venueName,
    required this.pitchName,
  });

  final String shareId;
  final int amountTzs;
  final String status;
  final String bookingCode;
  final DateTime startsAt;
  final String venueName;
  final String pitchName;
}
