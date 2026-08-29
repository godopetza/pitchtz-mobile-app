/// JSON parsing helpers. The backend serialises snake_case, but the handoff doc
/// shows camelCase — so every reader tries snake_case first, then camelCase, to
/// stay robust regardless of which the server sends.
class J {
  J._();

  static dynamic _raw(Map m, String snake) {
    if (m.containsKey(snake)) return m[snake];
    final camel = _toCamel(snake);
    if (m.containsKey(camel)) return m[camel];
    return null;
  }

  static String _toCamel(String snake) {
    final parts = snake.split('_');
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();
  }

  static String str(Map m, String key, {String fallback = ''}) {
    final v = _raw(m, key);
    return v == null ? fallback : v.toString();
  }

  static String? strOrNull(Map m, String key) {
    final v = _raw(m, key);
    return v?.toString();
  }

  static int intVal(Map m, String key, {int fallback = 0}) {
    final v = _raw(m, key);
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.round() ?? fallback;
    return fallback;
  }

  static double dbl(Map m, String key, {double fallback = 0}) {
    final v = _raw(m, key);
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static double? dblOrNull(Map m, String key) {
    final v = _raw(m, key);
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static bool boolean(Map m, String key, {bool fallback = false}) {
    final v = _raw(m, key);
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return fallback;
  }

  static List<String> strList(Map m, String key) {
    final v = _raw(m, key);
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }

  static List<Map<String, dynamic>> objList(Map m, String key) {
    final v = _raw(m, key);
    if (v is List) {
      return v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  static Map<String, dynamic>? obj(Map m, String key) {
    final v = _raw(m, key);
    return v is Map ? v.cast<String, dynamic>() : null;
  }

  static DateTime? date(Map m, String key) {
    final v = _raw(m, key);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  /// Like [date] but the name makes call-sites read clearly for optional dates.
  static DateTime? dateOrNull(Map m, String key) => date(m, key);
}

/// Presentation helpers that normalise the API's short codes to display text.
class Display {
  Display._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// "5" / "5-a-side" -> "5-a-side"; "futsal" -> "Futsal".
  static String format(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    if (v.contains('-a-side')) return v;
    if (v.toLowerCase() == 'futsal') return 'Futsal';
    if (RegExp(r'^\d+$').hasMatch(v)) return '$v-a-side';
    return _capitalise(v);
  }

  /// "artificial_turf" -> "Artificial turf".
  static String surface(String raw) {
    if (raw.isEmpty) return '';
    final spaced = raw.replaceAll('_', ' ');
    return _capitalise(spaced);
  }

  /// ISO timestamp -> "Aug 2026".
  static String monthYear(DateTime? d) =>
      d == null ? '' : '${_months[d.month - 1]} ${d.year}';

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
