import 'package:flutter/foundation.dart';

import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';

enum LoginStep { phone, code }

/// Drives the sign-in screen: phone → OTP → session, plus Google/Apple.
/// Toast copy lives in the view so it is localized; the ViewModel only
/// returns the signed-in [UserProfile].
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._auth);

  final AuthRepository _auth;

  LoginStep _step = LoginStep.phone;
  bool _busy = false;
  String _phone = '';

  LoginStep get step => _step;
  bool get isCodeStep => _step == LoginStep.code;
  bool get busy => _busy;
  String get phone => _phone;
  List<String> get digits => _auth.demoCode;

  void setPhone(String value) => _phone = value.trim();

  Future<T> _run<T>(Future<T> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Phone step: sends the OTP. Returns false if the phone field is empty.
  Future<bool> sendCode() async {
    if (_phone.isEmpty) return false;
    await _run(() => _auth.sendCode(_phone));
    _step = LoginStep.code;
    notifyListeners();
    return true;
  }

  /// Code step: verifies and opens the session.
  Future<UserProfile> verify() => _run(() => _auth.verifyCode(
        phone: '+255 $_phone',
        code: digits.join(),
      ));

  Future<UserProfile> signInWithGoogle() => _run(_auth.signInWithGoogle);

  Future<UserProfile> signInWithApple() => _run(_auth.signInWithApple);
}
