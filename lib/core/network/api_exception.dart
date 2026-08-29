/// A normalised API failure surfaced to ViewModels.
///
/// Produced from the backend error envelope
/// `{ "success": false, "error": { "code", "message" } }`, from non-2xx HTTP
/// responses, or from transport failures (timeouts, no connection).
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.isNetwork = false,
  });

  final String message;
  final String? code;
  final int? statusCode;

  /// True for transport-level failures (no connection / timeout), as opposed to
  /// a structured error the server returned.
  final bool isNetwork;

  /// A `planned` endpoint returns 404 today — callers can special-case this to
  /// show a "coming soon" state instead of an error.
  bool get isNotImplemented => statusCode == 404;

  /// A short, user-facing message safe to show in the UI.
  String get userMessage {
    if (isNetwork) return 'No connection. Check your internet and try again.';
    return message.isNotEmpty ? message : 'Something went wrong. Please try again.';
  }

  @override
  String toString() =>
      'ApiException(code: $code, status: $statusCode, message: $message)';
}
