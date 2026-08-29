import 'package:shared_preferences/shared_preferences.dart';

/// Holds the 30-day bearer JWT issued by `/auth/*`.
///
/// Lives below [ApiClient] (which reads it on every request) and below
/// `AuthRepositoryImpl` (which writes it on sign-in / refresh / sign-out),
/// breaking what would otherwise be a dependency cycle between the two.
class TokenStore {
  TokenStore(this._prefs);

  static const _kToken = 'auth_token';
  static const _kExpiresAt = 'auth_expires_at';

  /// Tokens are issued for 30 days; refresh is allowed past half-life.
  static const tokenLife = Duration(days: 30);

  final SharedPreferences _prefs;

  String? get token {
    final t = _prefs.getString(_kToken);
    if (t == null) return null;
    final exp = expiresAt;
    // An expired token is worse than none: the server 401s every call.
    if (exp != null && DateTime.now().isAfter(exp)) return null;
    return t;
  }

  DateTime? get expiresAt {
    final raw = _prefs.getString(_kExpiresAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  bool get hasToken => token != null;

  /// Per the contract: refresh once the token is past half its life.
  bool get isPastHalfLife {
    final exp = expiresAt;
    if (token == null || exp == null) return false;
    return DateTime.now().isAfter(exp.subtract(tokenLife ~/ 2));
  }

  Future<void> save(String token, DateTime expiresAt) async {
    await _prefs.setString(_kToken, token);
    await _prefs.setString(_kExpiresAt, expiresAt.toIso8601String());
  }

  Future<void> clear() async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kExpiresAt);
  }
}
