import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Local device session persisted in [SharedPreferences].
///
/// The backend has no player auth yet (`/auth/*` is `planned` → 404), so this
/// keeps the sign-in/sign-out UX working end-to-end on-device. When the real
/// endpoints ship, replace the bodies with API calls + JWT storage — the
/// interface and everything above it stay identical.
class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  AuthRepositoryImpl(this._prefs) {
    final name = _prefs.getString(_kName);
    if (name != null) {
      _user = UserProfile(
        name: name,
        phone: _prefs.getString(_kPhone) ?? '',
        provider: _prefs.getString(_kProvider) ?? 'phone',
      );
    }
  }

  static const _kName = 'session_name';
  static const _kPhone = 'session_phone';
  static const _kProvider = 'session_provider';

  /// Demo identity used until real accounts exist server-side.
  static const _demoName = 'Juma Mwakalinga';

  final SharedPreferences _prefs;
  UserProfile? _user;

  @override
  UserProfile? get currentUser => _user;

  @override
  bool get isSignedIn => _user != null;

  @override
  List<String> get demoCode => const ['4', '7', '2', '9', '1', '8'];

  @override
  Future<void> sendCode(String phone) =>
      Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<UserProfile> verifyCode(
      {required String phone, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _open(UserProfile(name: _demoName, phone: phone));
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _open(const UserProfile(
        name: _demoName, phone: '', provider: 'google'));
  }

  @override
  Future<UserProfile> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _open(
        const UserProfile(name: _demoName, phone: '', provider: 'apple'));
  }

  Future<UserProfile> _open(UserProfile user) async {
    _user = user;
    await _prefs.setString(_kName, user.name);
    await _prefs.setString(_kPhone, user.phone);
    await _prefs.setString(_kProvider, user.provider);
    notifyListeners();
    return user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    await _prefs.remove(_kName);
    await _prefs.remove(_kPhone);
    await _prefs.remove(_kProvider);
    notifyListeners();
  }
}
