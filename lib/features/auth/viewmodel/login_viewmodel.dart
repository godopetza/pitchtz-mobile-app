import 'package:flutter/foundation.dart';

import '../../../core/auth/social_auth_service.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';

enum LoginStep { email, code }

/// How a native social sign-in attempt ended.
enum NativeSignInStatus {
  /// Session opened — done.
  success,

  /// User dismissed the native sheet — do nothing.
  cancelled,

  /// Native path can't complete here (SDK unconfigured, or the backend has
  /// no `/auth/{provider}/token` yet) — fall back to the browser flow.
  unavailable,
}

class NativeSignInResult {
  const NativeSignInResult(this.status, [this.user]);
  final NativeSignInStatus status;
  final UserProfile? user;
}

/// Drives the sign-in screen: email → 6-digit code → session, plus native
/// Google/Apple sign-in (device accounts) with the browser redirect flow as
/// fallback. API errors ([ApiException]) bubble to the view, which toasts
/// their message; the ViewModel only manages step/busy state.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._auth, this._social);

  final AuthRepository _auth;
  final SocialAuthService _social;

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

  /// OAuth fallback: store the intercepted JWT and hydrate via `GET /auth/me`.
  Future<UserProfile> adoptToken(String token) =>
      _run(() => _auth.adoptOAuthToken(token));

  /// Silent sign-in for returning users: restores the Google account already
  /// signed in on this device (no picker, no typing) and trades its ID token
  /// for a session. Returns null — quietly — whenever that isn't possible;
  /// the login screen then just behaves as usual.
  Future<UserProfile?> trySilentSignIn() async {
    if (!ApiConfig.nativeSocialAuth) return null;
    final social = await _social.googleSilent();
    if (social == null) return null;
    try {
      return await _run(() => _auth.signInWithIdToken(
            provider: 'google',
            idToken: social.idToken,
            name: social.name,
            email: social.email,
          ));
    } on ApiException {
      // Backend missing /auth/google/token, expired token, offline — the
      // user can still sign in normally, so never surface this.
      return null;
    }
  }

  /// Native social sign-in: shows the device's Google account picker or the
  /// Apple Face ID sheet, then trades the provider's ID token for a session.
  ///
  /// Returns [NativeSignInStatus.unavailable] when either side of the native
  /// path is missing so the view can fall back to the browser redirect flow.
  /// Real API errors (bad token, server down) still throw [ApiException].
  Future<NativeSignInResult> signInWithProvider(String provider) async {
    // Don't prompt natively (Face ID / account picker) when the backend can't
    // redeem the resulting token — the user would have to sign in twice.
    if (!ApiConfig.nativeSocialAuth) {
      return const NativeSignInResult(NativeSignInStatus.unavailable);
    }
    final SocialAuthResult social;
    try {
      social = provider == 'apple' ? await _social.apple() : await _social.google();
    } on SocialAuthCancelled {
      return const NativeSignInResult(NativeSignInStatus.cancelled);
    } on SocialAuthUnavailable {
      return const NativeSignInResult(NativeSignInStatus.unavailable);
    }

    try {
      final user = await _run(() => _auth.signInWithIdToken(
            provider: provider,
            idToken: social.idToken,
            name: social.name,
            email: social.email,
          ));
      return NativeSignInResult(NativeSignInStatus.success, user);
    } on ApiException catch (e) {
      // Backend hasn't shipped /auth/{provider}/token yet.
      if (e.statusCode == 404 || e.statusCode == 405) {
        return const NativeSignInResult(NativeSignInStatus.unavailable);
      }
      rethrow;
    }
  }
}
