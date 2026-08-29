import 'package:flutter/foundation.dart';

import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';

enum LoginStep { email, code }

/// Drives the sign-in screen: email → 6-digit code → session, plus adopting
/// the JWT captured from the Google/Apple redirect. API errors ([ApiException])
/// bubble to the view, which toasts their message; the ViewModel only manages
/// step/busy state.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._auth);

  final AuthRepository _auth;

  LoginStep _step = LoginStep.email;
  bool _busy = false;
  String _email = '';
  String _code = '';

  LoginStep get step => _step;
  bool get isCodeStep => _step == LoginStep.code;
  bool get busy => _busy;
  String get email => _email;
  bool get emailLooksValid =>
      RegExp(r'^\S+@\S+\.\S+$').hasMatch(_email);
  bool get codeComplete => _code.length == 6;

  void setEmail(String value) => _email = value.trim();

  void setCode(String value) {
    _code = value.trim();
    notifyListeners(); // enables the verify button at 6 digits
  }

  /// Back from the code step to fix a typo'd address.
  void changeEmail() {
    _step = LoginStep.email;
    _code = '';
    notifyListeners();
  }

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

  /// Email step: `POST /auth/email/start`. Advances to the code step.
  Future<void> sendCode() async {
    await _run(() => _auth.sendEmailCode(_email));
    _step = LoginStep.code;
    _code = '';
    notifyListeners();
  }

  /// Code step: `POST /auth/email/verify` — opens the session.
  Future<UserProfile> verify() =>
      _run(() => _auth.verifyEmailCode(email: _email, code: _code));

  /// OAuth: store the intercepted JWT and hydrate via `GET /auth/me`.
  Future<UserProfile> adoptToken(String token) =>
      _run(() => _auth.adoptOAuthToken(token));
}
