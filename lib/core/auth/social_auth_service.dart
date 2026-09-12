import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Outcome of a native provider sign-in: the provider-signed ID token the
/// backend verifies, plus profile hints (Apple only shares the name once).
class SocialAuthResult {
  const SocialAuthResult({required this.idToken, this.email, this.name});
  final String idToken;
  final String? email;
  final String? name;
}

/// The user dismissed the native sheet — not an error, just stop quietly.
class SocialAuthCancelled implements Exception {}

/// Native sign-in can't run here (platform unsupported or the provider is
/// not configured for this build) — callers fall back to the web flow.
class SocialAuthUnavailable implements Exception {
  SocialAuthUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'SocialAuthUnavailable: $reason';
}

/// Native device sign-in:
///  * **Google** — the system account picker listing the accounts already on
///    the device (Credential Manager on Android, GoogleSignIn SDK on iOS).
///  * **Apple** — the iOS Face ID / Touch ID sheet for the device's Apple ID.
///
/// Both produce an ID token for the backend to verify (`POST
/// /auth/{provider}/token`). Google tokens carry the backend's web client ID
/// as audience so the server can verify them with its existing OAuth config.
class SocialAuthService {
  /// The backend's Google OAuth web client — the same one
  /// `/auth/google/start` uses, so ID tokens minted against it verify
  /// server-side without new Google-console config.
  static const _serverClientId =
      '774754517096-aooc2l4nnk4nqberbr50nl1amvj2rb0m.apps.googleusercontent.com';

  bool _googleReady = false;

  Future<void> _initGoogle() async {
    if (_googleReady) return;
    // On iOS the SDK additionally needs an iOS OAuth client — supplied via
    // `GIDClientID` in Info.plist. Missing config surfaces as an
    // initialization/authenticate error, which we map to "unavailable".
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _googleReady = true;
  }

  /// Silent Google re-authentication — no typing, no full account picker.
  ///
  /// Uses `attemptLightweightAuthentication()`: on Android the Credential
  /// Manager returns the previously used device account (at most a one-tap
  /// "Continue as …" sheet); on iOS the SDK restores the prior sign-in with
  /// no UI at all. Returns null when nothing can be restored without full
  /// interaction — callers just show the normal login screen.
  Future<SocialAuthResult?> googleSilent() async {
    try {
      await _initGoogle();
      final account =
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      final idToken = account?.authentication.idToken;
      if (account == null || idToken == null || idToken.isEmpty) return null;
      return SocialAuthResult(
        idToken: idToken,
        email: account.email,
        name: account.displayName,
      );
    } catch (e) {
      // Silent path is best-effort only — any failure means "not restored".
      debugPrint('Silent Google sign-in skipped: $e');
      return null;
    }
  }

  /// Drops the plugin's cached Google session so an explicit app logout
  /// doesn't get silently signed straight back in by [googleSilent].
  Future<void> signOutGoogle() async {
    try {
      await _initGoogle();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google sign-out skipped: $e');
    }
  }

  /// Native Google sign-in → verified ID token.
  Future<SocialAuthResult> google() async {
    try {
      await _initGoogle();
      final signIn = GoogleSignIn.instance;
      if (!signIn.supportsAuthenticate()) {
        throw SocialAuthUnavailable('authenticate() unsupported here');
      }
      final account =
          await signIn.authenticate(scopeHint: const ['email', 'profile']);
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw SocialAuthUnavailable('Google returned no ID token');
      }
      return SocialAuthResult(
        idToken: idToken,
        email: account.email,
        name: account.displayName,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw SocialAuthCancelled();
      }
      // clientConfigurationError / providerConfigurationError / unknown —
      // this build isn't wired for native Google yet.
      debugPrint('Native Google sign-in failed: ${e.code} ${e.description}');
      throw SocialAuthUnavailable('${e.code}');
    } on SocialAuthCancelled {
      rethrow;
    } on SocialAuthUnavailable {
      rethrow;
    } catch (e) {
      debugPrint('Native Google sign-in failed: $e');
      throw SocialAuthUnavailable('$e');
    }
  }

  /// Native Apple sign-in → identity token (iOS/macOS only).
  Future<SocialAuthResult> apple() async {
    final isApplePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (!isApplePlatform) {
      throw SocialAuthUnavailable('Sign in with Apple is iOS-only here');
    }
    try {
      // Throws MissingPluginException until the app is rebuilt with the
      // plugin's native code — caught below so the web flow takes over.
      if (!await SignInWithApple.isAvailable()) {
        throw SocialAuthUnavailable('Sign in with Apple needs iOS 13+');
      }
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw SocialAuthUnavailable('Apple returned no identity token');
      }
      final name = [credential.givenName, credential.familyName]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' ');
      return SocialAuthResult(
        idToken: idToken,
        email: credential.email,
        name: name.isEmpty ? null : name,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw SocialAuthCancelled();
      }
      debugPrint('Native Apple sign-in failed: ${e.code} ${e.message}');
      throw SocialAuthUnavailable('${e.code}');
    } on SocialAuthCancelled {
      rethrow;
    } on SocialAuthUnavailable {
      rethrow;
    } catch (e) {
      debugPrint('Native Apple sign-in failed: $e');
      throw SocialAuthUnavailable('$e');
    }
  }
}
