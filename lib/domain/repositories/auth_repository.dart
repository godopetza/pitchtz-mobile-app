import 'package:flutter/foundation.dart';

import '../entities/user_profile.dart';

/// Player session management.
///
/// Backend player auth (`/auth/otp/*`, `/auth/oauth/*`) is still `planned`, so
/// the current implementation keeps a **local device session** — but this
/// contract is shaped for the real endpoints: swap the implementation to call
/// them and store the JWTs instead, and nothing above this interface changes.
///
/// Extends [Listenable] so Profile/Explore react when the session changes.
abstract class AuthRepository implements Listenable {
  /// The signed-in player, or null when browsing as a guest.
  UserProfile? get currentUser;
  bool get isSignedIn;

  /// The 6-digit demo code pre-filled in the OTP boxes.
  List<String> get demoCode;

  /// `POST /auth/otp/send` (stubbed locally today).
  Future<void> sendCode(String phone);

  /// `POST /auth/otp/verify` — verifies and opens a session.
  Future<UserProfile> verifyCode({required String phone, required String code});

  /// `POST /auth/oauth/{provider}` — opens a session via Google / Apple.
  Future<UserProfile> signInWithGoogle();
  Future<UserProfile> signInWithApple();

  /// `POST /auth/logout` — ends the session.
  Future<void> signOut();
}
