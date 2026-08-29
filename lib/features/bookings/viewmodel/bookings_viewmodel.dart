import 'package:flutter/foundation.dart';

import '../../../domain/entities/api_booking.dart';
import '../../../domain/repositories/booking_repository.dart';

enum BookingsTab { upcoming, past }

class BookingsViewModel extends ChangeNotifier {
  BookingsViewModel(this._repo) {
    _repo.addListener(_onRepoChanged);
  }

  final BookingRepository _repo;

  BookingsTab _tab = BookingsTab.upcoming;
  BookingsTab get tab => _tab;
  bool get isUpcoming => _tab == BookingsTab.upcoming;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  void setUpcoming() {
    _tab = BookingsTab.upcoming;
    notifyListeners();
  }

  void setPast() {
    _tab = BookingsTab.past;
    notifyListeners();
  }

  /// Bookings shown on the Upcoming tab:
  ///   - status is pending, part_paid, or confirmed AND
  ///   - endsAt is in the future.
  List<ApiBooking> get upcoming {
    final now = DateTime.now().toUtc();
    return _repo.cachedBookings.where((b) {
      final activeStatus = b.status == 'pending' ||
          b.status == 'part_paid' ||
          b.status == 'confirmed';
      return activeStatus && b.endsAt.isAfter(now);
    }).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  /// Bookings shown on the Past tab:
  ///   - status is completed or cancelled, OR
  ///   - endsAt is in the past (regardless of status).
  List<ApiBooking> get past {
    final now = DateTime.now().toUtc();
    return _repo.cachedBookings.where((b) {
      final doneStatus =
          b.status == 'completed' || b.status == 'cancelled';
      return doneStatus || b.endsAt.isBefore(now);
    }).toList()
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt)); // newest first
  }

  /// Fetches the latest booking list from the API and updates the cache.
  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.getMyBookings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }
}
