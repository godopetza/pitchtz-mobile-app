import 'package:flutter/foundation.dart';

import '../../../domain/entities/api_booking.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/booking_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._auth, this._bookings) {
    _auth.addListener(_onAuthChanged);
    _bookings.addListener(_onBookingsChanged);
  }

  final AuthRepository _auth;
  final BookingRepository _bookings;

  bool _loading = false;

  bool get isLoading => _loading;
  bool get isSignedIn => _auth.isSignedIn;
  UserProfile? get user => _auth.currentUser;

  List<ApiBooking> get bookings => _bookings.cachedBookings;
  int get totalBookings => _bookings.cachedBookings.length;
  int get completedBookings =>
      _bookings.cachedBookings.where((b) => b.isCompleted).length;
  int get upcomingBookings => _bookings.cachedBookings
      .where((b) => b.isConfirmed && !b.isCompleted)
      .length;

  Future<void> load() async {
    if (!isSignedIn) return;
    _loading = true;
    notifyListeners();
    try {
      await _bookings.getMyBookings();
    } catch (_) {
      // silently ignore — stale cache still shows
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _auth.signOut();

  void _onAuthChanged() => notifyListeners();
  void _onBookingsChanged() => notifyListeners();

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _bookings.removeListener(_onBookingsChanged);
    super.dispose();
  }
}
