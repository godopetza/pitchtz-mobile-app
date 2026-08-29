import 'package:flutter/foundation.dart';

import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/booking_repository.dart';

enum BookingsTab { upcoming, past }

class BookingsViewModel extends ChangeNotifier {
  BookingsViewModel(this._repo) {
    _repo.addListener(notifyListeners);
  }

  final BookingRepository _repo;

  BookingsTab _tab = BookingsTab.upcoming;
  BookingsTab get tab => _tab;
  bool get isUpcoming => _tab == BookingsTab.upcoming;

  void setUpcoming() {
    _tab = BookingsTab.upcoming;
    notifyListeners();
  }

  void setPast() {
    _tab = BookingsTab.past;
    notifyListeners();
  }

  List<Booking> get upcoming => _repo.getUpcoming();
  List<Booking> get past => _repo.getPast();

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }
}
