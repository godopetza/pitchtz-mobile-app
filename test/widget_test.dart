import 'package:flutter_test/flutter_test.dart';

import 'package:pitchtz/core/utils/formatters.dart';
import 'package:pitchtz/data/datasources/mock_data.dart';
import 'package:pitchtz/domain/usecases/booking_calculator.dart';

void main() {
  group('Formatters', () {
    test('formats Tanzanian shillings with thousands separators', () {
      expect(Formatters.tsh(60000), 'TSh 60,000');
      expect(Formatters.tsh(100000), 'TSh 100,000');
      expect(Formatters.tsh(3000), 'TSh 3,000');
    });

    test('formats short price and 12h times', () {
      expect(Formatters.priceK(75000), '75K');
      expect(Formatters.h12m(20), '8:00 PM');
      expect(Formatters.h12m(20.5), '8:30 PM');
      expect(Formatters.slotLabel(8), '08:00');
    });

    test('rounds a per-player share up to the nearest 100', () {
      expect(Formatters.roundShare(78000, 10), 7800);
      expect(Formatters.roundShare(78001, 10), 7900);
    });
  });

  group('BookingCalculator', () {
    const calc = BookingCalculator();

    test('total adds pitch fee, extras, tips and the service fee', () {
      final extras = calc.extrasTotal(MockData.extras, {'water': 3}); // 36,000
      final tips = calc.tipsTotal(tipGuards: true, contribute: false); // 2,000
      final total = calc.total(
        pitchFee: 60000,
        extras: extras,
        tips: tips,
        hasSelection: true,
      );
      // 60,000 + 36,000 + 2,000 + 3,000 service fee
      expect(total, 101000);
    });

    test('pay-now on the 2-payment plan is half, rounded to nearest 500', () {
      expect(calc.payNow(total: 78000, installment: true), 39000);
      expect(calc.payNow(total: 78000, installment: false), 78000);
    });

    test('total is zero without a slot selection', () {
      expect(
        calc.total(pitchFee: 0, extras: 0, tips: 0, hasSelection: false),
        0,
      );
    });
  });
}
