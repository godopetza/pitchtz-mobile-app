/// Formatting helpers mirroring the design's `fmt`, `h12` and `h12m` functions.
class Formatters {
  Formatters._();

  /// `fmt(n)` → "TSh 60,000"
  static String tsh(num n) {
    final s = n.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return 'TSh $buf';
  }

  /// Rounds to the nearest thousand and appends "K" → 60000 -> "60K".
  static String priceK(num n) => '${(n / 1000).round()}K';

  /// `h12(h)` → 20 -> "8:00 PM"
  static String h12(int h) {
    final ap = h >= 12 ? 'PM' : 'AM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    return '$hh:00 $ap';
  }

  /// `h12m(t)` supporting half hours → 20.5 -> "8:30 PM"
  static String h12m(double t) {
    final h = t.floor();
    final m = ((t - h) * 60).round();
    final ap = h >= 12 ? 'PM' : 'AM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    final mm = m < 10 ? '0$m' : '$m';
    return '$hh:$mm $ap';
  }

  /// Two-digit 24h label used on the slot grid → 8 -> "08:00".
  static String slotLabel(int h) => '${h < 10 ? '0$h' : h}:00';

  /// Rounds a per-player share up to the nearest 100, like the design.
  static int roundShare(num amount, int players) =>
      ((amount / players) / 100).ceil() * 100;
}
