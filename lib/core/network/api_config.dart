/// API environment configuration.
///
/// Defaults to the PitchTZ production backend. Override at build/run time with:
///   flutter run --dart-define=PITCHTZ_API_BASE=http://localhost:8080/v1
class ApiConfig {
  ApiConfig._();

  /// All routes live under `/v1` (except /health, /docs, /openapi.yaml).
  static const String baseUrl = String.fromEnvironment(
    'PITCHTZ_API_BASE',
    defaultValue: 'https://pitchtz-production.up.railway.app/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// The IANA timezone the availability endpoint expects for `date=YYYY-MM-DD`.
  static const String venueTimezone = 'Africa/Dar_es_Salaam';

  /// Native Google/Apple sign-in exchanges a device-issued ID token via
  /// `POST /auth/{provider}/token` — endpoints the backend hasn't shipped yet
  /// (per docs/openapi.yaml only the `/auth/{provider}/start` redirect flow
  /// exists). Left off, sign-in goes straight to the browser redirect flow
  /// instead of prompting natively first and then asking the user to sign in
  /// a second time after the exchange 404s. Flip on once the backend adds
  /// the token endpoints:
  ///   flutter run --dart-define=PITCHTZ_NATIVE_AUTH=true
  static const bool nativeSocialAuth =
      bool.fromEnvironment('PITCHTZ_NATIVE_AUTH');
}
