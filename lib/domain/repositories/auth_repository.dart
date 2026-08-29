import 'package:flutter/foundation.dart';

import '../entities/user_profile.dart';

/// Player session management against the live `/auth/*` endpoints.
///
/// Sessions are a 30-day bearer JWT. Two ways in:
///  * **Email code** — `POST /auth/email/start` then `POST /auth/email/verify`.
///  * **Google / Apple** — the app opens `/auth/{provider}/start` in a WebView
///    and intercepts the redirect carrying `#oauth_token=<jwt>`, then adopts
///    that token here.
///
/// Extends [Listenable] so Profile/Explore react when the session changes.
abstract class AuthRepository implements Listenable {
  /// The signed-in player, or null when browsing as a guest.
  UserProfile? get currentUser;
  bool get isSignedIn;

  /// `POST /auth/email/start` — emails a 6-digit code (valid 10 minutes).
  Future<void> sendEmailCode(String email);

  /// `POST /auth/email/verify` — trades the code for a token and opens
  /// the session. Throws [ApiException] on a wrong/expired code (400) or
  /// after too many attempts (429).
  Future<UserProfile> verifyEmailCode({
    required String email,
    required String code,
  });

  /// Stores a JWT captured from the Google/Apple redirect and hydrates the
  /// profile via `GET /auth/me`.
  Future<UserProfile> adoptOAuthToken(String token);

  /// Sliding refresh: `POST /auth/refresh` when the stored token is past
  /// half-life. Silently signs out if the token turns out to be invalid.
  Future<void> refreshIfNeeded();

  /// Drops the token and cached profile (sign-out is client-side).
  Future<void> signOut();
}
