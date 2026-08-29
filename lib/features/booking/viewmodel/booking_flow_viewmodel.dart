import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/datasources/mock_data.dart';
import '../../../domain/entities/api_booking.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/malipo_operator.dart';
import '../../../domain/entities/payment_method.dart';
import '../../../domain/entities/pitch.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/payment_repository.dart';
import '../../../domain/usecases/booking_calculator.dart';

/// Holds the entire booking flow's state (summary → processing → success),
/// shared as a singleton so the screens stay in sync.
class BookingFlowViewModel extends ChangeNotifier {
  BookingFlowViewModel(
    this._calc,
    this._bookingRepo,
    this._payments,
  );

  final BookingCalculator _calc;
  final BookingRepository _bookingRepo;
  final PaymentRepository _payments;

  // ---- Draft (from the detail screen) ----
  late Pitch pitch;
  int _pitchFee = 0;
  String _dateLabel = '';
  String _timeLabel = '';
  int _durationHours = 1;
  String _format = '';

  // The real pitch ID used for the API call.
  String _pitchId = '';
  DateTime? _startsAt;
  DateTime? _endsAt;

  // ---- Operator catalogue ----
  List<MalipoOperator> _operators = [];
  List<MalipoOperator> get operators => _operators;
  bool _operatorsLoading = false;
  bool get operatorsLoading => _operatorsLoading;

  /// The operator ID selected by the user (e.g. "MPESA_TZA").
  String? _selectedOperatorId;
  String? get selectedOperatorId => _selectedOperatorId;

  MalipoOperator? get selectedOperator => _operators.isEmpty
      ? null
      : _operators.firstWhere(
          (o) => o.id == _selectedOperatorId,
          orElse: () => _operators.first,
        );

  void selectOperator(String id) {
    _selectedOperatorId = id;
    notifyListeners();
  }

  /// The phone number the user enters for mobile-money payment.
  String _phone = '';
  String get phone => _phone;
  void setPhone(String value) {
    _phone = value.trim();
    notifyListeners();
  }

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

  // ---- Active booking (created after confirmAndPay step 1) ----
  String? _currentBookingId;
  String? get currentBookingId => _currentBookingId;

  ApiBooking? _currentBooking;
  ApiBooking? get currentBooking => _currentBooking;

  // ---- Hold countdown ----
  Timer? _holdTicker;
  DateTime? _holdExpiresAt;

  /// Remaining time on the server-side seat hold.
  Duration get holdRemaining {
    if (_holdExpiresAt == null) return Duration.zero;
    final remaining = _holdExpiresAt!.difference(DateTime.now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get holdExpired => _holdExpiresAt != null && holdRemaining == Duration.zero;

  void _startHoldCountdown(DateTime expiresAt) {
    _holdTicker?.cancel();
    _holdExpiresAt = expiresAt;
    _holdTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
      if (holdExpired) _holdTicker?.cancel();
    });
  }

  // ---- Polling ----
  Timer? _pollTimer;
  int _pollCount = 0;
  static const int _maxPolls = 10;

  bool _polling = false;
  bool get polling => _polling;

  /// Polls [getBooking] every 3 seconds until the status leaves
  /// pending/part_paid or [_maxPolls] attempts are exhausted.
  /// Returns the final [ApiBooking] state.
  Future<ApiBooking?> pollBooking(String id) async {
    _pollCount = 0;
    _polling = true;
    notifyListeners();

    final completer = Completer<ApiBooking?>();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      try {
        final booking = await _bookingRepo.getBooking(id);
        _currentBooking = booking;
        notifyListeners();

        final done = booking.status != 'pending' && booking.status != 'part_paid';
        if (done || _pollCount >= _maxPolls) {
          timer.cancel();
          _polling = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete(booking);
        }
      } catch (e) {
        if (_pollCount >= _maxPolls) {
          timer.cancel();
          _polling = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete(_currentBooking);
        }
      }
    });

    return completer.future;
  }

  // ---- Success ----
  ApiBooking? _apiBooked;
  bool _shareOpen = false;
  bool _splitOpen = false;
  int _players = 10;

  // Legacy display-only booking kept for success screen until it is migrated.
  Booking? _booked;

  List<ExtraDef> get extraDefs => MockData.extras;
  List<PaymentMethod> get paymentMethods => _payments.getMethods();

  /// Called when navigating to the booking flow. Resets all state for a fresh
  /// booking and pre-loads the operator catalogue.
  void start({
    required Pitch pitch,
    required String pitchId,
    required int pitchFee,
    required String dateLabel,
    required String timeLabel,
    required int durationHours,
    required String format,
    required DateTime startsAt,
    required DateTime endsAt,
  }) {
    this.pitch = pitch;
    _pitchId = pitchId;
    _pitchFee = pitchFee;
    _dateLabel = dateLabel;
    _timeLabel = timeLabel;
    _durationHours = durationHours;
    _format = format;
    _startsAt = startsAt;
    _endsAt = endsAt;

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
    _apiBooked = null;
    _booked = null;
    _currentBookingId = null;
    _currentBooking = null;
    _holdExpiresAt = null;
    _phone = '';
    _selectedOperatorId = null;
    _pollCount = 0;
    _polling = false;

    _holdTicker?.cancel();
    _holdTicker = null;
    _pollTimer?.cancel();
    _pollTimer = null;

    notifyListeners();
    _loadOperators();
  }

  Future<void> _loadOperators() async {
    _operatorsLoading = true;
    notifyListeners();
    try {
      _operators = await _payments.getOperators();
      if (_operators.isNotEmpty) {
        _selectedOperatorId = _operators.first.id;
      }
    } catch (_) {
      // Keep whatever was previously loaded; UI falls back gracefully.
    } finally {
      _operatorsLoading = false;
      notifyListeners();
    }
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

  // ---- confirmAndPay — two-step real API flow ----

  bool _confirming = false;
  bool get confirming => _confirming;
  String? _confirmError;
  String? get confirmError => _confirmError;

  /// Step 1 + Step 2 combined:
  ///   a. POST /bookings → [ApiBooking] with a hold.
  ///   b. Stores [holdExpiresAt] and starts the countdown ticker.
  ///   c. POST /bookings/:id/pay → instructs Malipo gateway.
  ///
  /// Returns the created [ApiBooking] on success, null on failure.
  /// Callers should immediately navigate to the processing screen, which then
  /// calls [pollBooking] to track confirmation.
  Future<ApiBooking?> confirmAndPay() async {
    if (_startsAt == null || _endsAt == null) return null;

    final operatorId = _selectedOperatorId ?? (operators.isNotEmpty ? operators.first.id : 'MPESA_TZA');
    final phoneNumber = _phone.isEmpty ? '' : _phone;

    _confirming = true;
    _confirmError = null;
    notifyListeners();

    try {
      // Step a — create the booking and obtain the seat hold.
      final booking = await _bookingRepo.createBooking(
        pitchId: _pitchId,
        startsAt: _startsAt!,
        endsAt: _endsAt!,
      );

      _currentBookingId = booking.id;
      _currentBooking = booking;
      _apiBooked = booking;

      // Step b — start the countdown so the UI can warn the user.
      _startHoldCountdown(booking.holdExpiresAt);

      // Build the legacy Booking for any success-screen widgets still using it.
      _booked = Booking(
        venue: pitch.name,
        date: _dateLabel,
        time: _timeLabel,
        code: booking.code,
        total: Formatters.tsh(booking.totalTzs),
        totalAmount: booking.totalTzs,
        durationMinutes: durationText,
      );

      // Step c — trigger payment via Malipo.
      if (_installment) {
        await _bookingRepo.payDeposit(
          bookingId: booking.id,
          phone: phoneNumber,
          operator: operatorId,
        );
      } else {
        await _bookingRepo.payFull(
          bookingId: booking.id,
          phone: phoneNumber,
          operator: operatorId,
        );
      }

      return booking;
    } catch (e) {
      _confirmError = e.toString();
      return null;
    } finally {
      _confirming = false;
      notifyListeners();
    }
  }

  /// Legacy alias kept so any screens that still call [confirm] continue to
  /// compile. Delegates to [confirmAndPay].
  Future<ApiBooking?> confirm() => confirmAndPay();

  // ---- Success ----

  /// The [ApiBooking] created by the most recent [confirmAndPay] call.
  ApiBooking? get apiBooked => _apiBooked;

  /// Legacy display object derived from [apiBooked] (for screens not yet
  /// migrated to [ApiBooking]).
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

  @override
  void dispose() {
    _holdTicker?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }
}
