import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../domain/entities/availability.dart';
import '../../../domain/entities/pitch.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../domain/repositories/pitch_repository.dart';

/// A quick-info tile shown under the pitch header.
class QuickInfo {
  const QuickInfo(this.big, this.small);
  final String big;
  final String small;
}

/// A selectable date in the availability carousel.
class DateOption {
  const DateOption(this.dow, this.day, this.iso, this.label);
  final String dow; // "MON"
  final String day; // "24"
  final String iso; // "2026-08-25" (for the API query)
  final String label; // "Monday, 25 August"
}

enum DetailState { loading, ready, error }

class DetailViewModel extends ChangeNotifier {
  DetailViewModel(this._pitches, this._toast);

  final PitchRepository _pitches;
  final ToastController _toast;

  static const _dows = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _dowsLong = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _slotGroupsConfig = [
    ('Morning', [8, 9, 10]),
    ('Afternoon', [14, 15, 16]),
    ('Evening', [18, 19, 20, 21]),
  ];

  DetailState _state = DetailState.loading;
  String? _error;
  DetailState get state => _state;
  String? get error => _error;

  late String _venueId;
  Pitch? _pitch;
  PitchDetails? _details;
  List<PitchAvailability> _availability = [];
  final List<DateOption> _dates = [];
  int _dateIndex = 0;
  final List<int> _selectedHours = [];

  Pitch get pitch => _pitch!;
  PitchDetails get details => _details!;
  List<DateOption> get dates => _dates;
  int get dateIndex => _dateIndex;

  Future<void> load(String venueId) async {
    _venueId = venueId;
    _state = DetailState.loading;
    _error = null;
    _buildDates();
    notifyListeners();
    try {
      final results = await Future.wait([
        _pitches.getVenue(venueId),
        _pitches.getVenueDetails(venueId),
      ]);
      _pitch = results[0] as Pitch;
      _details = results[1] as PitchDetails;
      await _loadAvailability();
      _state = DetailState.ready;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _state = DetailState.error;
    } catch (_) {
      _error = 'Could not load this venue. Please try again.';
      _state = DetailState.error;
    }
    notifyListeners();
  }

  void _buildDates() {
    _dates.clear();
    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final d = DateTime(now.year, now.month, now.day + i);
      final iso =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      _dates.add(DateOption(
        _dows[d.weekday - 1],
        d.day.toString(),
        iso,
        '${_dowsLong[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}',
      ));
    }
  }

  Future<void> _loadAvailability() async {
    try {
      _availability = await _pitches
          .getAvailability(_venueId, date: _dates[_dateIndex].iso);
    } on ApiException {
      _availability = []; // treat as fully open if availability can't be read
    }
  }

  Future<void> pickDate(int index) async {
    _dateIndex = index;
    _selectedHours.clear();
    notifyListeners();
    await _loadAvailability();
    notifyListeners();
  }

  // ---- Slot grid (computed from the availability gaps) ----
  List<SlotGroup> get slotGroups {
    final base = _pitch?.pricePerHour ?? 0;
    return _slotGroupsConfig.map((g) {
      final slots = g.$2.map((h) {
        final available = _isHourAvailable(h);
        final peak = h >= 19;
        return TimeSlot(
          hour: h,
          available: available,
          peak: peak,
          price: peak ? (base * 1.25).round() : base,
        );
      }).toList();
      return SlotGroup(name: g.$1, slots: slots);
    }).toList();
  }

  /// A venue hour is bookable if at least one of its pitches has no unavailable
  /// window overlapping that hour on the selected date.
  bool _isHourAvailable(int hour) {
    if (_availability.isEmpty) return true; // no data → assume open
    for (final pa in _availability) {
      final blocked = pa.unavailable.any((w) {
        final s = w.startsAt.toLocal();
        final e = w.endsAt.toLocal();
        return s.hour <= hour && hour < (e.hour == 0 ? 24 : e.hour);
      });
      if (!blocked) return true;
    }
    return false;
  }

  bool isSlotSelected(int hour) => _selectedHours.contains(hour);
  bool get hasSelection => _selectedHours.isNotEmpty;
  List<int> get selectedHours => List.unmodifiable(_selectedHours..sort());

  /// Consecutive-slot selection (kept for realism; booking is gated).
  void pickSlot(TimeSlot slot) {
    if (!slot.available) return;
    final h = slot.hour;
    final cur = List<int>.from(_selectedHours)..sort();
    if (cur.contains(h)) {
      if (h == cur.first || h == cur.last) {
        cur.remove(h);
      } else {
        cur
          ..clear()
          ..add(h);
      }
    } else if (cur.isEmpty || h == cur.first - 1 || h == cur.last + 1) {
      cur.add(h);
    } else {
      cur
        ..clear()
        ..add(h);
    }
    _selectedHours
      ..clear()
      ..addAll(cur);
    notifyListeners();
  }

  int get pitchFee {
    var fee = 0;
    for (final g in slotGroups) {
      for (final s in g.slots) {
        if (_selectedHours.contains(s.hour)) fee += s.price;
      }
    }
    return fee;
  }

  int get durationHours => _selectedHours.length;

  String get timeLabel {
    if (!hasSelection) return '';
    final hs = selectedHours;
    return '${Formatters.h12m(hs.first.toDouble())} – ${Formatters.h12m((hs.last + 1).toDouble())}';
  }

  /// Locale-neutral summary of the selection ("2h · 8:00 PM – 10:00 PM").
  String get selectionLabel => '${durationHours}h · $timeLabel';

  String get peakPriceLabel => Formatters.tsh(pitch.peakPrice);

  List<QuickInfo> get quickInfo {
    final formatHead = pitch.format.split('-').first;
    final surfaceWord = pitch.surface.split(' ').first;
    return [
      QuickInfo(formatHead.isEmpty ? '—' : '${formatHead}v$formatHead', 'Pitch size'),
      QuickInfo(surfaceWord.isEmpty ? '—' : surfaceWord, 'Surface'),
      const QuickInfo('Lights', 'Floodlit'),
      const QuickInfo('Parking', 'Available'),
    ];
  }

  List<Review> get reviews => _details?.reviews ?? const [];
  List<String> get amenities => _details?.amenities ?? const [];
  List<String> get goodToKnow => _details?.goodToKnow ?? const [];
  List<String> get reviewTags => _details?.reviewTags ?? const [];

  // ---- Gated actions (copy passed in from the view so it is localized) ----
  void showComingSoon(String message) => _toast.show(message);
}
