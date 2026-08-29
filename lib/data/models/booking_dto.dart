import '../../domain/entities/api_booking.dart';
import 'json.dart';

class BookingDto {
  static ApiBooking fromJson(Map<String, dynamic> m) => ApiBooking(
        id: J.str(m, 'id'),
        code: J.str(m, 'code'),
        pitchId: J.str(m, 'pitch_id'),
        startsAt: J.date(m, 'starts_at') ?? DateTime(0),
        endsAt: J.date(m, 'ends_at') ?? DateTime(0),
        status: J.str(m, 'status'),
        pitchFeeTzs: J.intVal(m, 'pitch_fee_tzs'),
        serviceFeeTzs: J.intVal(m, 'service_fee_tzs'),
        totalTzs: J.intVal(m, 'total_tzs'),
        paidTzs: J.intVal(m, 'paid_tzs'),
        holdExpiresAt: J.date(m, 'hold_expires_at') ?? DateTime(0),
        balanceAtVenue: J.boolean(m, 'balance_at_venue'),
        balanceDueTzs: J.intVal(m, 'balance_due_tzs'),
        shares: J.objList(m, 'shares').map(ShareDto.fromJson).toList(),
      );
}

class ShareDto {
  static BookingShare fromJson(Map<String, dynamic> m) => BookingShare(
        id: J.str(m, 'id'),
        amountTzs: J.intVal(m, 'amount_tzs'),
        kind: J.str(m, 'kind'),
        status: J.str(m, 'status'),
        paidAt: J.dateOrNull(m, 'paid_at'),
        payUrl: J.strOrNull(m, 'pay_url'),
      );
}

class PublicShareDto {
  static PublicShare fromJson(Map<String, dynamic> m) => PublicShare(
        shareId: J.str(m, 'share_id'),
        amountTzs: J.intVal(m, 'amount_tzs'),
        status: J.str(m, 'status'),
        bookingCode: J.str(m, 'booking_code'),
        startsAt: J.date(m, 'starts_at') ?? DateTime(0),
        venueName: J.str(m, 'venue_name'),
        pitchName: J.str(m, 'pitch_name'),
      );
}
