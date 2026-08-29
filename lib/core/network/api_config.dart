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
}
