import 'dart:async';

import 'package:flutter/foundation.dart';

/// App-wide lightweight toast (the design's `appToast`): a message that shows
/// for 2.4s above the bottom nav. Provided once at the root and rendered by an
/// overlay in [AppRoot].
class ToastController extends ChangeNotifier {
  String? _message;
  Timer? _timer;

  String? get message => _message;
  bool get isVisible => _message != null;

  void show(String message) {
    _message = message;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2400), () {
      _message = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
