import '../entities/booking.dart';

/// Pure domain logic that turns the summary screen's selections into a priced
/// breakdown. Mirrors the design's `renderVals` maths exactly:
///   total = pitchFee + extras + tips + service fee (3,000)
///   pay-now (split-in-2) = ceil(total / 2 / 500) * 500
///   per-player share = ceil(amount / players / 100) * 100
class BookingCalculator {
  const BookingCalculator();

  static const int serviceFee = 3000;
  static const int guardsTip = 2000;
  static const int venueContribution = 5000;

  int extrasTotal(List<ExtraDef> defs, Map<String, int> quantities) =>
      defs.fold(0, (t, x) => t + x.price * (quantities[x.key] ?? 0));

  int tipsTotal({required bool tipGuards, required bool contribute}) =>
      (tipGuards ? guardsTip : 0) + (contribute ? venueContribution : 0);

  int total({
    required int pitchFee,
    required int extras,
    required int tips,
    required bool hasSelection,
  }) =>
      hasSelection ? pitchFee + extras + tips + serviceFee : 0;

  /// 50% now, rounded to nearest 500 (pay-in-two plan).
  int payNow({required int total, required bool installment}) =>
      installment ? (total / 2 / 500).ceil() * 500 : total;

  int perPlayer(num amount, int players) =>
      ((amount / players) / 100).ceil() * 100;
}
