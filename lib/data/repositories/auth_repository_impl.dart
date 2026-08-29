import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/token_store.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/json.dart';

/// Real session against the live `/auth/*` endpoints.
///
/// The 30-day bearer JWT lives in [TokenStore] (where [ApiClient] picks it up
/// for every request); the profile is cached in [SharedPreferences] so the app
/// opens signed-in without waiting on the network.
class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  AuthRepositoryImpl(this._prefs, this._api, this._tokens) {
    final cached = _prefs.getString(_kUser);
    if (_tokens.hasToken && cached != null) {
      try {
        _user = _profileFromJson(
            (jsonDecode(cached) as Map).cast<String, dynamic>());
      } catch (_) {
        _user = null;
      }
    }
    // Token gone/expired but a stale profile remains — drop it.
    if (!_tokens.hasToken && cached != null) _prefs.remove(_kUser);
  }

  static const _kUser = 'session_user';

  final SharedPreferences _prefs;
  final ApiClient _api;
  final TokenStore _tokens;
  UserProfile? _user;

  @override
  UserProfile? get currentUser => _user;

  @override
  bool get isSignedIn => _user != null && _tokens.hasToken;

  @override
  Future<void> sendEmailCode(String email) =>
      _api.post('/auth/email/start', body: {'email': email});

  @override
  Future<UserProfile> verifyEmailCode(
      {required String email, required String code}) async {
    final data = await _api.post('/auth/email/verify',
        body: {'email': email, 'code': code});
    return _openFromGrant(data);
  }

  @override
  Future<UserProfile> adoptOAuthToken(String token) async {
    // The redirect fragment only carries the JWT; its `exp` claim is the
    // authoritative expiry (fall back to the documented 30 days).
    final expiresAt =
        _jwtExpiry(token) ?? DateTime.now().add(TokenStore.tokenLife);
    await _tokens.save(token, expiresAt);
    try {
      final me = await _api.getObject('/auth/me');
      return await _open(_profileFromJson(me));
    } catch (_) {
      await _tokens.clear();
      rethrow;
    }
  }

  @override
  Future<void> refreshIfNeeded() async {
    if (!isSignedIn || !_tokens.isPastHalfLife) return;
    try {
      final data = await _api.post('/auth/refresh');
      await _openFromGrant(data);
    } on ApiException catch (e) {
      // 401 = the token no longer refreshes; fall back to signed-out.
      if (e.statusCode == 401) await signOut();
      // Network blips: keep the session, try again next launch.
    }
  }

  @override
  Future<void> signOut() async {
    _user = null;
    await _tokens.clear();
    await _prefs.remove(_kUser);
    notifyListeners();
  }

  // ---- helpers ----

  /// TokenGrant: `{ access_token, token_type, expires_at, user }`.
  Future<UserProfile> _openFromGrant(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected sign-in response.');
    }
    final token = J.str(data, 'access_token');
    if (token.isEmpty) throw ApiException('Sign-in response had no token.');
    final expiresAt = J.date(data, 'expires_at') ??
        DateTime.now().add(TokenStore.tokenLife);
    await _tokens.save(token, expiresAt);
    final userJson = J.obj(data, 'user') ?? const <String, dynamic>{};
    return _open(_profileFromJson(userJson));
  }

  Future<UserProfile> _open(UserProfile user) async {
    _user = user;
    await _prefs.setString(
        _kUser,
        jsonEncode({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'avatar_url': user.avatarUrl,
          'language': user.language,
        }));
    notifyListeners();
    return user;
  }

  UserProfile _profileFromJson(Map<String, dynamic> m) {
    final email = J.str(m, 'email');
    final name = J.str(m, 'name');
    return UserProfile(
      id: J.str(m, 'id'),
      // OAuth accounts may arrive nameless — show the mailbox instead.
      name: name.isNotEmpty ? name : email.split('@').first,
      email: email,
      avatarUrl: J.strOrNull(m, 'avatar_url'),
      language: J.str(m, 'language', fallback: 'en'),
    );
  }

  /// Reads the `exp` claim off a JWT without verifying it (the server is the
  /// verifier — we only need the expiry for the refresh schedule).
  static DateTime? _jwtExpiry(String jwt) {
    for (final part in jwt.split('.')) {
      try {
        final decoded = utf8.decode(
            base64Url.decode(base64Url.normalize(part)));
        final map = jsonDecode(decoded);
        if (map is Map && map['exp'] is num) {
          return DateTime.fromMillisecondsSinceEpoch(
              (map['exp'] as num).toInt() * 1000);
        }
      } catch (_) {
        // Not a JSON segment (header/signature) — keep looking.
      }
    }
    return null;
  }
}
