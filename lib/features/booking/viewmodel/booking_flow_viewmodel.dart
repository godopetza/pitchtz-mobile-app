import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/datasources/mock_data.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/payment_method.dart';
import '../../../domain/entities/pitch.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/payment_repository.dart';
import '../../../domain/usecases/booking_calculator.dart';
import '../../../domain/usecases/create_booking.dart';

/// Holds the entire booking flow's state (summary → processing → success),
/// shared as a singleton so the screens stay in sync.
class BookingFlowViewModel extends ChangeNotifier {
  BookingFlowViewModel(
    this._calc,
    this._createBooking,
    this._payments,
    this._bookingRepo,
  );

  final BookingCalculator _calc;
  final CreateBooking _createBooking;
  final PaymentRepository _payments;
  final BookingRepository _bookingRepo;

  // ---- Draft (from the detail screen) ----
  late Pitch pitch;
  int _pitchFee = 0;
  String _dateLabel = '';
  String _timeLabel = '';
  int _durationHours = 1;
  String _format = '';

  // ---- Summary selections ----
  final Map<String, int> _qty = {
    for (final e in MockData.extras) e.key: 0,
  };
  bool _waterAlways = false;
  String _repeat = 'Just once';
  bool _tipGuards = false;
  bool _contribute = false;
  bool _installment = false; // pay in 2
  String _payId = 'mpesa';
  bool _splitPay = false;
  String _splitGroup = 'Mikocheni Warriors';
  int _splitN = 10;

  // ---- Success ----
  Booking? _booked;
  bool _shareOpen = false;
  bool _splitOpen = false;
  int _players = 10;

  List<ExtraDef> get extraDefs => _bookingRepo.getExtraDefinitions();
  List<PaymentMethod> get paymentMethods => _payments.getMethods();

  void start({
    required Pitch pitch,
    required int pitchFee,
    required String dateLabel,
    required String timeLabel,
    required int durationHours,
    required String format,
  }) {
    this.pitch = pitch;
    _pitchFee = pitchFee;
    _dateLabel = dateLabel;
    _timeLabel = timeLabel;
    _durationHours = durationHours;
    _format = format;
    // Reset selections for a fresh booking.
    for (final k in _qty.keys) {
      _qty[k] = 0;
    }
    _waterAlways = false;
    _repeat = 'Just once';
    _tipGuards = false;
    _contribute = false;
    _installment = false;
    _payId = 'mpesa';
    _splitPay = false;
    _splitN = 10;
    _shareOpen = false;
    _splitOpen = false;
    _players = 10;
    notifyListeners();
  }

  // ---- Extras ----
  int qty(String key) => _qty[key] ?? 0;
  void increment(String key) {
    _qty[key] = (_qty[key] ?? 0) + 1;
    notifyListeners();
  }

  void decrement(String key) {
    _qty[key] = ((_qty[key] ?? 0) - 1).clamp(0, 99);
    notifyListeners();
  }

  bool get waterAlways => _waterAlways;
  void toggleWaterAlways() {
    _waterAlways = !_waterAlways;
    if (_waterAlways && (_qty['water'] ?? 0) == 0) _qty['water'] = 3;
    notifyListeners();
  }

  // ---- Repeat ----
  String get repeat => _repeat;
  List<String> get repeatOptions => MockData.repeatOptions;
  void pickRepeat(String r) {
    _repeat = r;
    notifyListeners();
  }

  String get repeatNote => _repeat == 'Just once'
      ? 'One session'
      : 'Same slot reserved every time · billed per session · cancel anytime';

  // ---- Tips ----
  bool get tipGuards => _tipGuards;
  bool get contribute => _contribute;
  void toggleTip() {
    _tipGuards = !_tipGuards;
    notifyListeners();
  }

  void toggleContribute() {
    _contribute = !_contribute;
    notifyListeners();
  }

  // ---- Payment plan ----
  bool get installment => _installment;
  void pickFull() {
    _installment = false;
    notifyListeners();
  }

  void pickInstallment() {
    _installment = true;
    notifyListeners();
  }

  // ---- Payment method ----
  String get payId => _payId;
  void pickPayment(String id) {
    _payId = id;
    notifyListeners();
  }

  String get payName =>
      paymentMethods.firstWhere((m) => m.id == _payId).name;

  // ---- Who's paying ----
  bool get splitPay => _splitPay;
  void setSolo() {
    _splitPay = false;
    notifyListeners();
  }

  void setSplit() {
    _splitPay = true;
    notifyListeners();
  }

  String get splitGroup => _splitGroup;
  List<String> get splitGroups => MockData.splitGroups;
  void pickSplitGroup(String g) {
    _splitGroup = g;
    notifyListeners();
  }

  int get splitN => _splitN;
  void splitUp() {
    _splitN = (_splitN + 1).clamp(2, 22);
    notifyListeners();
  }

  void splitDown() {
    _splitN = (_splitN - 1).clamp(2, 22);
    notifyListeners();
  }

  // ---- Totals ----
  bool get _hasSelection => _pitchFee > 0;
  int get extrasTotal => _calc.extrasTotal(extraDefs, _qty);
  int get tipsTotal =>
      _calc.tipsTotal(tipGuards: _tipGuards, contribute: _contribute);
  int get total => _calc.total(
        pitchFee: _pitchFee,
        extras: extrasTotal,
        tips: tipsTotal,
        hasSelection: _hasSelection,
      );
  int get payNow => _calc.payNow(total: total, installment: _installment);
  int get splitShare =>
      _calc.perPlayer(_installment ? payNow : total, _splitN);

  String get pitchFeeFmt => Formatters.tsh(_pitchFee);
  String get totalFmt => Formatters.tsh(total);
  String get payNowFmt => Formatters.tsh(payNow);
  String get splitShareFmt => Formatters.tsh(splitShare);
  String get dateLabel => _dateLabel;
  String get timeLabel => _timeLabel;
  String get durationText =>
      _durationHours == 1 ? '1 hour' : '$_durationHours hours';
  String get format => _format;
  int get splitQrSeed => total == 0 ? 13 : total;

  List<PriceLine> get summaryRows => [
        PriceLine('Venue', pitch.name),
        PriceLine('Date', _dateLabel),
        PriceLine('Time', _timeLabel),
        PriceLine('Duration', durationText),
        PriceLine('Pitch', _format),
        PriceLine('Repeats', _repeat),
      ];

  List<PriceLine> get extraLines => [
        for (final x in extraDefs)
          if (qty(x.key) > 0)
            PriceLine('${x.name} ×${qty(x.key)}',
                Formatters.tsh(x.price * qty(x.key))),
        if (_tipGuards) const PriceLine('Security guards tip', 'TSh 2,000'),
        if (_contribute) const PriceLine('Venue contribution', 'TSh 5,000'),
      ];

  String get payButtonLabel {
    if (_splitPay) return 'Pay my share · ${Formatters.tsh(splitShare)}';
    if (_installment) return 'Pay ${Formatters.tsh(payNow)} now';
    return 'Pay ${Formatters.tsh(total)}';
  }

  // ---- Confirm (called after the processing delay) ----
  Booking confirm() {
    _booked = _createBooking(
      venue: pitch.name,
      date: _dateLabel,
      time: _timeLabel,
      total: total,
      durationMinutes: _durationHours * 60,
    );
    notifyListeners();
    return _booked!;
  }

  // ---- Success ----
  Booking get booked =>
      _booked ??
      const Booking(venue: '', date: '', time: '', code: '', durationMinutes: '');
  bool get shareOpen => _shareOpen;
  bool get splitOpen => _splitOpen;
  int get players => _players;
  int get perPlayer =>
      _calc.perPlayer(_booked?.totalAmount ?? 0, _players);
  String get perPlayerFmt => Formatters.tsh(perPlayer);
  int get successQrSeed => _booked?.totalAmount ?? 7;

  void toggleShare() {
    _shareOpen = !_shareOpen;
    notifyListeners();
  }

  void toggleSplit() {
    _splitOpen = !_splitOpen;
    notifyListeners();
  }

  void playersUp() {
    _players = (_players + 1).clamp(2, 22);
    notifyListeners();
  }

  void playersDown() {
    _players = (_players - 1).clamp(2, 22);
    notifyListeners();
  }
}
