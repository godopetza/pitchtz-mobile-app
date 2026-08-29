import 'package:flutter/foundation.dart';

import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Exposes the session to the Profile screen and performs logout.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._auth) {
    _auth.addListener(notifyListeners);
  }

  final AuthRepository _auth;

  bool get isSignedIn => _auth.isSignedIn;
  UserProfile? get user => _auth.currentUser;

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _auth.removeListener(notifyListeners);
    super.dispose();
  }
}
